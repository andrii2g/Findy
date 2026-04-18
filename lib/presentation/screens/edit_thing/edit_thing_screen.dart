import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/app_text_field.dart';
import '../../widgets/image_preview.dart';
import '../../widgets/primary_button.dart';
import '../add_thing/add_thing_view_model.dart';
import 'edit_thing_view_model.dart';

class EditThingScreen extends StatefulWidget {
  const EditThingScreen({super.key});

  @override
  State<EditThingScreen> createState() => _EditThingScreenState();
}

class _EditThingScreenState extends State<EditThingScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<EditThingViewModel>().description,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EditThingViewModel>();
    final previewPath = viewModel.selectedPhoto?.path ?? viewModel.existingImagePath;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit thing')),
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
                label: const Text('Retake location photo'),
              ),
              const SizedBox(height: 16),
              ImagePreview(filePath: previewPath),
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
                        final updatedThing =
                            await context.read<EditThingViewModel>().save();
                        if (!context.mounted) {
                          return;
                        }
                        if (updatedThing != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Thing updated locally.')),
                          );
                          Navigator.of(context).pop(updatedThing);
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
