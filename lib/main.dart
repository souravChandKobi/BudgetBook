import 'dart:developer' show log;
import 'dart:io';

import 'package:budget_book_app/UI/screens/homeScreen.dart';
import 'package:budget_book_app/UI/screens/test.dart';
import 'package:budget_book_app/blocs/auth/auth_bloc.dart';
import 'package:budget_book_app/blocs/auth/auth_repository/auth_repository.dart';
import 'package:budget_book_app/blocs/budgets/budget_bloc.dart';
import 'package:budget_book_app/blocs/budgets/budget_event.dart';
import 'package:budget_book_app/blocs/budgets/models/budget_item.dart';
import 'package:budget_book_app/blocs/budgets/repository/budget_repository.dart';
import 'package:budget_book_app/blocs/sync/sync_repository/sync_repository.dart';
import 'package:budget_book_app/firebase_options.dart';
import 'package:budget_book_app/themes/my_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

@pragma('vm:entry-point')
Future<void> overlayEntryPoint() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Hive.initFlutter();

  final path = await getExternalHivePath();
  Hive.init(path);

  Hive.registerAdapter(BudgetItemAdapter());
  await Hive.openBox<BudgetItem>('itemsBox');
  await Hive.openBox('appSettings');

  const channel = MethodChannel("overlay_channel");

  channel.setMethodCallHandler((call) async {
    final box = Hive.box<BudgetItem>('itemsBox');


    // ======================================================
    // FIXED : ALWAYS SAVE USING item.id AS THE HIVE KEY
    // ======================================================
    if (call.method == "addItemFromOverlay") {
      final data = Map<String, dynamic>.from(call.arguments);

      final id = DateTime.now().millisecondsSinceEpoch.toString();
      // final id = const Uuid().v4();

      final item = BudgetItem(
        id: id,
        name: data["name"],
        quantity: int.parse(data["quantity"]),
        price: int.parse(data["price"]),
        dateTime: DateTime.now(),
        imagePath: "",
        category: data["category"] ?? "Other",
      );

      // Old: box.add(item);  → creates duplicate
      // New (correct):
      await box.put(item.id, item);
      log("from main.dart: item added from OVERLAY  ${item.id} : ${item.name}");

      return {"savedId": item.id};
    }

    if (call.method == "getSuggestions") {
      final latestByName = <String, Map<String, dynamic>>{};

      for (final item in box.values) {
        latestByName[item.name.toLowerCase()] = {
          "name": item.name,
          "quantity": item.quantity,
          "price": item.price,
          "category": item.category,
        };
      }

      return latestByName.values.toList();
    }

    return null;
  });
}

Future<String> getExternalHivePath() async {
  // final dir = await getExternalStorageDirectory();
  // /storage/emulated/0/Android/data/<package>/files
  final hiveDir = Directory(
    "/storage/emulated/0/Android/media/com.kobi.budget_book/hive",
  );

  if (!hiveDir.existsSync()) {
    hiveDir.createSync(recursive: true);
  }

  return hiveDir.path;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2) Initialize Hive (your overlayEntryPoint handles this)
  await overlayEntryPoint();

  // >>> CLEAR NOTIFICATIONS ON APP OPEN
  const MethodChannel("clear_notifications").invokeMethod("clearAll");
  // <<< CLEAR NOTIFICATIONS

  // ------------------ Hive (MINIMUM) ------------------
  // await Hive.initFlutter();
  // await Hive.openBox('appSettings');

  // ------------------ System UI ------------------
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarColor: Colors.transparent,
    ),
  );

  // ------------------ Theme ------------------
  final savedTheme = Hive.box('appSettings').get('themeMode', defaultValue: 1);
  themeNotifier.value = ThemeMode.values[savedTheme];

final box = Hive.box<BudgetItem>('itemsBox');
final settingsBox = Hive.box("appSettings");

final budgetRepository = BudgetRepository(box, settingsBox);
final authRepository = AuthRepository();
final syncRepository = SyncRepository(box);

final user = FirebaseAuth.instance.currentUser;
if (user != null) {
    await syncRepository.initializeCloudSync();
}

runApp(
  MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => BudgetBloc(budgetRepository),
      ),
      BlocProvider(
        create: (_) => AuthBloc(
          authRepository: authRepository,
          syncRepository: syncRepository,
        ),
      ),
    ],
    child: const MyApp(),
  ),
);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: themeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          scaffoldMessengerKey: scaffoldMessengerKey,

          title: 'Budget Book',
          theme: MyAppTheme.lightTheme,
          darkTheme: MyAppTheme.darkTheme,
          themeMode: themeMode,

          home: HomeScreen(),
        );
      },
    );
  }
}
