import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class LogUtil {
  LogUtil._();

  static final LogUtil _instance = LogUtil._();

  factory LogUtil() => _instance;
  
  late final Logger _logger;

  static Future<String> _getLogFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return path.join(directory.path, 'app_log.txt');
  }

  Future<void> _initLogger() async {
    if (kDebugMode) {
      _logger = Logger(
        printer: PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          printTime: true,
        ),
        output: ConsoleOutput(),
        filter: DevelopmentFilter(),
      );
    } else {
      final logFilePath = await _getLogFilePath();
      _logger = Logger(
        printer: PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 5,
          lineLength: 120,
          colors: false,
          printEmojis: false,
          printTime: true,
        ),
        output: MultiOutput([
          ConsoleOutput(),
          FileOutput(file: File(logFilePath)),
        ]),
        filter: ProductionFilter(),
      );
    }
  }

  Future<void> init() async {
    await _initLogger();
  }

  void error(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  void fatal(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  void info(dynamic message) {
    _logger.i(message);
  }

  void debug(dynamic message) {
    _logger.d(message);
  }

  void warning(dynamic message) {
    _logger.w(message);
  }

}


final logger = LogUtil();