import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/flower.dart';
import '../models/walk.dart';
import 'db_service.dart';

class WalkService extends ChangeNotifier {
  final DbService _db = DbService();

  bool isWalking = false;
  int stepCount = 0;
  int flowerCount = 0;
  double distanceKm = 0.0;
  List<LatLng> route = [];
  List<Flower> currentFlowers = [];
  List<Flower> todayFlowers = [];
  Walk? currentWalk;
  LatLng? currentPosition;

  StreamSubscription? _accelSub;
  StreamSubscription? _gpsSub;

  double _lastMagnitude = 0;
  DateTime? _lastStepTime;
  static const double _stepThreshold = 11.5;
  static const int _stepsPerFlower = 15;

  // stride lengths in km
  static const double _walkStrideKm = 0.0007; // ~0.7m, normal walking
  static const double _jogStrideKm = 0.0010; // ~1.0m, light jog
  static const double _runStrideKm = 0.0014; // ~1.4m, running

  Future<void> loadToday() async {
    final flowers = await _db.getTodayFlowers();
    todayFlowers = flowers
        .where((f) => f.latitude.isFinite && f.longitude.isFinite)
        .toList();
    notifyListeners();
  }

  Future<void> startWalk() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    stepCount = 0;
    flowerCount = 0;
    distanceKm = 0.0;
    route = [];
    currentFlowers = [];
    _lastStepTime = null;

    try {
      final pos = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );
      if (pos.latitude.isFinite && pos.longitude.isFinite) {
        currentPosition = LatLng(pos.latitude, pos.longitude);
        route.add(currentPosition!);
      }
    } catch (_) {
      // ignore — stream will catch up shortly
    }

    final walkId = await _db.insertWalk(Walk(startedAt: DateTime.now()));
    currentWalk = Walk(id: walkId, startedAt: DateTime.now());

    _startGps();
    _startAccelerometer();
    isWalking = true;
    notifyListeners();
  }

  void _startGps() {
    _gpsSub =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 3,
          ),
        ).listen((pos) {
          if (!pos.latitude.isFinite || !pos.longitude.isFinite) return;
          final point = LatLng(pos.latitude, pos.longitude);
          route.add(point);
          currentPosition = point;
          notifyListeners();
        });
  }

  void _startAccelerometer() {
    _accelSub = accelerometerEventStream().listen((event) {
      final magnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );
      if (magnitude > _stepThreshold && _lastMagnitude <= _stepThreshold) {
        final now = DateTime.now();
        final stride = _strideForCadence(now);
        _lastStepTime = now;

        stepCount++;
        distanceKm += stride;

        if (stepCount % _stepsPerFlower == 0) _plantFlower();
        notifyListeners();
      }
      _lastMagnitude = magnitude;
    });
  }

  /// Picks a stride length based on how fast steps are happening.
  /// Faster cadence (shorter time between steps) = running, longer stride.
  double _strideForCadence(DateTime now) {
    if (_lastStepTime == null) return _walkStrideKm;

    final gapMs = now.difference(_lastStepTime!).inMilliseconds;
    if (gapMs <= 0) return _walkStrideKm;

    // Typical walking cadence: ~450-600ms between steps
    // Jogging: ~350-450ms
    // Running: under 350ms
    if (gapMs < 350) {
      return _runStrideKm;
    } else if (gapMs < 450) {
      return _jogStrideKm;
    } else {
      return _walkStrideKm;
    }
  }

  Future<void> _plantFlower() async {
    if (currentWalk == null) return;

    LatLng? plantPoint =
        currentPosition ?? (route.isNotEmpty ? route.last : null);
    if (plantPoint == null) return;

    final flower = Flower(
      latitude: plantPoint.latitude,
      longitude: plantPoint.longitude,
      emoji: Flower.randomEmoji(),
      plantedAt: DateTime.now(),
      walkId: currentWalk!.id!,
    );
    await _db.insertFlower(flower);
    currentFlowers.add(flower);
    todayFlowers.insert(0, flower);
    flowerCount++;
    notifyListeners();
  }

  Future<Walk?> stopWalk() async {
    if (currentWalk == null) return null;
    _accelSub?.cancel();
    _gpsSub?.cancel();
    isWalking = false;

    final finished = currentWalk!.copyWith(
      endedAt: DateTime.now(),
      stepCount: stepCount,
      flowerCount: flowerCount,
      distanceKm: distanceKm,
    );
    await _db.updateWalk(finished);
    currentWalk = finished;
    notifyListeners();
    return finished;
  }
}
