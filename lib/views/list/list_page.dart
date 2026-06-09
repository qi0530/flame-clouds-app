import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/record_provider.dart';
import '../detail/detail_page.dart';

class ListPage extends ConsumerWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(recordProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("历史记录"),
      ),
      body: ListView.builder(
        itemCount: records.length,
        itemBuilder: (context, index) {
          final r = records[index];

          return ListTile(
            leading: Image.file(
              File(r.imagePath),
              width: 60,
              fit: BoxFit.cover,
            ),
            title: Text("${r.probability.toInt()}%"),
            subtitle: Text(r.cloudType),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailPage(r),
                ),
              );
            },
          );
        },
      ),
    );
  }
}