# API Documentation

## HTTP Headers

```dart
headers: {
  // Type of content sent in the request body
  'Content-Type': 'application/json',

  // Authentication
  'Authorization': 'Bearer eyJhbGciOi...',

  // Type of content expected in the response body
  'Accept': 'application/json',

  // Preferred language for the response (if the API supports localization)
  'Accept-Language': 'fr-FR',
}
```

## Dio Interceptors

```dart
dio.interceptors.add(
  InterceptorsWrapper(
    // Before sending the request
    onRequest: (options, handler) {
      options.headers['Authorization'] = 'Bearer $token';
      handler.next(options); // continue
    },

    // When response is received
    onResponse: (response, handler) {
      print('Status: ${response.statusCode}');
      handler.next(response); // continue
    },

    // When an error occurs
    onError: (error, handler) {
      if (error.response?.statusCode == 401) {
        // token expired → refresh token
      }
      handler.next(error); // continue
    },
  ),
);
```
