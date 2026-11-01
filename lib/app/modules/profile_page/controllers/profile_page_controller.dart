import 'package:get/get.dart';
import '../../../data/services/auth_service.dart';

class ProfilePageController extends GetxController {
  final AuthService authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    authService.fetchUserProfile();
  }

  void refreshProfile() {
    authService.fetchUserProfile();
  }
}
