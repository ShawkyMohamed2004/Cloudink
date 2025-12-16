import 'package:flutter/material.dart';
import '../models/note.dart';
import 'notes_service.dart';

class NotesProvider extends ChangeNotifier {
  final NotesService _notesService = NotesService();

  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<Note> get notes => _notes;
  List<Note> get filteredNotes => _filteredNotes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  Future<void> loadNotes() async {
    _setLoading(true);
    _setError(null);

    try {
      _notes = await _notesService.getNotes();
      _applySearch();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load notes: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addNote(Note note) async {
    try {
      await _notesService.saveNote(note);
      await loadNotes(); // Reload to get updated list
    } catch (e) {
      _setError('Failed to add note: $e');
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      await _notesService.saveNote(note);
      await loadNotes(); // Reload to get updated list
    } catch (e) {
      _setError('Failed to update note: $e');
    }
  }

  Future<bool> deleteNote(String noteId) async {
    try {
      final success = await _notesService.deleteNote(noteId);
      if (success) {
        await loadNotes(); // Reload to get updated list
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to delete note: $e');
      return false;
    }
  }

  Future<List<Note>> getNotesByFolder(String folderId) async {
    try {
      return await _notesService.getNotesByFolder(folderId);
    } catch (e) {
      _setError('Failed to load folder notes: $e');
      return [];
    }
  }

  void searchNotes(String query) {
    _searchQuery = query;
    _applySearch();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _applySearch();
    notifyListeners();
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredNotes = List.from(_notes);
    } else {
      _filteredNotes = _notes
          .where(
            (note) =>
                note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                note.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear all notes (for logout)
  void clearNotes() {
    _notes = [];
    _filteredNotes = [];
    _searchQuery = '';
    notifyListeners();
  }
}
