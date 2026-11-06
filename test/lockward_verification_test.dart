import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lockward/app/data/models/vault_item.dart';
import 'package:lockward/app/data/services/auth_service.dart';
import 'package:lockward/app/data/services/screen_security_service.dart';
import 'package:lockward/app/data/services/session_security_service.dart';
import 'package:lockward/app/data/services/vault_service.dart';
import 'package:lockward/app/modules/home/views/password_details_view.dart';
import 'package:lockward/app/routes/app_pages.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Screen Security Service Tests', () {
    test('ScreenSecurityService.setSecureMode executes safely without unhandled exception', () async {
      final result = await ScreenSecurityService.setSecureMode(true);
      expect(result, isNotNull);
    });
  });

  group('Clipboard Auto-Purge (TC-04) Tests', () {
    testWidgets('copyPassword copies text and auto-purges after 30 seconds', (WidgetTester tester) async {
      String clipboardContent = '';
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (MethodCall methodCall) async {
        if (methodCall.method == 'Clipboard.setData') {
          final Map<dynamic, dynamic>? args = methodCall.arguments as Map<dynamic, dynamic>?;
          clipboardContent = args?['text'] as String? ?? '';
          return null;
        } else if (methodCall.method == 'Clipboard.getData') {
          return {'text': clipboardContent};
        }
        return null;
      });

      Get.testMode = true;
      final vaultService = VaultService();

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  vaultService.copyPassword('MySuperSecretPassword123!', title: 'TestSite');
                },
                child: const Text('Copy'),
              ),
            ),
          ),
        ),
      );

      // 1. User taps "Copy"
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verify copied immediately
      expect(clipboardContent, 'MySuperSecretPassword123!');

      // Let initial snackbar display settle
      await tester.pump(const Duration(seconds: 4));

      // 2. Advance time past 30 seconds total (timer fires)
      await tester.pump(const Duration(seconds: 28));

      // 3. Verify clipboard is automatically purged clean (TC-04 pass!)
      expect(clipboardContent, '');

      // Let purge snackbar finish so all timers settle
      await tester.pumpAndSettle(const Duration(seconds: 5));

      vaultService.onClose();
      Get.reset();
    });
  });

  group('Password Details 30-Second Auto-Masking Tests', () {
    testWidgets('Password visibility reveals and auto-masks back to bullet points after 30 seconds', (WidgetTester tester) async {
      Get.testMode = true;
      final vaultService = Get.put(VaultService());

      final testItem = VaultItem(
        id: 'item_101',
        name: 'GitHub',
        username: 'octocat',
        password: 'SuperSecretGitHubPassword123!',
        category: 'Work',
        link: 'https://github.com',
        securityStatus: SecurityStatus.safe,
        brandColor: Colors.black,
        iconLetter: 'G',
      );
      vaultService.items.add(testItem);

      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/',
          getPages: [
            GetPage(name: '/', page: () => const Scaffold(body: Text('Home'))),
          ],
        ),
      );

      // Navigate to PasswordDetailsView passing the vault item argument
      Get.to(() => const PasswordDetailsView(), arguments: testItem);
      await tester.pumpAndSettle();

      // 1. Initially password must be masked with bullet points
      expect(find.text('••••••••••••'), findsOneWidget);
      expect(find.text('SuperSecretGitHubPassword123!'), findsNothing);

      // 2. Tap the eye reveal icon
      final revealIcon = find.byIcon(Icons.visibility_outlined);
      expect(revealIcon, findsOneWidget);
      await tester.tap(revealIcon);
      await tester.pump();

      // Password should now be in plaintext
      expect(find.text('SuperSecretGitHubPassword123!'), findsOneWidget);
      expect(find.text('••••••••••••'), findsNothing);

      // 3. Advance time by 30 seconds for shoulder-surfing auto-mask
      await tester.pump(const Duration(seconds: 30));

      // Password should revert automatically to bullet points
      expect(find.text('••••••••••••'), findsOneWidget);
      expect(find.text('SuperSecretGitHubPassword123!'), findsNothing);

      // Settle any snackbars before finishing
      await tester.pumpAndSettle(const Duration(seconds: 5));

      vaultService.onClose();
      Get.reset();
    });
  });

  group('Session Inactivity & Background Auto-Lock Tests', () {
    testWidgets('Inactivity timer automatically locks after 30s, rejects incorrect password, and unlocks with correct password', (WidgetTester tester) async {
      Get.testMode = true;
      Get.put(AuthService());
      Get.put(VaultService());
      final sessionService = Get.put(SessionSecurityService());

      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/home',
          getPages: AppPages.routes,
        ),
      );

      expect(sessionService.isLocked.value, false);

      // 1. Advance time by 30 seconds of simulated inactivity while in foreground
      await tester.pump(const Duration(seconds: 30));
      await tester.pumpAndSettle();

      // 2. Verify vault automatically locked and transitioned to VaultLockView
      expect(sessionService.isLocked.value, true);
      expect(find.text('Vault Locked'), findsOneWidget);

      // Anti-bypass test: PopScope must strictly disallow back navigation
      final popScope = tester.widget<PopScope>(find.byType(PopScope));
      expect(popScope.canPop, false);

      // 3. Attempt unlock with wrong password
      await tester.enterText(find.byType(TextField), 'wrongPassword999');
      await tester.tap(find.text('Unlock Vault'));
      await tester.pumpAndSettle();

      // Verify wrong password rejected and vault remains locked
      expect(find.text('Incorrect password. Please try again.'), findsOneWidget);
      expect(sessionService.isLocked.value, true);

      // 4. Enter correct master/account password
      await tester.enterText(find.byType(TextField), 'testPassword123');
      await tester.tap(find.text('Unlock Vault'));
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Verify vault successfully unlocked
      expect(sessionService.isLocked.value, false);

      sessionService.onClose();
      Get.reset();
    });

    testWidgets('Touch watchdog resets inactivity timer preventing premature lock', (WidgetTester tester) async {
      Get.testMode = true;
      Get.put(AuthService());
      Get.put(VaultService());
      final sessionService = Get.put(SessionSecurityService());

      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/home',
          getPages: AppPages.routes,
        ),
      );

      expect(sessionService.isLocked.value, false);

      // 1. Advance 20 seconds (not yet 30s)
      await tester.pump(const Duration(seconds: 20));
      expect(sessionService.isLocked.value, false);

      // 2. User touches the screen (touch watchdog resets timer)
      sessionService.recordUserActivity();

      // 3. Advance another 20 seconds (total 40s elapsed, but only 20s since last touch)
      await tester.pump(const Duration(seconds: 20));
      expect(sessionService.isLocked.value, false); // Must STILL be unlocked!

      // 4. Now let 30 consecutive seconds elapse with zero touches
      await tester.pump(const Duration(seconds: 30));
      await tester.pumpAndSettle();

      // Now it must lock
      expect(sessionService.isLocked.value, true);
      expect(find.text('Vault Locked'), findsOneWidget);

      sessionService.onClose();
      Get.reset();
    });

    test('Background lifecycle transition triggers lock when elapsed duration >= timeout', () async {
      Get.testMode = true;
      Get.put(AuthService());
      Get.put(VaultService());
      final sessionService = Get.put(SessionSecurityService());
      sessionService.setAutoLockTimeout(1); // 1 second test threshold

      // App minimized to background
      sessionService.didChangeAppLifecycleState(AppLifecycleState.paused);

      // Wait 2 seconds past the threshold
      await Future.delayed(const Duration(seconds: 2));

      // App resumed
      sessionService.didChangeAppLifecycleState(AppLifecycleState.resumed);

      // Verify locked immediately upon return
      expect(sessionService.isLocked.value, true);

      sessionService.onClose();
      Get.reset();
    });
  });

  group('Route & Page Integrity Check', () {
    test('All application routes are defined and valid', () {
      expect(AppPages.routes.isNotEmpty, true);
      for (final page in AppPages.routes) {
        expect(page.name.isNotEmpty, true);
        expect(page.page, isNotNull);
      }
    });

    test('Verify total configured application pages', () {
      expect(AppPages.routes.length, greaterThanOrEqualTo(11));
    });
  });
}
