import 'package:flutter/material.dart';
import '../models/folder.dart';
import '../models/note.dart';
import '../services/notes_service.dart';
import '../services/folder_service.dart';
import 'add_note_screen.dart';
import 'add_folder_screen.dart';

class FolderDetailScreen extends StatefulWidget {
  final Folder folder;

  const FolderDetailScreen({super.key, required this.folder});

  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  final NotesService _notesService = NotesService();
  final FolderService _folderService = FolderService();
  List<Note> _notes = [];
  late Folder _currentFolder;
  bool _isLoading = true;
  bool _hasChanges = false; // Track if folder was modified

  final List<Color> _folderColors = [
    const Color(0xFFF5B041), // Golden yellow (main brand color)
    const Color(0xFF5DADE2), // Sky blue
    const Color(0xFF58D68D), // Emerald green
    const Color(0xFFAF7AC5), // Purple
    const Color(0xFFE74C3C), // Red
    const Color(0xFFFF6B9D), // Pink
    const Color(0xFFF39C12), // Orange
    const Color(0xFF2ECC71), // Green
    const Color(0xFF3498DB), // Blue
    const Color(0xFF9B59B6), // Violet
    const Color(0xFF1ABC9C), // Turquoise
    const Color(0xFFE67E22), // Carrot orange
  ];

  // Note colors matching the system
  final List<Color> _noteColors = [
    const Color(0xFFF5B041), // Golden yellow (main brand color)
    const Color(0xFF5DADE2), // Sky blue
    const Color(0xFF58D68D), // Emerald green
    const Color(0xFFAF7AC5), // Purple
    const Color(0xFFE74C3C), // Red
    const Color(0xFFFF6B9D), // Pink
    const Color(0xFFF39C12), // Orange
    const Color(0xFF2ECC71), // Green
    const Color(0xFF3498DB), // Blue
    const Color(0xFF9B59B6), // Violet
    const Color(0xFF1ABC9C), // Turquoise
    const Color(0xFFE67E22), // Carrot orange
    const Color(0xFF95A5A6), // Gray
    const Color(0xFF34495E), // Dark blue gray
  ];

  @override
  void initState() {
    super.initState();
    _currentFolder = widget.folder;
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notes = await _notesService.getNotesByFolder(_currentFolder.id);
      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteNote(Note note) async {
    final confirmed = await _showDeleteConfirmation(
      'Delete Note',
      'Are you sure you want to delete this note?',
    );
    if (confirmed) {
      final success = await _notesService.deleteNote(note.id);
      if (success) {
        _loadNotes();
        _hasChanges = true; // Mark that changes were made
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note deleted successfully')),
          );
        }
      }
    }
  }

  Future<void> _deleteFolder() async {
    final confirmed = await _showDeleteConfirmation(
      'Delete Folder',
      'Are you sure you want to delete this folder? All notes in this folder will be moved to the general notes.',
    );
    if (confirmed) {
      // Move all notes in this folder to have no folder (folderId = null)
      for (final note in _notes) {
        final updatedNote = note.copyWith(folderId: null);
        await _notesService.updateNote(updatedNote);
      }

      // Delete the folder
      final success = await _folderService.deleteFolder(_currentFolder.id);
      if (success && mounted) {
        _hasChanges = true; // Mark that changes were made
        Navigator.pop(context, true); // Return to previous screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Folder deleted successfully')),
        );
      }
    }
  }

  Future<bool> _showDeleteConfirmation(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _editFolder() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFolderScreen(folder: _currentFolder),
      ),
    );

    if (result == true) {
      // Reload folder details
      final folders = await _folderService.getFolders();
      final updatedFolder = folders.firstWhere(
        (f) => f.id == _currentFolder.id,
        orElse: () => _currentFolder,
      );
      setState(() {
        _currentFolder = updatedFolder;
        _hasChanges = true; // Mark that changes were made
      });

      // Add small delay to ensure data is saved before returning
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void _addNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddNoteScreen(folderId: _currentFolder.id),
      ),
    );

    if (result == true) {
      _loadNotes();
      _hasChanges = true; // Mark that changes were made
    }
  }

  Color get _folderColor {
    if (_currentFolder.colorIndex >= 0 &&
        _currentFolder.colorIndex < _folderColors.length) {
      return _folderColors[_currentFolder.colorIndex];
    }
    return _folderColors[0]; // Default color
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, _hasChanges);
          },
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _folderColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.folder, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _currentFolder.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _editFolder();
                  break;
                case 'delete':
                  _deleteFolder();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('Edit Folder'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Delete Folder', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Folder description
          if (_currentFolder.description.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _folderColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _folderColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                _currentFolder.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.8),
                  height: 1.4,
                ),
              ),
            ),

          // Notes count and add button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${_notes.length} note${_notes.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _addNote,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Note'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _folderColor,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Notes list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _folderColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.note_add,
                            size: 40,
                            color: _folderColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notes in this folder',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the "Add Note" button to create your first note',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      final note = _notes[index];
                      final noteColor =
                          _noteColors[note.colorIndex % _noteColors.length];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: noteColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            note.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                note.content,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${note.createdAt.day}/${note.createdAt.month}/${note.createdAt.year}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              switch (value) {
                                case 'edit':
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AddNoteScreen(note: note),
                                    ),
                                  ).then((result) {
                                    if (result == true) {
                                      _loadNotes();
                                      _hasChanges =
                                          true; // Mark that changes were made
                                    }
                                  });
                                  break;
                                case 'delete':
                                  _deleteNote(note);
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 18),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddNoteScreen(note: note),
                              ),
                            ).then((result) {
                              if (result == true) {
                                _loadNotes();
                                _hasChanges =
                                    true; // Mark that changes were made
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
