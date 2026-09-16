// import 'package:dio/dio.dart';

// class ApiClient {
//   late final Dio dio;

//   ApiClient() {
//     dio = Dio(
//       BaseOptions(
//         baseUrl: "https://dummyjson.com",
//         connectTimeout: const Duration(seconds: 30),
//         receiveTimeout: const Duration(seconds: 30),
//         headers: {
//           "Content-Type": "application/json",
//           "Accept": "application/json",
//         },
//       ),
//     );

//     dio.interceptors.add(
//       LogInterceptor(
//         request: true,
//         requestBody: true,
//         responseBody: true,
//         error: true,
//       ),
//     );
//   }
// }
