import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/folder.dart';
import '../services/folder_service.dart';

class AddFolderScreen extends StatefulWidget {
  final Folder? folder; // For editing existing folders

  const AddFolderScreen({super.key, this.folder});

  @override
  State<AddFolderScreen> createState() => _AddFolderScreenState();
}

class _AddFolderScreenState extends State<AddFolderScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final FolderService _folderService = FolderService();
  final Uuid _uuid = const Uuid();

  int _selectedColorIndex = 0;
  bool _isLoading = false;

  // Folder colors matching the Cloudink brand
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

  @override
  void initState() {
    super.initState();
    if (widget.folder != null) {
      _nameController.text = widget.folder!.name;
      _descriptionController.text = widget.folder!.description;
      _selectedColorIndex = widget.folder!.colorIndex;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveFolder() async {
    if (_nameController.text.trim().isEmpty) {
      _showErrorDialog('Please enter a folder name');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final folder = Folder(
        id: widget.folder?.id ?? _uuid.v4(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        createdAt: widget.folder?.createdAt ?? DateTime.now(),
        colorIndex: _selectedColorIndex,
      );

      final success = await _folderService.saveFolder(folder);

      if (success) {
        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        _showErrorDialog('Failed to save folder. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('An error occurred while saving the folder.');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.folder != null ? 'Edit Folder' : 'Create Folder',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveFolder,
              child: Text(
                widget.folder != null ? 'Update' : 'Create',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name field
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
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
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter folder name',
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
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
                  decoration: InputDecoration(
                    hintText: 'Enter folder description (optional)',
                    hintStyle: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(20),
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.5,
                  ),
                  textAlignVertical: TextAlignVertical.top,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Color selection
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Color',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_folderColors.length, (index) {
                      final isSelected = index == _selectedColorIndex;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColorIndex = index;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: _folderColors[index],
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                    width: 3,
                                  )
                                : Border.all(
                                    color: Colors.grey.withOpacity(0.3),
                                    width: 1,
                                  ),
                            boxShadow: [
                              BoxShadow(
                                color: _folderColors[index].withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: isSelected ? 8 : 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: isSelected
                              ? Icon(Icons.check, color: Colors.white, size: 20)
                              : null,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Create/Update Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveFolder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFFF5B041,
                  ), // Golden yellow brand color
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  shadowColor: const Color(0xFFF5B041).withValues(alpha: 0.3),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        widget.folder != null
                            ? 'Update Folder'
                            : 'Create Folder',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
