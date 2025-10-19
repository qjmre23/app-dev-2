import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/order.dart';
import 'models/user.dart';
import 'providers/app_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart'; // Updated import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(OrderAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: MaterialApp(
        title: 'Smart Toy Store',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // New Professional Color Scheme
          primarySwatch: Colors.deepPurple,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
            secondary: Colors.amber,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 2,
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            selectedItemColor: Colors.deepPurple,
            unselectedItemColor: Colors.grey,
          ),
        ),
        home: Consumer<AppProvider>(
          builder: (context, provider, _) {
            if (provider.currentUser != null) {
              // If logged in, go to the new MainScreen
              return const MainScreen();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
