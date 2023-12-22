import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:torch_light/torch_light.dart';
// import 'package:flashlight/flashlight.dart';
import 'package:flutter/services.dart';
// import 'package:torch_controller/torch_controller.dart';
import 'package:camera/camera.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bezpieczeństwo Personalne',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String _username = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logowanie'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Nazwa użytkownika',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Hasło',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                // Logika uwierzytelniania
                String username = _usernameController.text;
                String password = _passwordController.text;

                // Przykładowa walidacja loginu i hasła
                if (username == 'rat' && password == 'sos') {
                  setState(() {
                    _username =
                        username; // Przypisanie nazwy użytkownika po zalogowaniu
                  });

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SafePersonalApp(username: _username),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Błędny login lub hasło.'),
                    ),
                  );
                }
              },
              child: Text('Zaloguj się'),
            ),
          ],
        ),
      ),
    );
  }
}

class SafePersonalApp extends StatefulWidget {
  final String username;

  SafePersonalApp({required this.username});

  @override
  _SafePersonalAppState createState() => _SafePersonalAppState();
}

class _SafePersonalAppState extends State<SafePersonalApp> {
  final Geolocator _geolocator = Geolocator();
  Position? _currentPosition; // Zmieniono na Position?

  //bool isFlashOn = false; // Dodajemy zmienną do śledzenia stanu latarki
  late CameraController _controller;
  late bool _isFlashOn;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _getCurrentLocation();

    _checkCameraPermission();
    _initCamera();
    _isFlashOn = false;
  }

  // Metoda sprawdzająca i prosząca o uprawnienia lokalizacyjne
  void _checkLocationPermission() async {
    if (await Permission.locationWhenInUse.isDenied) {
      // Jeśli uprawnienie jest odrzucone, poproś o nie ponownie
      await Permission.locationWhenInUse.request();
    }
  }

  void _getCurrentLocation() async {
    try {
      Position? position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation, // zmieniono z best
      );
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print('Wystąpił błąd: $e');
    }
  }

  String getDegreesMinutes(double value, String type) {
    String direction = '';
    if (type == 'latitude') {
      direction = value >= 0 ? 'N' : 'S';
    } else {
      direction = value >= 0 ? 'E' : 'W';
    }

    value = value.abs();
    int degrees = value.floor();
    double minutes = (value - degrees) * 60;

    return '$degrees° ${minutes.toStringAsFixed(2)}\' $direction';
  }

  // // Nowa metoda do obsługi latarki
  // void _toggleFlashlight() {
  //   setState(() {
  //     isFlashOn = !isFlashOn;
  //   });

  //   if (isFlashOn) {
  //     // Włącz latarkę
  //     TorchLight.turnOn();
  //   } else {
  //     // Wyłącz latarkę
  //     TorchLight.turnOff();
  //   }
  // }

  // void _toggleFlashlight() {
  //   setState(() {
  //     isFlashOn = !isFlashOn;
  //   });

  //   if (isFlashOn) {
  //     _turnOnFlashlight();
  //   } else {
  //     _turnOffFlashlight();
  //   }
  // }

  // // Metoda do włączania latarki
  // void _turnOnFlashlight() {
  //   const platform = MethodChannel('samples.flutter.dev/flashlight');
  //   try {
  //     platform.invokeMethod('turnOn');
  //   } on PlatformException catch (e) {
  //     print("Błąd podczas włączania latarki: $e");
  //   }
  // }

  // // Metoda do wyłączania latarki
  // void _turnOffFlashlight() {
  //   const platform = MethodChannel('samples.flutter.dev/flashlight');
  //   try {
  //     platform.invokeMethod('turnOff');
  //   } on PlatformException catch (e) {
  //     print("Błąd podczas wyłączania latarki: $e");
  //   }
  // }

  void _checkCameraPermission() async {
    if (await Permission.camera.isDenied) {
      await Permission.camera.request();
    }
  }

  void _initCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.low,
      enableAudio: false,
    );

    await _controller.initialize();
  }

  // Metoda do obsługi latarki
  void _toggleFlashlight() async {
    if (!_controller.value.isInitialized) {
      return;
    }

    try {
      await _controller.setFlashMode(
        _isFlashOn ? FlashMode.off : FlashMode.torch,
      );
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      print("Błąd podczas przełączania latarki: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bezpieczeństwo Personalne'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                'Nazwa użytkownika: ${widget.username}',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16.0),
            Container(
              height: 100.0,
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Twoje położenie',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  SizedBox(height: 8.0),
                  _currentPosition != null
                      ? Column(
                          children: [
                            // Text(
                            //   'Szerokość: ${_currentPosition!.latitude}',
                            // ),
                            Text(
                              'Szerokość: ${getDegreesMinutes(_currentPosition!.latitude, 'latitude')}',
                            ),
                            // Text(
                            //   'Długość: ${_currentPosition!.longitude}',
                            // ),
                            Text(
                              'Długość: ${getDegreesMinutes(_currentPosition!.longitude, 'longitude')}',
                            ),
                          ],
                        )
                      : CircularProgressIndicator(),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Implementacja wysyłania SMS-a
              },
              child: Text('Wyślij SMS'),
            ),
            SizedBox(height: 8.0),
            TextField(
              decoration: InputDecoration(
                hintText: 'Wpisz wiadomość SMS...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Wywołanie funkcji włączającej lub wyłączającej latarkę
                _toggleFlashlight();
              },
              child: Text('Latarka'),
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     ElevatedButton(
            //       onPressed: _toggleFlashlight,
            //       style: ElevatedButton.styleFrom(
            //         primary: isFlashOn ? Colors.yellow : Colors.grey,
            //       ),
            //       child: Text('Latarka'),
            //     ),
            //     ElevatedButton(
            //       onPressed: _toggleRecording,
            //       style: ElevatedButton.styleFrom(
            //         primary: isRecording ? Colors.red : Colors.grey,
            //       ),
            //       child: Text('Nagrywanie'),
            //     ),
            //   ],
            // ),
            SizedBox(height: 16.0),
            // Odtwarzacz dźwięku
            // Tutaj można dodać widgety do odtwarzania dźwięku
            // Przycisk "Wyloguj się"
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              },
              child: Text('Wyloguj się'),
            ),
          ],
        ),
      ),
    );
  }
}
