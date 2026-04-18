import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/utils/date_utils.dart';
import '../../domain/models/thing.dart';

class ThingListItem extends StatelessWidget {
  const ThingListItem({
    required this.thing,
    required this.onTap,
    super.key,
  });

  final Thing thing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(10),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(thing.thumbnailPath),
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 64,
                height: 64,
                color: theme.colorScheme.surfaceContainerHighest,
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported_outlined),
              );
            },
          ),
        ),
        title: Text(
          thing.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('Updated ${formatThingDate(thing.updatedAt)}'),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
