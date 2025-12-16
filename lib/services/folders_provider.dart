import 'package:flutter/material.dart';
import '../models/folder.dart';
import 'folder_service.dart';

class FoldersProvider extends ChangeNotifier {
  final FolderService _folderService = FolderService();

  List<Folder> _folders = [];
  bool _isLoading = false;
  String? _error;

  List<Folder> get folders => _folders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadFolders() async {
    _setLoading(true);
    _setError(null);

    try {
      _folders = await _folderService.getFolders();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load folders: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addFolder(Folder folder) async {
    try {
      await _folderService.saveFolder(folder);
      await loadFolders(); // Reload to get updated list
    } catch (e) {
      _setError('Failed to add folder: $e');
    }
  }

  Future<void> updateFolder(Folder folder) async {
    try {
      await _folderService.saveFolder(folder);
      await loadFolders(); // Reload to get updated list
    } catch (e) {
      _setError('Failed to update folder: $e');
    }
  }

  Future<bool> deleteFolder(String folderId) async {
    try {
      final success = await _folderService.deleteFolder(folderId);
      if (success) {
        await loadFolders(); // Reload to get updated list
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to delete folder: $e');
      return false;
    }
  }

  Folder? getFolderById(String folderId) {
    try {
      return _folders.firstWhere((folder) => folder.id == folderId);
    } catch (e) {
      return null;
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

  // Clear all folders (for logout)
  void clearFolders() {
    _folders = [];
    notifyListeners();
  }
}
