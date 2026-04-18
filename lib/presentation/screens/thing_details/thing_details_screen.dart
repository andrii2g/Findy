import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/logger.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/usecases/update_thing_usecase.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/image_preview.dart';
import '../edit_thing/edit_thing_screen.dart';
import '../edit_thing/edit_thing_view_model.dart';
import 'thing_details_view_model.dart';

class ThingDetailsScreen extends StatelessWidget {
  const ThingDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ThingDetailsViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thing details'),
      ),
      body: SafeArea(
        child: switch (viewModel.status) {
          ThingDetailsStatus.loading ||
          ThingDetailsStatus.initial => const Center(
              child: CircularProgressIndicator(),
            ),
          ThingDetailsStatus.error => EmptyState(
              title: 'Unable to open this thing',
              message: viewModel.errorMessage ?? 'Please go back and try again.',
            ),
          _ => _ThingDetailsContent(viewModel: viewModel),
        },
      ),
    );
  }
}

class _ThingDetailsContent extends StatelessWidget {
  const _ThingDetailsContent({required this.viewModel});

  final ThingDetailsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final thing = viewModel.thing!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ImagePreview(
            filePath: thing.imagePath,
            height: 280,
          ),
          const SizedBox(height: 20),
          Text(
            thing.description,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _MetaRow(
            label: 'Created',
            value: formatThingDate(thing.createdAt),
          ),
          const SizedBox(height: 8),
          _MetaRow(
            label: 'Updated',
            value: formatThingDate(thing.updatedAt),
          ),
          if (viewModel.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              viewModel.errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () async {
              final updatedThing = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider(
                    create: (context) => EditThingViewModel(
                      thing: thing,
                      updateThingUseCase: context.read<UpdateThingUseCase>(),
                      logger: context.read<AppLogger>(),
                    ),
                    child: const EditThingScreen(),
                  ),
                ),
              );

              if (updatedThing != null && context.mounted) {
                await context.read<ThingDetailsViewModel>().load();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thing details refreshed.')),
                  );
                }
              }
            },
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: viewModel.status == ThingDetailsStatus.deleting
                ? null
                : () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete this thing?'),
                        content: const Text(
                          'This removes the saved description and photos from this device.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed != true || !context.mounted) {
                      return;
                    }

                    final deleted = await context.read<ThingDetailsViewModel>().deleteThing();
                    if (!context.mounted) {
                      return;
                    }
                    if (deleted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Thing deleted.')),
                      );
                      Navigator.of(context).pop(true);
                    }
                  },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 84,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}
