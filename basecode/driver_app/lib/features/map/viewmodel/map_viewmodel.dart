import 'package:driver_app/features/map/repository/map_realtime_db_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class MapViewModel extends ChangeNotifier {
  final Logger logger = Logger();
  final MapRealtimeDBService realtimeDBService = MapRealtimeDBService();
  bool _driverInQueue = false;
  int? _currenQueuePoosition;

  //GETTERS
  bool get driverInQueue => _driverInQueue;
  int? get currenQueuePoosition => _currenQueuePoosition;

  //SETTERS
  set driverInQueue(bool value) {
    _driverInQueue = value;
    notifyListeners();
  }

  set currenQueuePoosition(int? value) {
    _currenQueuePoosition = value;
    notifyListeners();
  }
}
