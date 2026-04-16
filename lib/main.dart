import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'app/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/theme_controller.dart';
import 'core/utils/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // System UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Theme controller (needs to be before GetMaterialApp)
  final themeCtrl = Get.put(ThemeController(), permanent: true);

  // Notification service
  final notifService = Get.put(NotificationService(), permanent: true);
  await notifService.initialize();

  runApp(CricBidApp(themeCtrl: themeCtrl));
}

class CricBidApp extends StatelessWidget {
  final ThemeController themeCtrl;
  const CricBidApp({super.key, required this.themeCtrl});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 14 base
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Obx(() => GetMaterialApp(
              title: 'CricBid',
              debugShowCheckedModeBanner: false,
              theme: themeCtrl.lightTheme,
              darkTheme: themeCtrl.darkTheme,
              themeMode: themeCtrl.themeMode.value,
              initialBinding: InitialBinding(),
              initialRoute: AppRoutes.splash,
              getPages: AppPages.pages,
              defaultTransition: Transition.cupertino,
              transitionDuration: const Duration(milliseconds: 250),
              builder: (context, widget) {
                // Ensure text scale doesn't go crazy on system settings
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
                  child: widget!,
                );
              },
            ));
      },
    );
  }
}
