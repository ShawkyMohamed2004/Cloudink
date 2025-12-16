import 'package:shared_preferences/shared_preferences.dart';
import '../models/folder.dart';

class FolderService {
  static const String _foldersKey = 'folders';
  static const String _userEmailKey = 'userEmail';

  // Singleton pattern
  static FolderService? _instance;
  FolderService._internal();
  factory FolderService() {
    _instance ??= FolderService._internal();
    return _instance!;
  }

  // Get current user email
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  // Get all folders for current user
  Future<List<Folder>> getFolders() async {
    try {
      final userEmail = await getUserEmail();
      if (userEmail == null) return [];

      final prefs = await SharedPreferences.getInstance();
      final userFoldersKey = '${_foldersKey}_$userEmail';
      final foldersJson = prefs.getStringList(userFoldersKey) ?? [];

      return foldersJson
          .map((folderJson) => Folder.fromJson(folderJson))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name)); // Sort by name
    } catch (e) {
      print('Error loading folders: $e');
      return [];
    }
  }

  // Save a folder
  Future<bool> saveFolder(Folder folder) async {
    try {
      final folders = await getFolders();

      // Check if folder already exists (update) or add new
      final existingIndex = folders.indexWhere((f) => f.id == folder.id);
      if (existingIndex >= 0) {
        folders[existingIndex] = folder;
      } else {
        folders.add(folder);
      }

      return await _saveFolders(folders);
    } catch (e) {
      print('Error saving folder: $e');
      return false;
    }
  }

  // Delete a folder
  Future<bool> deleteFolder(String folderId) async {
    try {
      final folders = await getFolders();
      folders.removeWhere((folder) => folder.id == folderId);
      return await _saveFolders(folders);
    } catch (e) {
      print('Error deleting folder: $e');
      return false;
    }
  }

  // Get folder by ID
  Future<Folder?> getFolderById(String folderId) async {
    try {
      final folders = await getFolders();
      return folders.firstWhere(
        (folder) => folder.id == folderId,
        orElse: () => throw Exception('Folder not found'),
      );
    } catch (e) {
      print('Error getting folder by ID: $e');
      return null;
    }
  }

  // Private method to save folders list
  Future<bool> _saveFolders(List<Folder> folders) async {
    try {
      final userEmail = await getUserEmail();
      if (userEmail == null) return false;

      final prefs = await SharedPreferences.getInstance();
      final userFoldersKey = '${_foldersKey}_$userEmail';
      final foldersJson = folders.map((folder) => folder.toJson()).toList();
      return await prefs.setStringList(userFoldersKey, foldersJson);
    } catch (e) {
      print('Error saving folders list: $e');
      return false;
    }
  }

  // Clear all folders
  Future<bool> clearAllFolders() async {
    try {
      final userEmail = await getUserEmail();
      if (userEmail == null) return false;

      final prefs = await SharedPreferences.getInstance();
      final userFoldersKey = '${_foldersKey}_$userEmail';
      await prefs.remove(userFoldersKey);
      return true;
    } catch (e) {
      print('Error clearing folders: $e');
      return false;
    }
  }
}
