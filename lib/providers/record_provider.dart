import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cloud_record.dart';
import '../services/storage_service.dart';

final recordProvider =
StateNotifierProvider<RecordNotifier, List<CloudRecord>>(
      (ref) => RecordNotifier(),
);

class RecordNotifier extends StateNotifier<List<CloudRecord>> {
  RecordNotifier() : super([]) {
    loadRecords();
  }

  final storage = StorageService();

  void loadRecords() {
    state = storage.getRecords();
  }

  Future<void> addRecord(CloudRecord record) async {
    await storage.addRecord(record);
    loadRecords();
  }

  Future<void> deleteRecord(String id) async {
    await storage.deleteRecord(id);
    loadRecords();
  }
}