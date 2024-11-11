import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importa Firebase Auth
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'auth_services.dart'; // Importa el archivo de servicios de autenticación
import 'task_board_page.dart'; // Importa el archivo de TaskBoardPage
import 'create_project_page.dart';

// Configuración de Firebase para la web
const firebaseConfig = {
  'apiKey': "AIzaSyA7FcE9MQW-HoGh9JViVUl85FbfpL-rm_A",
  'authDomain': "focus-35f20.firebaseapp.com",
  'projectId': "focus-35f20",
  'storageBucket': "focus-35f20.appspot.com",
  'messagingSenderId': "788312826114",
  'appId': "1:788312826114:web:1f85ea3c008ddf3ec0221b",
  'measurementId': "G-HBY7MT5X06"
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: firebaseConfig['apiKey'] as String,
      authDomain: firebaseConfig['authDomain'] as String,
      projectId: firebaseConfig['projectId'] as String,
      storageBucket: firebaseConfig['storageBucket'] as String,
      messagingSenderId: firebaseConfig['messagingSenderId'] as String,
      appId: firebaseConfig['appId'] as String,
      measurementId: firebaseConfig['measurementId'] as String,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Esperar 5 segundos antes de verificar el estado de autenticación
    Future.delayed(const Duration(seconds: 1), () {
      _checkAuthState();
    });
  }

  Future<void> _checkAuthState() async {
    final authService = AuthService();
    
    // Esperar 5 segundos para mostrar el splash
    await Future.delayed(const Duration(seconds: 1));
    
    // Verificar si hay una sesión activa
    final currentUser = await authService.getCurrentUser();
    
    if (!mounted) return;

    if (currentUser != null) {
      // Usuario ya está autenticado, ir directamente a TaskBoard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TaskBoardPage(user: currentUser),
        ),
      );
    } else {
      // No hay sesión activa, ir a la página de login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Focus.',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'una app de ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[300],
                    ),
                  ),
                  Image.asset(
                    'assets/ltm.png',
                    height: 40,
                    width: 40,
                  ),
                  Text(
                    ' T-ecogroup',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Focus.',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                SizedBox(height: 8),
                SignInButton(
                  Buttons.Google,
                  onPressed: () async {
                    if (_isLoading) return; // Evita múltiples clics
                    setState(() {
                      _isLoading = true;
                    });
                    print('Iniciando el proceso de inicio de sesión con Google...');
                    try {
                      final user = await authService.signInWithGoogle();
                      if (user != null) {
                        print('Inicio de sesión exitoso: ${user.email}');
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => TaskBoardPage(user: user)),
                        );
                      } else {
                        print('No se pudo iniciar sesión, el usuario es nulo.');
                      }
                    } catch (e) {
                      print('Error durante el inicio de sesión: $e');
                    } finally {
                      // Solo llama a setState aquí si no se ha completado el Future
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: const Center(
        child: Text('Bienvenido a la página de inicio'),
      ),
    );
  }
}
