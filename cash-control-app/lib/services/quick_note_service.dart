import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

class QuickNoteService {
  static const String boxName = "cash_control_local";

  static const String notesKey = "quick_notes";

  static const Uuid uuid = Uuid();

  static Box get _box => Hive.box(boxName);

  static Future<List<Map<String, dynamic>>> getNotes() async {
    final saved = _box.get(notesKey);

    if (saved == null) {
      return [];
    }

    return List<Map<String, dynamic>>.from(
      saved.map(
        (item) => Map<String, dynamic>.from(item),
      ),
    );
  }

  static Future<void> addNote({
    required String title,
    required String content,
    String category = "General",
  }) async {
    final notes = await getNotes();

    notes.insert(0, {
      "id": uuid.v4(),
      "title": title.trim().isEmpty ? "Nota rápida" : title.trim(),
      "content": content.trim(),
      "category": category.trim().isEmpty ? "General" : category.trim(),
      "created_at": DateTime.now().toIso8601String(),
      "sync_status": "pending",
    });

    await _box.put(
      notesKey,
      notes,
    );
  }

  static Future<void> deleteNote(
    String id,
  ) async {
    final notes = await getNotes();

    notes.removeWhere(
      (note) => note["id"] == id,
    );

    await _box.put(
      notesKey,
      notes,
    );
  }

  static Future<int> getPendingCount() async {
    final notes = await getNotes();

    return notes.where(
      (note) => note["sync_status"] == "pending",
    ).length;
  }
}