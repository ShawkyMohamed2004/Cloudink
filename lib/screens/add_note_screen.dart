import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/notes_provider.dart';
import '../services/folders_provider.dart';
import '../services/theme_provider.dart';

class AddNoteScreen extends StatefulWidget {
  final Note? note;
  final String? folderId;

  const AddNoteScreen({super.key, this.note, this.folderId});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  int _selectedColorIndex = 0;
  String? _selectedFolderId;
  bool _isLoading = false;

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
  ];

  final List<Color> _folderColors = [
    const Color(0xFFF5B041), // Golden yellow
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

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _descriptionController.text = widget.note!.description;
      _selectedColorIndex = widget.note!.colorIndex;
      _selectedFolderId = widget.note!.folderId;
    } else if (widget.folderId != null) {
      // إذا كان جاي من داخل فولدر، اختار الفولدر دا أوتوماتيك
      _selectedFolderId = widget.folderId;
    }

    // Load folders using provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoldersProvider>().loadFolders();
    });
  }

  Future<void> _saveNote() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final note = Note(
        id: widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        createdAt: widget.note?.createdAt ?? DateTime.now(),
        colorIndex: _selectedColorIndex,
        folderId: _selectedFolderId,
      );

      if (widget.note != null) {
        await context.read<NotesProvider>().updateNote(note);
      } else {
        await context.read<NotesProvider>().addNote(note);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving note: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Consumer2<ThemeProvider, FoldersProvider>(
      builder: (context, themeProvider, foldersProvider, child) {
        return Scaffold(
          backgroundColor: themeProvider.isDarkMode
              ? const Color(0xFF1A1A1A)
              : const Color(0xFFE8DCC6),
          appBar: AppBar(
            title: Text(
              widget.note == null ? 'Add Note' : 'Edit Note',
              style: TextStyle(
                color: themeProvider.isDarkMode
                    ? Colors.white
                    : const Color(0xFF2C3E50),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            backgroundColor: themeProvider.isDarkMode
                ? const Color(0xFF1A1A1A)
                : const Color(0xFFE8DCC6),
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: themeProvider.isDarkMode
                    ? Colors.white
                    : const Color(0xFF2C3E50),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title field
                        Container(
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkMode
                                ? const Color(0xFF2A2A2A)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _titleController,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF2C3E50),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Note Title...',
                              hintStyle: TextStyle(
                                color: themeProvider.isDarkMode
                                    ? Colors.grey
                                    : const Color(0xFF95A5A6),
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Description field
                        Container(
                          height: keyboardVisible ? 120 : 100,
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkMode
                                ? const Color(0xFF2A2A2A)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _descriptionController,
                            maxLines: null,
                            expands: true,
                            style: TextStyle(
                              fontSize: 16,
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF2C3E50),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Write your note here...',
                              hintStyle: TextStyle(
                                color: themeProvider.isDarkMode
                                    ? Colors.grey
                                    : const Color(0xFF95A5A6),
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                            textAlignVertical: TextAlignVertical.top,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Colors section - يختفي لما الكيبورد ظاهر
                        if (!keyboardVisible) ...[
                          const Text(
                            'Choose Color:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(_noteColors.length, (
                                index,
                              ) {
                                final isSelected = index == _selectedColorIndex;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedColorIndex = index;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: isSelected ? 50 : 45,
                                    height: isSelected ? 50 : 45,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color: _noteColors[index],
                                      borderRadius: BorderRadius.circular(25),
                                      border: isSelected
                                          ? Border.all(
                                              color: const Color(0xFF2C3E50),
                                              width: 3,
                                            )
                                          : Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isSelected
                                              ? _noteColors[index].withValues(
                                                  alpha: 0.6,
                                                )
                                              : _noteColors[index].withValues(
                                                  alpha: 0.3,
                                                ),
                                          blurRadius: isSelected ? 12 : 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 24,
                                          )
                                        : null,
                                  ),
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Folders section - مدمج horizontal scrolling
                        const Text(
                          'Select Folder:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 12),
                        foldersProvider.folders.isEmpty
                            ? const Text(
                                'No folders available. Create a folder first.',
                                style: TextStyle(
                                  color: Color(0xFF95A5A6),
                                  fontSize: 14,
                                ),
                              )
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    // None option
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedFolderId = null;
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 18,
                                          vertical: 10,
                                        ),
                                        margin: const EdgeInsets.only(
                                          right: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: _selectedFolderId == null
                                              ? const LinearGradient(
                                                  colors: [
                                                    Color(0xFF3498DB),
                                                    Color(0xFF2980B9),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                )
                                              : null,
                                          color: _selectedFolderId == null
                                              ? null
                                              : Colors.grey[100],
                                          borderRadius: BorderRadius.circular(
                                            22,
                                          ),
                                          border: _selectedFolderId == null
                                              ? null
                                              : Border.all(
                                                  color: Colors.grey[300]!,
                                                  width: 1,
                                                ),
                                          boxShadow: _selectedFolderId == null
                                              ? [
                                                  BoxShadow(
                                                    color: const Color(
                                                      0xFF3498DB,
                                                    ).withValues(alpha: 0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.clear,
                                              color: _selectedFolderId == null
                                                  ? Colors.white
                                                  : Colors.grey[600],
                                              size: 22,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'None',
                                              style: TextStyle(
                                                color: _selectedFolderId == null
                                                    ? Colors.white
                                                    : Colors.grey[600],
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Folders options
                                    ...foldersProvider.folders.map((folder) {
                                      final isSelected =
                                          _selectedFolderId == folder.id;
                                      final folderColor =
                                          _folderColors[folder.colorIndex %
                                              _folderColors.length];
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedFolderId = folder.id;
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          margin: const EdgeInsets.only(
                                            right: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? const Color(0xFF3498DB)
                                                : Colors.grey[200],
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  color: folderColor,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                folder.name.length > 8
                                                    ? '${folder.name.substring(0, 8)}...'
                                                    : folder.name,
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.grey[700],
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                ),

                // Save button - دائماً في الأسفل
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFF5B041),
                            Color(0xFFF39C12),
                          ], // Golden gradient instead of blue
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFF5B041,
                            ).withValues(alpha: 0.3), // Golden shadow
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveNote,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                widget.note == null
                                    ? 'Save Note'
                                    : 'Update Note',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
