import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/temperature_provider.dart';
import 'presentation/providers/location_provider.dart';
import 'presentation/providers/inventory_provider.dart';
import 'presentation/screens/dashboard_screen.dart';

void main() {
  runApp(const ColdStorageApp());
}

class ColdStorageApp extends StatelessWidget {
  const ColdStorageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TemperatureProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(
            create: (_) =>
                InventoryProvider(locationProvider: LocationProvider()))
      ],
      child: MaterialApp(
        title: 'Technical Test',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 2,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        home: const DashboardScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
