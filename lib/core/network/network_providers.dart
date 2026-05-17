import 'package:dio/dio.dart';
import 'package:flutter_pulse_app/core/network/app_dio_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Single shared [Dio] for the whole app.
///
/// Datasources should receive this via constructor injection — never reach
/// into [AppDioClient] directly. Riverpod caches the result, so every
/// `ref.watch(dioProvider)` returns the same instance.
final dioProvider = Provider<Dio>((ref) => AppDioClient.create());
