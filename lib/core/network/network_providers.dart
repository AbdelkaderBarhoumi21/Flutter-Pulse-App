import 'package:dio/dio.dart';
import 'package:flutter_pulse_app/core/network/app_dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Single shared [Dio] for the whole app, injected into every datasource.
final dioProvider = Provider<Dio>((ref) {
  final dio = AppDioClient.create();
  ref.onDispose(dio.close);
  return dio;
});
