import 'package:flutter/material.dart';
import 'home_screen.dart'; // импортируйте свой файл с HomeScreen
import 'package:flutter_svg/flutter_svg.dart';
//import 'package:rive/rive.dart';
import 'package:flutter_svg/svg.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Future<void> _loadingData;

  @override
  void initState() {
    super.initState();
    _loadingData = _loadData();
  }

  Future<void> _loadData() async {
    // Здесь ваш код для загрузки данных...
    await Future.delayed(Duration(seconds: 2)); // Имитация задержки
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadingData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Данные загружены и готовы к использованию
          _navigateToHome();
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/logo_kinza.svg',
                    height: 100,
                  ),
                  SizedBox(height: 20),
                  Text("Сейчас будет вкусно!"),
                ],
              ),
            ),
          );
        } else {
          // Данные еще загружаются
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/logo_kinza.svg',
                    height: 100,
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator(), // Индикатор загрузки
                ],
              ),
            ),
          );
        }
      },
    );
  }

  _navigateToHome() {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeScreen()));
    });
  }
}


// import 'package:flutter/material.dart';
// import 'package:rive/rive.dart';
// import 'home_screen.dart'; // импортируйте свой файл с HomeScreen
// import 'package:flutter/services.dart';

// class SplashScreen extends StatefulWidget {
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   late final RiveFile _riveFile;
//   late Artboard _artboard;

//   @override
//   void initState() {
//     super.initState();
//     _loadRiveFile();
//     _navigateToHome();
//   }

//   Future<void> _loadRiveFile() async {
//     final data = await rootBundle.load('assets/tetradaka.riv');
//     final file = RiveFile.import(data);

//     if (file != null) {
//       setState(() {
//         _artboard = file.mainArtboard;
//       });
//     }
//   }

//   _navigateToHome() async {
//     await Future.delayed(Duration(seconds: 3), () {
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (context) => HomeScreen()));
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: _artboard == null
//             ? CircularProgressIndicator() // Если артборд не загружен, показываем индикатор загрузки
//             : Rive(artboard: _artboard),  // Если загружен - показываем Rive анимацию
//       ),
//     );
//   }
// }