import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fraccionamiento/models/user_model.dart';
import 'package:fraccionamiento/services/google_auth_service.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find<AuthController>();

  final googleService = GoogleAuthService();

  Rx<UserModel> user = UserModel.empty().obs;

  bool get isLoggedIn => user.value.uid.isNotEmpty;

  @override
  void onInit() {
    super.onInit();

    // 🔄 Escucha permanente del estado de FirebaseAuth
    FirebaseAuth.instance.authStateChanges().listen((firebaseUser) {
      if (firebaseUser == null) {
        // No hay usuario logueado
        user.value = UserModel.empty();
      } else {
        // Hay usuario (incluye cuando se restaura sesión al abrir app)
        setFromFirebase(firebaseUser);
      }
    });
  }

  /// Rellena tu UserModel a partir del usuario de Firebase
  void setFromFirebase(User firebaseUser) {
    user.value = UserModel(
      uid: firebaseUser.uid,
      name: firebaseUser.displayName ?? "",
      email: firebaseUser.email ?? "",
      photoUrl: firebaseUser.photoURL ?? "",
    );
  }

  /// Login manual con Google (desde tu botón)
  Future<void> loginWithGoogle() async {
    final credential = await googleService.signInWithGoogle();
    if (credential == null) return;

    final firebaseUser = credential.user;
    if (firebaseUser == null) return;

    setFromFirebase(firebaseUser);
  }

  Future<void> logout() async {
    // Cierra sesión en Google + Firebase
    await googleService.signOut();
    await FirebaseAuth.instance.signOut();
    user.value = UserModel.empty();
  }
}
