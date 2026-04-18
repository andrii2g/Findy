import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/logger.dart';
import '../../../domain/usecases/add_thing_usecase.dart';
import '../../../domain/usecases/delete_thing_usecase.dart';
import '../../../domain/usecases/get_thing_by_id_usecase.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/thing_list_item.dart';
import '../add_thing/add_thing_screen.dart';
import '../add_thing/add_thing_view_model.dart';
import '../thing_details/thing_details_screen.dart';
import '../thing_details/thing_details_view_model.dart';
import 'thing_list_view_model.dart';

class ThingListScreen extends StatelessWidget {
  const ThingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ThingListViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thing Finder'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final didSave = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider(
                create: (context) => AddThingViewModel(
                  addThingUseCase: context.read<AddThingUseCase>(),
                  logger: context.read<AppLogger>(),
                ),
                child: const AddThingScreen(),
              ),
            ),
          );

          if (didSave == true && context.mounted) {
            await context.read<ThingListViewModel>().loadThings();
          }
        },
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Add new thing'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            children: [
              TextField(
                onChanged: (value) =>
                    context.read<ThingListViewModel>().updateSearchQuery(value),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search things...',
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: switch (viewModel.status) {
                  ThingListStatus.loading => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ThingListStatus.error => EmptyState(
                      title: 'Something went wrong',
                      message:
                          viewModel.errorMessage ?? 'Please try again in a moment.',
                    ),
                  ThingListStatus.empty => EmptyState(
                      title: 'No things saved yet',
                      message: viewModel.searchQuery.trim().isEmpty
                          ? 'Tap + to add your first thing.'
                          : 'Try a different search.',
                    ),
                  _ => ListView.builder(
                      itemCount: viewModel.things.length,
                      itemBuilder: (context, index) {
                        final thing = viewModel.things[index];
                        return ThingListItem(
                          thing: thing,
                          onTap: () async {
                            final changed = await Navigator.of(context).push<bool>(
                              MaterialPageRoute(
                                builder: (_) => ChangeNotifierProvider(
                                  create: (context) => ThingDetailsViewModel(
                                    thingId: thing.id,
                                    getThingByIdUseCase:
                                        context.read<GetThingByIdUseCase>(),
                                    deleteThingUseCase:
                                        context.read<DeleteThingUseCase>(),
                                    logger: context.read<AppLogger>(),
                                  )..load(),
                                  child: const ThingDetailsScreen(),
                                ),
                              ),
                            );

                            if (changed == true && context.mounted) {
                              await context.read<ThingListViewModel>().loadThings();
                            }
                          },
                        );
                      },
                    ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
