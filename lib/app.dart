import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/logger.dart';
import 'data/repositories/thing_repository.dart';
import 'domain/usecases/add_thing_usecase.dart';
import 'domain/usecases/delete_thing_usecase.dart';
import 'domain/usecases/get_all_things_usecase.dart';
import 'domain/usecases/get_thing_by_id_usecase.dart';
import 'domain/usecases/search_things_usecase.dart';
import 'domain/usecases/update_thing_usecase.dart';
import 'presentation/screens/thing_list/thing_list_screen.dart';
import 'presentation/screens/thing_list/thing_list_view_model.dart';

class FindyApp extends StatelessWidget {
  const FindyApp({
    required this.logger,
    required this.thingRepository,
    required this.addThingUseCase,
    required this.getAllThingsUseCase,
    required this.searchThingsUseCase,
    required this.getThingByIdUseCase,
    required this.updateThingUseCase,
    required this.deleteThingUseCase,
    super.key,
  });

  final AppLogger logger;
  final ThingRepository thingRepository;
  final AddThingUseCase addThingUseCase;
  final GetAllThingsUseCase getAllThingsUseCase;
  final SearchThingsUseCase searchThingsUseCase;
  final GetThingByIdUseCase getThingByIdUseCase;
  final UpdateThingUseCase updateThingUseCase;
  final DeleteThingUseCase deleteThingUseCase;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2A6F4F),
      brightness: Brightness.light,
    );

    return MultiProvider(
      providers: [
        Provider.value(value: logger),
        Provider.value(value: thingRepository),
        Provider.value(value: addThingUseCase),
        Provider.value(value: getAllThingsUseCase),
        Provider.value(value: searchThingsUseCase),
        Provider.value(value: getThingByIdUseCase),
        Provider.value(value: updateThingUseCase),
        Provider.value(value: deleteThingUseCase),
      ],
      child: MaterialApp(
        title: 'Findy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: colorScheme,
          scaffoldBackgroundColor: const Color(0xFFF7F5EE),
          appBarTheme: AppBarTheme(
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: colorScheme.primary,
            contentTextStyle: TextStyle(color: colorScheme.onPrimary),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          useMaterial3: true,
        ),
        home: ChangeNotifierProvider(
          create: (context) => ThingListViewModel(
            getAllThingsUseCase: context.read<GetAllThingsUseCase>(),
            searchThingsUseCase: context.read<SearchThingsUseCase>(),
            logger: context.read<AppLogger>(),
          )..loadThings(),
          child: const ThingListScreen(),
        ),
      ),
    );
  }
}
