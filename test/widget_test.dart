import 'package:findy/core/services/logger.dart';
import 'package:findy/data/db/app_database.dart';
import 'package:findy/data/repositories/thing_repository.dart';
import 'package:findy/domain/models/thing.dart';
import 'package:findy/domain/usecases/get_all_things_usecase.dart';
import 'package:findy/domain/usecases/search_things_usecase.dart';
import 'package:findy/presentation/screens/thing_list/thing_list_screen.dart';
import 'package:findy/presentation/screens/thing_list/thing_list_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('list screen renders empty state', (tester) async {
    final viewModel = ThingListViewModel(
      getAllThingsUseCase: _FakeGetAllThingsUseCase(),
      searchThingsUseCase: _FakeSearchThingsUseCase(),
      logger: AppLogger(),
    );

    await viewModel.loadThings();

    await tester.pumpWidget(
      ChangeNotifierProvider<ThingListViewModel>.value(
        value: viewModel,
        child: const MaterialApp(
          home: ThingListScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Thing Finder'), findsOneWidget);
    expect(find.text('No things saved yet'), findsOneWidget);
    expect(find.text('Tap + to add your first thing.'), findsOneWidget);
  });
}

ThingRepository _buildUnusedRepository() {
  final logger = AppLogger();
  return ThingRepository(
    appDatabase: AppDatabase(logger: logger),
    logger: logger,
  );
}

class _FakeGetAllThingsUseCase extends GetAllThingsUseCase {
  _FakeGetAllThingsUseCase() : super(_buildUnusedRepository());

  @override
  Future<List<Thing>> call() async => const [];
}

class _FakeSearchThingsUseCase extends SearchThingsUseCase {
  _FakeSearchThingsUseCase() : super(_buildUnusedRepository());

  @override
  Future<List<Thing>> call(String query) async => const [];
}
