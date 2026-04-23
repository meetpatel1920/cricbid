import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'bindings/initial_binding.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'core/theme/theme_service.dart';
import 'services/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Init theme before app
  final themeService = Get.put(ThemeService(), permanent: true);

  // Init notification service
  final notifService = Get.put(NotificationService(), permanent: true);
  await notifService.initialize();

  runApp(CricBidApp(themeService: themeService));
}

class CricBidApp extends StatelessWidget {
  final ThemeService themeService;
  const CricBidApp({super.key, required this.themeService});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Obx(() => GetMaterialApp(
              title: 'CricBid',
              debugShowCheckedModeBanner: false,
              theme: themeService.lightTheme,
              darkTheme: themeService.darkTheme,
              themeMode: themeService.themeMode.value,
              initialBinding: InitialBinding(),
              initialRoute: AppRoutes.splash,
              getPages: AppPages.pages,
              defaultTransition: Transition.cupertino,
              transitionDuration: const Duration(milliseconds: 280),
              builder: (context, widget) {
                return MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.noScaling),
                  child: widget!,
                );
              },
            ));
      },
    );
  }
}
