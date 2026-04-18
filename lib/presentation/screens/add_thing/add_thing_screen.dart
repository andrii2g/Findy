import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/app_text_field.dart';
import '../../widgets/image_preview.dart';
import '../../widgets/primary_button.dart';
import 'add_thing_view_model.dart';

class AddThingScreen extends StatefulWidget {
  const AddThingScreen({super.key});

  @override
  State<AddThingScreen> createState() => _AddThingScreenState();
}

class _AddThingScreenState extends State<AddThingScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddThingViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Add new thing')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _controller,
                label: 'What is this thing?',
                hintText: 'gray winter coat',
                onChanged: viewModel.updateDescription,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: viewModel.status == ThingFormStatus.saving
                    ? null
                    : viewModel.takePhoto,
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text(
                  viewModel.selectedPhoto == null
                      ? 'Take location photo'
                      : 'Retake location photo',
                ),
              ),
              if (viewModel.selectedPhoto != null) ...[
                const SizedBox(height: 16),
                ImagePreview(filePath: viewModel.selectedPhoto!.path),
              ],
              if (viewModel.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  viewModel.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Save',
                isBusy: viewModel.status == ThingFormStatus.saving,
                onPressed: viewModel.canSave
                    ? () async {
                        final didSave = await context.read<AddThingViewModel>().save();
                        if (!context.mounted) {
                          return;
                        }
                        if (didSave) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Thing saved locally.')),
                          );
                          Navigator.of(context).pop(true);
                        }
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
