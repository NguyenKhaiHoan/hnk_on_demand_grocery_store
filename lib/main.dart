import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:on_demand_grocery_store/firebase_options.dart';
import 'package:on_demand_grocery_store/src/bindings/app_bindings.dart';
import 'package:on_demand_grocery_store/src/constants/app_colors.dart';
import 'package:on_demand_grocery_store/src/repositories/authentication_repository.dart';
import 'package:on_demand_grocery_store/src/routes/app_pages.dart';
import 'package:on_demand_grocery_store/src/utils/theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await GetStorage.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((FirebaseApp value) => Get.put(AuthenticationRepository()));

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );
  runApp(const MyApp());
}

class ScrollBehaviorModified extends ScrollBehavior {
  const ScrollBehaviorModified();
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return const ClampingScrollPhysics();
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        initialBinding: HAppBinding(),
        title: 'On demand Grocery',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const <LocalizationsDelegate<Object>>[
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        supportedLocales: const [Locale('vi')],
        theme: HAppTheme().lightTheme,
        getPages: HAppPages.pages,
        builder: (context, child) => child!,
        home: Scaffold(
            backgroundColor: HAppColor.hWhiteColor,
            body: Center(
                child: Image.asset(
              "assets/logos/grofast_splash.gif",
              gaplessPlayback: true,
              fit: BoxFit.fill,
              height: 400,
              width: 400,
            ))));
  }
}
