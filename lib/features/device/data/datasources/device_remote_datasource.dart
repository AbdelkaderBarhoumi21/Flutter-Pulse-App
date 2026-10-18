/// Registers this device's push token with the backend.
abstract interface class DeviceRemoteDataSource {
  Future<void> register({required String token, required String platform});
}
