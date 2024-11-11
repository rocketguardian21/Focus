import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signInWithGoogle() async {
    try {
      print('Iniciando el proceso de inicio de sesión con Google...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('El usuario canceló el inicio de sesión.');
        return null; // El usuario canceló el inicio de sesión
      }
      print('Usuario autenticado: ${googleUser.email}');

      final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        print('Inicio de sesión exitoso: ${user.email}');
        // Verificar si el usuario existe en la base de datos
        final userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          await _createNewUser(user);
        }

        // Aquí puedes llamar a la imagen del usuario
        String? photoUrl = user?.photoURL; // Obtener la URL de la foto del usuario
        if (photoUrl != null) {
          // Aquí puedes usar la URL para mostrar la imagen
          // ... código para mostrar la imagen ...
        } else {
          print('No se encontró la URL de la foto del usuario.');
        }

        return user;
      } else {
        print('No se pudo iniciar sesión, el usuario es nulo.');
      }
    } catch (e) {
      print('Error durante el inicio de sesión: $e');
    }
    return null;
  }

  Future<void> _createNewUser(User user) async {
    try {
      // Asegurarse de que tenemos una URL de foto válida
      String? photoURL = user.photoURL;
      if (photoURL == null || photoURL.isEmpty) {
        photoURL = 'https://ui-avatars.com/api/?name=${user.displayName}&background=0D8ABC&color=fff';
      }

      print('Creando nuevo usuario en Firestore...');
      await _firestore.collection('users').doc(user.uid).set({
        'displayName': user.displayName,
        'email': user.email,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });

      // Inicializar documentos adicionales para el nuevo usuario
      await _firestore.collection('userProjects').doc(user.uid).set({
        'projects': [],
      });

      await _firestore.collection('userTasks').doc(user.uid).set({
        'tasks': [],
      });

      await _firestore.collection('taskSummaries').doc(user.uid).set({
        'totalTasks': 0,
        'pendingTasks': 0,
        'myTasks': 0,
        'assignedTasks': 0,
        'inProgressTasks': 0,
        'completedTasks': 0,
        'overdueTasks': 0,
      });
      print('Nuevo usuario creado exitosamente en Firestore.');
    } catch (e) {
      print('Error al crear nuevo usuario: $e');
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        print('Usuario actual encontrado: ${user.email}');
        // Verificar si el token de Google aún es válido
        final googleSignInAccount = await _googleSignIn.signInSilently();
        if (googleSignInAccount != null) {
          print('Token de Google válido, verificando usuario en Firestore...');
          // Verificar si el usuario existe en Firestore
          final userDoc = await _firestore.collection('users').doc(user.uid).get();
          if (userDoc.exists) {
            print('El usuario existe en Firestore.');
            if (user.photoURL != userDoc.data()?['photoURL']) {
              print('Actualizando URL de foto del usuario en Firestore...');
              await _firestore.collection('users').doc(user.uid).update({
                'photoURL': user.photoURL,
                'lastLogin': FieldValue.serverTimestamp(),
              });
            }
          } else {
            print('El usuario no existe en Firestore, creando nuevo usuario...');
            await _createNewUser(user);
          }
          return user;
        } else {
          print('Token expirado, cerrando sesión...');
          await signOut();
          return null;
        }
      }
      print('No hay usuario actual.');
      return null;
    } catch (e) {
      print('Error en getCurrentUser: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    print('Cerrando sesión...');
    await _auth.signOut();
    await _googleSignIn.signOut();
    print('Sesión cerrada.');
  }

  Future<String?> getUserProfileImage() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        final response = await http.get(
          Uri.parse('https://people.googleapis.com/v1/people/me?personFields=photos'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['photos'] != null && data['photos'].isNotEmpty) {
            return data['photos'][0]['url']; // Retorna la URL de la foto
          }
        } else {
          print('Error al obtener la imagen de perfil: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error al obtener la imagen de perfil: $e');
    }
    return null; // Retorna null si no se pudo obtener la imagen
  }
}
