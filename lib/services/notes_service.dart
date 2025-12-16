import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class NotesService {
  static const String _notesKey = 'notes';
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userEmailKey = 'userEmail';

  // Singleton pattern
  static NotesService? _instance;
  NotesService._internal();
  factory NotesService() {
    _instance ??= NotesService._internal();
    return _instance!;
  }

  // Get all notes for current user
  Future<List<Note>> getNotes() async {
    try {
      final userEmail = await getUserEmail();
      if (userEmail == null) return [];

      final prefs = await SharedPreferences.getInstance();
      final userNotesKey = '${_notesKey}_$userEmail';
      final notesJson = prefs.getStringList(userNotesKey) ?? [];

      return notesJson.map((noteJson) => Note.fromJson(noteJson)).toList()
        ..sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
        ); // Sort by newest first
    } catch (e) {
      print('Error loading notes: $e');
      return [];
    }
  }

  // Save a note
  Future<bool> saveNote(Note note) async {
    try {
      final notes = await getNotes();

      // Check if note already exists (update) or add new
      final existingIndex = notes.indexWhere((n) => n.id == note.id);
      if (existingIndex >= 0) {
        notes[existingIndex] = note;
      } else {
        notes.add(note);
      }

      return await _saveNotes(notes);
    } catch (e) {
      print('Error saving note: $e');
      return false;
    }
  }

  // Delete a note
  Future<bool> deleteNote(String noteId) async {
    try {
      final notes = await getNotes();
      notes.removeWhere((note) => note.id == noteId);
      return await _saveNotes(notes);
    } catch (e) {
      print('Error deleting note: $e');
      return false;
    }
  }

  // Private method to save notes list for current user
  Future<bool> _saveNotes(List<Note> notes) async {
    try {
      final userEmail = await getUserEmail();
      if (userEmail == null) return false;

      final prefs = await SharedPreferences.getInstance();
      final userNotesKey = '${_notesKey}_$userEmail';
      final notesJson = notes.map((note) => note.toJson()).toList();
      return await prefs.setStringList(userNotesKey, notesJson);
    } catch (e) {
      print('Error saving notes list: $e');
      return false;
    }
  }

  // Login management
  Future<bool> setLoggedIn(bool isLoggedIn, {String? email}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, isLoggedIn);
      if (email != null) {
        await prefs.setString(_userEmailKey, email);
      }
      return true;
    } catch (e) {
      print('Error setting login status: $e');
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userEmailKey);
    } catch (e) {
      print('Error getting user email: $e');
      return null;
    }
  }

  // Get notes by folder
  Future<List<Note>> getNotesByFolder(String? folderId) async {
    try {
      final allNotes = await getNotes();
      if (folderId == null) {
        // Return notes without folder (general notes)
        return allNotes.where((note) => note.folderId == null).toList();
      } else {
        // Return notes in specific folder
        return allNotes.where((note) => note.folderId == folderId).toList();
      }
    } catch (e) {
      print('Error getting notes by folder: $e');
      return [];
    }
  }

  // Move note to folder
  Future<bool> moveNoteToFolder(String noteId, String? folderId) async {
    try {
      final notes = await getNotes();
      final noteIndex = notes.indexWhere((note) => note.id == noteId);

      if (noteIndex >= 0) {
        final updatedNote = notes[noteIndex].copyWith(folderId: folderId);
        notes[noteIndex] = updatedNote;
        return await _saveNotes(notes);
      }
      return false;
    } catch (e) {
      print('Error moving note to folder: $e');
      return false;
    }
  }

  // Update note
  Future<bool> updateNote(Note note) async {
    try {
      final notes = await getNotes();
      final noteIndex = notes.indexWhere((n) => n.id == note.id);

      if (noteIndex >= 0) {
        notes[noteIndex] = note;
        return await _saveNotes(notes);
      }
      return false;
    } catch (e) {
      print('Error updating note: $e');
      return false;
    }
  }

  // Logout and clear current user's notes
  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_isLoggedInKey);
      await prefs.remove(_userEmailKey);
      // Notes will remain but won't be accessible without login
      return true;
    } catch (e) {
      print('Error during logout: $e');
      return false;
    }
  }

  // Clear all data
  Future<bool> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      return true;
    } catch (e) {
      print('Error clearing data: $e');
      return false;
    }
  }
}
