// ABOUTME: Application entry point with Riverpod provider scope and database initialization
// ABOUTME: Sets up bottom navigation for fuel entries, price chart, and efficiency chart screens

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/database/sqflite_database_service.dart';
import 'core/theme/app_theme.dart';
import 'features/fuel_entries/data/datasources/fuel_entry_local_datasource.dart';
import 'features/fuel_entries/presentation/providers/fuel_entry_providers.dart';
import 'features/fuel_entries/presentation/screens/fuel_entry_list_screen.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'features/statistics/presentation/screens/efficiency_chart_screen.dart';
import 'features/statistics/presentation/screens/price_chart_screen.dart';
import 'core/providers/shared_preferences_provider.dart';
import 'features/sync/presentation/providers/sync_providers.dart';
import 'features/sync/presentation/screens/sync_settings_screen.dart';
import 'features/sync/presentation/widgets/sync_status_indicator.dart';
import 'generated/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbService = SqfliteDatabaseService();
  await dbService.initialize();
  final database = await dbService.database;
  final dataSource = FuelEntryLocalDataSource(database);

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        dataSourceProvider.overrideWithValue(dataSource),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const GasolinaApp(),
    ),
  );
}

class GasolinaApp extends StatelessWidget {
  const GasolinaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gasolina',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('nl', ''),
      ],
    );
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const FuelEntryListScreen(),
    const PriceChartScreen(),
    const EfficiencyChartScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gasolina'),
        actions: [
          const SyncStatusIndicator(),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Sync settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SyncSettingsScreen(),
              ),
            ),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.list),
            label: l10n.navEntries,
          ),
          NavigationDestination(
            icon: const Icon(Icons.show_chart),
            label: l10n.navPrice,
          ),
          NavigationDestination(
            icon: const Icon(Icons.trending_up),
            label: l10n.navEfficiency,
          ),
        ],
      ),
    );
  }
}
