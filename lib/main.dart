import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:torch_light/torch_light.dart';
// import 'package:flashlight/flashlight.dart';
import 'package:flutter/services.dart';
// import 'package:torch_controller/torch_controller.dart';
import 'package:camera/camera.dart';
//import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:timer_builder/timer_builder.dart';
import 'package:just_audio/just_audio.dart' as just_audio;
import 'package:audioplayers/audioplayers.dart' as audioplayers;
import 'package:flutter_sound/flutter_sound.dart';
// import 'package:microphone/microphone.dart' as mic;
import 'package:record/record.dart';
// import 'package:flutter_sms/flutter_sms.dart';
// import 'package:sms_maintained/sms.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import "package:latlong2/latlong.dart" as latLng;
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

//Widget listy kontaktow
class ContactListScreen extends StatelessWidget {
  final Iterable<Contact> contacts;

  ContactListScreen(this.contacts);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista kontaktów'),
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          Contact contact = contacts.elementAt(index);
          return ListTile(
            title: Text(contact.displayName ?? ''),
            onTap: () {
              Navigator.pop(context, contact);
            },
          );
        },
      ),
    );
  }
}

// Widget mapy
class MapScreen extends StatelessWidget {
  final double latitude;
  final double longitude;

  MapScreen({required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa 🗺'),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: latLng.LatLng(latitude, longitude),
          zoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 40.0,
                height: 40.0,
                point: latLng.LatLng(latitude, longitude),
                builder: (ctx) => Container(
                  child: Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40.0,
                  ),
                ),
              ),
            ],
          ),
          // Dodaj przycisk do otwierania mapy w aplikacji Google Maps
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () {
                _openMapWithGoogleMapsApp(latitude, longitude);
              },
              child: Container(
                margin: EdgeInsets.all(
                    16.0), // Dodaj margines dla dodatkowego miejsca
                padding: EdgeInsets.all(8.0),
                color: Colors.blue,
                child: Text(
                  'Otwórz w Google Maps',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Funkcja do otwierania mapy w aplikacji Google Maps
  void _openMapWithGoogleMapsApp(double latitude, double longitude) async {
    // String mapUrl = 'google.navigation:q=$latitude,$longitude';
    String mapUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    if (await canLaunch(mapUrl)) {
      await launch(mapUrl);
    } else {
      print('Nie można otworzyć mapy w aplikacji Google Maps');
    }
  }
}

// class MapScreen extends StatelessWidget {
//   final double latitude;
//   final double longitude;

//   MapScreen({required this.latitude, required this.longitude});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Mapa'),
//       ),
//       body: GoogleMap(
//         initialCameraPosition: CameraPosition(
//           target: LatLng(latitude, longitude),
//           zoom: 15.0,
//         ),
//         markers: {
//           Marker(
//             markerId: MarkerId('Your Location'),
//             position: LatLng(latitude, longitude),
//             infoWindow: InfoWindow(title: 'Twoje położenie'),
//           ),
//         },
//       ),
//     );
//   }
// }

class SafePersonalApp extends StatefulWidget {
  final String username;

  SafePersonalApp({required this.username});

  @override
  _SafePersonalAppState createState() => _SafePersonalAppState();
}

class _SafePersonalAppState extends State<SafePersonalApp>
    with SingleTickerProviderStateMixin {
  final Geolocator _geolocator = Geolocator();
  Position? _currentPosition; // Zmieniono na Position?

  //bool isFlashOn = false; // Dodajemy zmienną do śledzenia stanu latarki
  late CameraController _controller;
  late bool _isFlashOn;
  late bool _isRecording;
  late Color _flashButtonColor;
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  // late AudioRecorder _recorder;
  late just_audio.AudioPlayer _player;
  late audioplayers.AudioPlayer _playerAudioplayers;
  // late AudioSource _audioSource;
  late audioplayers.AudioPlayer _audioPlayer;
  // late just_audio.AudioRecorder _recorder;
  late FlutterSoundRecorder _flutterSound;
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  late bool _isPlaying;
  late String _recordingPath;
  late DateTime _startTime;
  Contact? selectedContact; // Zmienna przechowująca wybrany kontakt

  //late Contact? selectedContact; // Zmienna przechowująca wybrany kontakt

  late FlutterSoundRecorder _audioRecorder;
  final recorder = FlutterSoundRecorder();

  // Duration _recordedTime = Duration.zero;
  // Timer? _timer;

  Timer? _timer;

  Duration _recordedTime = Duration(seconds: 0);

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _getCurrentLocation();

    _loadTrustedContact();

    _checkCameraPermission();
    _initCamera();
    _isFlashOn = false;

    _audioRecorder = FlutterSoundRecorder();
    //_initAudio();

    _isRecording = false;
    _flashButtonColor = Colors.grey;
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );

    _colorAnimation = ColorTween(
      begin: Colors.grey,
      end: Colors.yellow,
    ).animate(_animationController);

    _player = just_audio.AudioPlayer();
    // _recorder = just_audio.AudioRecorder();
    // _recorder = AudioRecorder();
    // _audioSource = AudioSource();

    // _audioPlayer = AudioPlayer();
    _isPlaying = false;
    _recordingPath = '';
  }

  // Metoda sprawdzająca i prosząca o uprawnienia lokalizacyjne
  void _checkLocationPermission() async {
    if (await Permission.locationWhenInUse.isDenied) {
      // Jeśli uprawnienie jest odrzucone, poproś o nie ponownie
      await Permission.locationWhenInUse.request();
    }
  }

  // Metoda do pozysania aktualnej lokalizacji
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

  // Metoda do zamiany wpolrzednych na stopnie goograficzne
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

  // funkcja do otwierania mapy w aplikacji google maps
  void openMap(double latitude, double longitude) async {
    String mapUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    if (await canLaunch(mapUrl)) {
      await launch(mapUrl);
    } else {
      print('Nie można otworzyć mapy');
    }
  }

  // funkcja do wczytania danych do mapy
  void _openMapWithCurrentLocation() {
    if (_currentPosition != null) {
      openMap(_currentPosition!.latitude, _currentPosition!.longitude);
    } else {
      print('Brak dostępnej lokalizacji');
    }
  }

  // funkcja do otwierania mapy w nowym widoku
  void openMapScreen(double latitude, double longitude) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          latitude: latitude,
          longitude: longitude,
        ),
      ),
    );
  }

  final TextEditingController _smsController = TextEditingController();
  String defaultSMS = 'To jest przykładowa wiadomość SMS';

  static const platform = const MethodChannel('sms_sender_channel');

  // Future<void> _sendSms() async {
  //   if (selectedContact != null) {
  //     String phoneNumber = selectedContact!.phones!.first.value ?? '';

  //     String message =
  //         _smsController.text.isNotEmpty ? _smsController.text : defaultSMS;

  //     // Pobieranie aktualnych współrzędnych
  //     String latitude = _currentPosition != null
  //         ? getDegreesMinutes(_currentPosition!.latitude, 'latitude')
  //         : 'Brak danych o lokalizacji';
  //     String longitude = _currentPosition != null
  //         ? getDegreesMinutes(_currentPosition!.longitude, 'longitude')
  //         : 'Brak danych o lokalizacji';

  //     // Dołączenie współrzędnych do wiadomości
  //     String fullMessage =
  //         '$message\n\nPotrzebuje wsparcia\nAktualne współrzędne:\nLatitude: $latitude\nLongitude: $longitude';

  //     try {
  //       await platform.invokeMethod('sendSMS', {
  //         'phoneNumber': phoneNumber,
  //         'message': fullMessage,
  //       });
  //       // Wyślij SMS do wybranego kontaktu
  //       _showNotification('SMS został wysłany do $phoneNumber');
  //     } on PlatformException catch (e) {
  //       print('Błąd wysyłania SMS: $e');
  //     }
  //   } else {
  //     _showNotification('Proszę wybrać kontakt przed wysłaniem SMS.');
  //   }
  // }

  Future<void> _sendSms() async {
    if (selectedContact != null) {
      String phoneNumber = selectedContact!.phones!.first.value ?? '';

      // Domyślna wiadomość
      String defaultMessage = 'Potrzebna Pomoc!';

      // Wiadomość wpisana przez użytkownika
      String userMessage = _smsController.text.isNotEmpty
          ? _smsController.text
          : ''; // Lub inna domyślna wartość

      // Pobieranie aktualnych współrzędnych
      String latitude = _currentPosition != null
          ? getDegreesMinutes(_currentPosition!.latitude, 'latitude')
          : 'Brak danych o lokalizacji';
      String longitude = _currentPosition != null
          ? getDegreesMinutes(_currentPosition!.longitude, 'longitude')
          : 'Brak danych o lokalizacji';

      // Link do Google Maps
      String googleMapsLink =
          'https://www.google.com/maps?q=$latitude,$longitude';

      // Pełna wiadomość
      String fullMessage =
          '$defaultMessage\n$userMessage\nPotrzebne wsparcie\nAktualne współrzędne:\nSzerokość: $latitude\nDługość: $longitude\n$googleMapsLink';

      try {
        await platform.invokeMethod('sendSMS', {
          'phoneNumber': phoneNumber,
          'message': fullMessage,
        });

        // Wyślij SMS do wybranego kontaktu
        _showNotification('SMS został wysłany do $phoneNumber');
      } on PlatformException catch (e) {
        print('Błąd wysyłania SMS: $e');
      }
    } else {
      _showNotification('Proszę wybrać kontakt przed wysłaniem SMS.');
    }
  }

  // Future<void> _sendSms() async {
  //   if (selectedContact != null) {
  //     String phoneNumber = selectedContact!.phones!.first.value ?? '';

  //     String message =
  //         _smsController.text.isNotEmpty ? _smsController.text : defaultSMS;

  //     // Pobieranie aktualnych współrzędnych
  //     String latitude = _currentPosition != null
  //         ? getDegreesMinutes(_currentPosition!.latitude, 'latitude')
  //         : 'Brak danych o lokalizacji';
  //     String longitude = _currentPosition != null
  //         ? getDegreesMinutes(_currentPosition!.longitude, 'longitude')
  //         : 'Brak danych o lokalizacji';

  //     // String message = _smsController.text.isNotEmpty
  //     //     ? _smsController.text
  //     //     : defaultSMS +
  //     //         '\nPotrzebne wsparcie\nAktualne współrzędne\nSzerokość: $latitude\nDługość: $longitude';
  //     String fullMessage =
  //         '$message\nPotrzebne wsparcie\nAktualne współrzędne:\nSzerokość: $latitude\nDługość: $longitude';

  //     // Dołączenie współrzędnych do treści wiadomości
  //     // String fullMessage =
  //     //     '$message\n\nPotrzebuje wsparcia\nAktualne wspolrzedne:\nSzerokosc: $latitude\nDlugosc: $longitude';
  //     // print('Message: $message');
  //     // print('Latitude: $latitude');
  //     // print('Longitude: $longitude');
  //     try {
  //       await platform.invokeMethod('sendSMS', {
  //         'phoneNumber': phoneNumber,
  //         'message': fullMessage,
  //         // 'message': message,
  //       });
  //       // Wyślij SMS do wybranego kontaktu
  //       _showNotification('SMS został wysłany do $phoneNumber');
  //     } on PlatformException catch (e) {
  //       print('Błąd wysyłania SMS: $e');
  //     }
  //   } else {
  //     _showNotification('Proszę wybrać kontakt przed wysłaniem SMS.');
  //   }
  // }

  void _showNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  Future<void> _loadTrustedContact() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? contactId = prefs.getString('trustedContactId');

    if (contactId != null) {
      Iterable<Contact>? contacts = await ContactsService.getContacts();
      Contact? trustedContact;

      try {
        trustedContact = contacts?.firstWhere(
          (contact) => contact.identifier == contactId,
        );
      } catch (e) {
        // Obsłuż błąd, np. kontakt nie został znaleziony
        print('Błąd podczas ładowania zaufanego kontaktu: $e');
      }

      setState(() {
        selectedContact = trustedContact;
      });
    }
  }

  Future<void> _saveTrustedContact(String contactId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('trustedContactId', contactId);
  }

  Future<void> _pickContact() async {
    try {
      Iterable<Contact>? contacts = await ContactsService.getContacts();

      Contact? selected = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContactListScreen(contacts!),
        ),
      );

      if (selected != null) {
        await _saveTrustedContact(selected.identifier!);
        setState(() {
          selectedContact = selected;
        });
      }
    } catch (e, stackTrace) {
      print('Wystąpił błąd podczas wybierania kontaktu: $e');
      //print(stackTrace);
    }
  }

  // Future<void> _pickContact() async {
  //   try {
  //     Iterable<Contact>? contacts = await ContactsService.getContacts();

  //     Contact? selected = await Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => ContactListScreen(contacts!),
  //       ),
  //     );

  //     if (selected != null) {
  //       setState(() {
  //         selectedContact = selected;
  //       });
  //     }
  //   } catch (e, stackTrace) {
  //     print('Wystąpił błąd podczas wybierania kontaktu: $e');
  //     print(stackTrace);
  //     // Tutaj możesz dodać logikę obsługi błędu, np. wyświetlenie komunikatu dla użytkownika
  //   }
  // }
  // static const platform =
  //     const MethodChannel('sms_sender_channel'); // Ustawiamy nazwę kanału

  // Future<void> _sendSms() async {
  //   try {
  //     await platform.invokeMethod('sendSMS', {
  //       'phoneNumber': '+48 123 456 789', // Zmień na docelowy numer telefonu
  //       'message': 'To jest wiadomość SMS wysłana z aplikacji Flutter!'
  //     });
  //   } on PlatformException catch (e) {
  //     print('Błąd wysyłania SMS: $e');
  //   }
  // }

  // Future<void> _selectContact() async {
  //   Contact? contact = await showModalBottomSheet<Contact>(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return ContactListPicker(); // Tutaj będzie lista kontaktów do wyboru
  //     },
  //   );

  //   if (contact != null) {
  //     setState(() {
  //       selectedContact = contact;
  //     });
  //   }
  // }

  // Future<void> _sendSms() async {
  //   if (selectedContact != null) {
  //     String phoneNumber = selectedContact!.phones!.first.value ?? '';

  //     try {
  //       SmsSender sender = new SmsSender();
  //       SmsMessage message = new SmsMessage(phoneNumber, messageText);

  //       await sender.sendSms(message);

  //       // Wysłanie wiadomości SMS do wybranego kontaktu
  //     } catch (error) {
  //       print('Błąd wysyłania SMS: $error');
  //     }
  //   } else {
  //     showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text('Brak kontaktu'),
  //           content: Text('Wybierz kontakt przed wysłaniem SMS.'),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: Text('OK'),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }
  // }

  // Metoda do pozyskania uprawnien kamery
  void _checkCameraPermission() async {
    if (await Permission.camera.isDenied) {
      await Permission.camera.request();
    }
  }

  // Metoda do inicjalizacji kamery
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
        _flashButtonColor = _isFlashOn
            ? Colors.yellow
            : Color.fromARGB(255, 225, 225, 225); // Zmiana koloru przycisku
      });
    } catch (e) {
      print("Błąd podczas przełączania latarki: $e");
    }
  }

  Future initRecorder() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }

    // if (recorder.isOpen) {
    //   await recorder.closeAudioSession();
    // }

    await recorder.openRecorder();
  }

  Future record() async {
    if (!recorder.isStopped) {
      return; // Jeśli nagrywanie już trwa, nie uruchamiamy kolejnego
    }

    if (_isRecording) {
      await stop(); // Zatrzymaj bieżące nagrywanie przed rozpoczęciem nowego
    }

    setState(() {
      _recordedTime = Duration(); // Zeruj licznik czasu
    });

    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        _recordedTime = _recordedTime + Duration(seconds: 1);
      });
    });

    // await recorder.startRecorder(toFile: 'audio');
    // Generuj unikalną nazwę pliku na podstawie aktualnego czasu
    DateTime now = DateTime.now();
    String fileName =
        'audio_${now.year}${now.month}${now.day}_${now.hour}${now.minute}${now.second}.m4a';

    try {
      await recorder.startRecorder(
        toFile: fileName,
        codec: Codec.aacMP4,
      );

      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print('Błąd podczas rozpoczynania nagrywania: $e');
      _timer?.cancel();
    }
  }

  Future checkAndRequestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (!status.isGranted) {
        print('Brak uprawnień do zapisu w pamięci zewnętrznej.');
      }
    }
  }

  List<File> recentRecordings = [];

  Future stop() async {
    // Sprawdź i poproś o uprawnienia przed zapisaniem pliku
    await checkAndRequestStoragePermission();

    if (!_isRecording) {
      return; // Jeśli nie nagrywamy, nie ma potrzeby zatrzymywać
    }

    _timer?.cancel(); // Zatrzymaj stoper po zakończeniu nagrywania
    //await recorder.stopRecorder();

    // Pobierz ścieżkę nagrania
    String? path = await recorder.stopRecorder();

    // Pobierz katalog tymczasowy
    //Directory appDocDir = await getTemporaryDirectory();
    // Directory appDocDir = await getApplicationDocumentsDirectory();
    // String appDocPath = appDocDir.path;
    if (path == null) {
      print('Błąd: Ścieżka po zakończeniu nagrywania jest pusta.');
      return;
    }

    Directory? appDocDir = await getExternalStorageDirectory();
    if (appDocDir == null) {
      print('Błąd: Brak dostępu do katalogu zewnętrznego.');
      return;
    }
    String appDocPath = appDocDir.path;

    // Use getExternalStorageDirectory() instead of getApplicationDocumentsDirectory()
    // Directory? appDocDir = await getExternalStorageDirectory();
    // String appDocPath = appDocDir!.path;

    // Katalog "recordings" wewnątrz katalogu dokumentów
    // String recordingsPath = '$appDocPath/Recordings';
    // Katalog "Recordings" wewnątrz katalogu dostępnego publicznie
    // Uzyskaj katalog dostępny publicznie
    Directory? publicDir = await getExternalStorageDirectory();

    if (publicDir == null) {
      print('Błąd: Brak dostępu do katalogu zewnętrznego.');
      return;
    }
    String recordingsPath = '${publicDir.path}/Recordings';

    // Utwórz katalog "Recordings", jeśli nie istnieje
    Directory(recordingsPath).createSync(recursive: true);

    // Utwórz katalog "recordings", jeśli nie istnieje
    Directory(recordingsPath).createSync(recursive: true);

    // Utwórz unikalną nazwę pliku w katalogu "recordings"
    DateTime now = DateTime.now();
    String fileName =
        'audio_${now.year}${now.month}${now.day}_${now.hour}${now.minute}${now.second}.m4a';

    // Przenieś plik nagrania do docelowej lokalizacji (np. katalogu cache)
    File recordedFile = File('$recordingsPath/$fileName'); //appDocDir
    if (await File(path!).exists()) {
      print('Ścieżka przed kopiowaniem: $path');
      await File(path).copy(recordedFile.path);
      print('Ścieżka po kopiowaniu: ${recordedFile.path}');
      // } else {
      //   print('Plik nie istnieje.');
      // }

      // Sprawdź, czy plik faktycznie istnieje po skopiowaniu
      if (await recordedFile.exists()) {
        print('Plik został poprawnie zapisany w: ${recordedFile.path}');
      } else {
        print('Błąd: Plik nie został skopiowany do katalogu dokumentów.');
      }
    } else {
      print('Błąd: Plik źródłowy nie istnieje.');
    }

    try {
      await File(path!).copy(recordedFile.path);
      print('File copied successfully to: ${recordedFile.path}');
      // // Open the file using the open_file plugin
      // OpenFile.open(recordedFile.path);
      // Dodaj nowe nagranie do listy recentRecordings
      setState(() {
        recentRecordings.insert(0, recordedFile);
        if (recentRecordings.length > 5) {
          recentRecordings
              .removeLast(); // Usuń najstarsze nagranie, jeśli jest więcej niż 5
        }
      });

      // Otwórz ekran "music" po zakończeniu nagrywania
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MusicScreen(
            recentRecordings: recentRecordings
                .map((file) => file.path)
                .toList(), // Konwersja na List<String>
          ),
        ),
      );
    } catch (e) {
      print('Error copying file: $e');
    }

    setState(() {
      _isRecording = false;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    //_flutterSound.closeAudioSession();
    recorder.closeRecorder();
    _smsController.dispose();
    _timer?.cancel();

    super.dispose();
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
            // InkWell(
            //   onTap: () {
            //     _openMapWithCurrentLocation();
            //   },
            //   child: Container(
            //     height: 100.0,
            //     decoration: BoxDecoration(
            //       border: Border.all(),
            //       borderRadius: BorderRadius.circular(8.0),
            //     ),
            //     child: Column(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: [
            //         Text(
            //           'Twoje położenie',
            //           style: TextStyle(fontSize: 16.0),
            //         ),
            //         SizedBox(height: 8.0),
            //         _currentPosition != null
            //             ? Column(
            //                 children: [
            //                   // Text(
            //                   //   'Szerokość: ${_currentPosition!.latitude}',
            //                   // ),
            //                   Text(
            //                     'Szerokość: ${getDegreesMinutes(_currentPosition!.latitude, 'latitude')}',
            //                   ),
            //                   // Text(
            //                   //   'Długość: ${_currentPosition!.longitude}',
            //                   // ),
            //                   Text(
            //                     'Długość: ${getDegreesMinutes(_currentPosition!.longitude, 'longitude')}',
            //                   ),
            //                 ],
            //               )
            //             : CircularProgressIndicator(),
            //         SizedBox(height: 8.0),
            //         Text(
            //           'Kliknij, by zobaczyć mapę',
            //           style: TextStyle(fontSize: 12.0),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),

            InkWell(
              onTap: () {
                if (_currentPosition != null) {
                  openMapScreen(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                  );
                } else {
                  print('Brak dostępnej lokalizacji');
                }
              },
              child: Container(
                height: 100.0,
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Twoje położenie 🌍',
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
                    SizedBox(height: 8.0),
                    Text(
                      'Kliknij, by zobaczyć mapę',
                      style: TextStyle(fontSize: 12.0),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16.0),

            ButtonBar(
              alignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _sendSms(),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    onPrimary: Colors.white,
                    padding:
                        EdgeInsets.symmetric(horizontal: 64.0, vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text('Wyślij SMS'),
                ),
              ],
            ),

            SizedBox(height: 16.0),
            TextField(
              controller: _smsController,
              decoration: InputDecoration(
                hintText: 'Wpisz wiadomość SMS...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (selectedContact != null)
                  Expanded(
                    child: Container(
                      margin:
                          EdgeInsets.only(left: 8.0), // margines z lewej strony
                      child: Text(
                        'Zaufany kontakt: ${selectedContact!.displayName ?? ''}',
                        style: TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                ElevatedButton(
                  onPressed: _pickContact,
                  child: Text('Zmień kontakt'),
                ),
              ],
            ),

            SizedBox(height: 8.0),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color.fromARGB(255, 0, 0, 0)!, // Kolor obramówki
                  width: 1.0, // Szerokość obramówki
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      'Szybkie akcje 🚨',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            _toggleFlashlight();
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedContainer(
                                padding: EdgeInsets.symmetric(vertical: 24.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  gradient: _isFlashOn
                                      ? LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [Colors.yellow, Colors.amber],
                                        )
                                      : null,
                                  color: _flashButtonColor,
                                ),
                                duration: Duration(milliseconds: 300),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.flashlight_on,
                                      color: Colors.black,
                                    ),
                                    SizedBox(width: 8.0),
                                    Text(
                                      'Latarka',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_isFlashOn)
                                Positioned(
                                  bottom: 0,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4.0, horizontal: 8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(8.0),
                                        bottomRight: Radius.circular(8.0),
                                      ),
                                    ),
                                    child: Text(
                                      'włączona',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          style: ButtonStyle(
                            overlayColor:
                                MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                                return states.contains(MaterialState.pressed)
                                    ? Colors.transparent
                                    : null;
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            try {
                              await initRecorder(); // Inicjalizacja przed rozpoczęciem nagrywania

                              if (recorder.isRecording) {
                                await stop();
                              } else {
                                await record();
                              }
                            } catch (e) {
                              print(
                                  'Error: $e'); // Obsługa błędu inicjalizacji rekordera
                            }
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedContainer(
                                padding: EdgeInsets.symmetric(
                                    vertical: 22.0, horizontal: 24.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  color:
                                      _isRecording ? Colors.red : Colors.orange,
                                ),
                                duration: Duration(milliseconds: 300),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.mic,
                                      color: Colors.black,
                                    ),
                                    // SizedBox(height: 8.0),
                                    Text(
                                      _isRecording ? 'Nagrywanie' : 'Nagraj',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (_isRecording) SizedBox(height: 4.0),
                                    if (_isRecording)
                                      Text(
                                        '${_recordedTime.inHours.toString().padLeft(2, '0')}:${(_recordedTime.inMinutes % 60).toString().padLeft(2, '0')}:${(_recordedTime.inSeconds % 60).toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (_isRecording)
                                Positioned(
                                  bottom: 0,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4.0, horizontal: 8.0),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(8.0),
                                        bottomRight: Radius.circular(8.0),
                                      ),
                                    ),
                                    child: Text(
                                      'włączone',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          style: ButtonStyle(
                            overlayColor:
                                MaterialStateProperty.resolveWith<Color?>(
                              (Set<MaterialState> states) {
                                return states.contains(MaterialState.pressed)
                                    ? Colors.transparent
                                    : null;
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MusicScreen(
                      recentRecordings: recentRecordings
                          .map((file) => file.path)
                          .toList(), // Konwersja na List<String>
                    ),
                  ),
                );
              },
              child: Text('Ostatnie nagrania'),
            ),
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

class MusicScreen extends StatefulWidget {
  final List<String> recentRecordings;

  MusicScreen({required this.recentRecordings});

  @override
  _MusicScreenState createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  late just_audio.AudioPlayer _audioPlayer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = just_audio.AudioPlayer();
    _initPlayer();
  }

  // Future<void> _initPlayer() async {
  //   await _audioPlayer.setFilePath(widget.recentRecordings[_currentIndex]);

  //   _audioPlayer.positionStream.listen((Duration position) {
  //     setState(() {
  //       // Update UI with the current playback position
  //     });
  //   });

  //   _audioPlayer.durationStream.listen((Duration? duration) {
  //     setState(() {
  //       // Update UI with the current duration
  //     });
  //   });
  // }
  Future<void> _initPlayer() async {
    if (widget.recentRecordings.isNotEmpty) {
      await _audioPlayer.setFilePath(widget.recentRecordings[_currentIndex]);

      _audioPlayer.positionStream.listen((Duration position) {
        setState(() {});
      });

      _audioPlayer.durationStream.listen((Duration? duration) {
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playPause() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  Future<void> _stop() async {
    await _audioPlayer.stop();
  }

  Future<void> _previous() async {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      await _audioPlayer.setFilePath(widget.recentRecordings[_currentIndex]);
      await _audioPlayer.play();
    }
  }

  Future<void> _next() async {
    if (_currentIndex < widget.recentRecordings.length - 1) {
      setState(() {
        _currentIndex++;
      });
      await _audioPlayer.setFilePath(widget.recentRecordings[_currentIndex]);
      await _audioPlayer.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recent Recordings'),
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.recentRecordings.isNotEmpty
                ? ListView.builder(
                    itemCount: widget.recentRecordings.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('Recording ${index + 1}'),
                        onTap: () async {
                          await _audioPlayer.stop();
                          setState(() {
                            _currentIndex = index;
                          });
                          await _audioPlayer.setFilePath(
                              widget.recentRecordings[_currentIndex]);
                          await _audioPlayer.play();
                        },
                      );
                    },
                  )
                : Center(
                    child: Text(
                      'Brak aktualnych nagran',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
          ),
          if (widget.recentRecordings.isNotEmpty)
            Container(
              color: Colors.black,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        Text(
                          'Now Playing: ${widget.recentRecordings[_currentIndex]}',
                          style: TextStyle(color: Colors.white),
                        ),
                        StreamBuilder<Duration?>(
                          stream: _audioPlayer.positionStream,
                          builder: (context, snapshot) {
                            final position = snapshot.data ?? Duration.zero;
                            return Text(
                              '${_audioPlayer.position.inMinutes}:${(_audioPlayer.position.inSeconds % 60).toString().padLeft(2, '0')} / ${_audioPlayer.duration != null ? _audioPlayer.duration!.inMinutes : 0}:${(_audioPlayer.duration != null ? _audioPlayer.duration!.inSeconds % 60 : 0).toString().padLeft(2, '0')}',
                              style: TextStyle(color: Colors.white),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Slider(
                    value: _audioPlayer.position.inSeconds.toDouble(),
                    max: _audioPlayer.duration?.inSeconds.toDouble() ?? 0,
                    onChanged: (value) {
                      _audioPlayer.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.skip_previous),
                        onPressed: _previous,
                        color: Colors.white,
                      ),
                      IconButton(
                        icon: Icon(
                          _audioPlayer.playing ? Icons.pause : Icons.play_arrow,
                        ),
                        onPressed: _playPause,
                        color: Colors.white,
                        iconSize: 36.0,
                      ),
                      IconButton(
                        icon: Icon(Icons.stop),
                        onPressed: _stop,
                        color: Colors.white,
                      ),
                      IconButton(
                        icon: Icon(Icons.skip_next),
                        onPressed: _next,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
