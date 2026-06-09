import 'package:hive_flutter/hive_flutter.dart';
import '../models/cloud_record.dart';

class StorageService {
  final box = Hive.box("records");

  Future<void> addRecord(CloudRecord record) async {
    await box.put(record.id, record.toMap());
  }

  Future<void> deleteRecord(String id) async {
    await box.delete(id);
  }

  List<CloudRecord> getRecords() {
    final list = box.values.toList();

    return list.map((e) {
      return CloudRecord.fromMap(Map<String, dynamic>.from(e));
    }).toList().reversed.toList();
  }
}