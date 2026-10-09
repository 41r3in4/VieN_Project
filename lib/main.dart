import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/main_container_screen.dart';
import 'screens/map_screen.dart';
import 'services/local_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localService = LocalService();
  await localService.init();
  runApp(MyApp(localService: localService));
}

class MyApp extends StatefulWidget {
  final LocalService localService;

  const MyApp({super.key, required this.localService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<bool> _isLoggedInFuture;

  @override
  void initState() {
    super.initState();
    _isLoggedInFuture = widget.localService.isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VieN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF9F6F0),
      ),
      home: FutureBuilder<bool>(
        future: _isLoggedInFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Colors.deepOrange),
              ),
            );
          }

          if (snapshot.hasData && snapshot.data == true) {
            return MapScreen(localService: widget.localService);
          }

          return LoginScreen(localService: widget.localService);
        },
      ),
    );
  }
}
