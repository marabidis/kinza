// import 'package:flutter/material.dart';
// import 'orders/home_screen.dart'; // импортируйте свой файл с HomeScreen
// import 'package:flutter_svg/flutter_svg.dart';
// import '/services/api_client.dart';

// class SplashScreen extends StatefulWidget {
//   final ApiClient apiClient;

//   SplashScreen({required this.apiClient});

//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   late Future<void> _loadingData;

//   @override
//   void initState() {
//     super.initState();
//     _loadingData = _loadData();
//   }

//   Future<void> _loadData() async {
//     // Здесь ваш код для загрузки данных...
//     await Future.delayed(Duration(seconds: 2)); // Имитация задержки
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<void>(
//       future: _loadingData,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             _navigateToHome();
//           });
//           return _buildSplashScreen();
//         } else if (snapshot.hasError) {
//           // Добавленная проверка на ошибку
//           return Scaffold(
//             body: Center(child: Text('Error: ${snapshot.error}')),
//           );
//         } else {
//           // Данные еще загружаются
//           return _buildLoadingScreen();
//         }
//       },
//     );
//   }

//   Widget _buildSplashScreen() {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SvgPicture.asset(
//               'assets/logo_kinza.svg',
//               height: 100,
//             ),
//             SizedBox(height: 20),
//             Text("Сейчас будет вкусно!"),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLoadingScreen() {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SvgPicture.asset(
//               'assets/logo_kinza.svg',
//               height: 100,
//             ),
//             SizedBox(height: 20),
//             CircularProgressIndicator(), // Индикатор загрузки
//           ],
//         ),
//       ),
//     );
//   }

//   void _navigateToHome() {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => HomeScreen(apiClient: widget.apiClient),
//       ),
//     );
//   }
// }
