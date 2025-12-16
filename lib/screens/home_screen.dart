import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/folder.dart';
import '../services/notes_provider.dart';
import '../services/folders_provider.dart';
import '../services/theme_provider.dart';
import '../services/auth_provider.dart';
import '../widgets/theme_switcher.dart';
import 'add_note_screen.dart';
import 'add_folder_screen.dart';
import 'folder_detail_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolledDown = false;
  late TabController _tabController;

  // Note colors matching the Cloudink brand
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

  // Folder colors matching the system
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
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_onScroll);

    // Load data using providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotesProvider>().loadNotes();
      context.read<FoldersProvider>().loadFolders();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && !_isScrolledDown) {
      setState(() {
        _isScrolledDown = true;
      });
    } else if (_scrollController.offset <= 100 && _isScrolledDown) {
      setState(() {
        _isScrolledDown = false;
      });
    }
  }

  // Helper function to format dates
  String _formatDateSmart(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck.isAtSameMomentAs(today)) {
      return 'Today';
    } else {
      return DateFormat('MMM dd').format(date);
    }
  }

  // Helper function to format last updated with time
  String _formatLastUpdated(DateTime date) {
    // Always show time in AM/PM format
    return DateFormat('hh:mm a').format(date);
  }

  Future<void> _deleteNote(String noteId) async {
    final confirmed = await _showDeleteConfirmation();
    if (confirmed == true) {
      await context.read<NotesProvider>().deleteNote(noteId);
    }
  }

  Future<void> _deleteFolder(String folderId) async {
    final confirmed = await _showDeleteFolderConfirmation();
    if (confirmed == true) {
      await context.read<FoldersProvider>().deleteFolder(folderId);
    }
  }

  Future<bool?> _showDeleteConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteFolderConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Folder'),
        content: const Text(
          'Are you sure you want to delete this folder and all its notes?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode
                ? const Color(0xFF1A1A1A)
                : const Color(0xFFE8DCC6),
          ),
          child: Stack(
            children: [
              // Main Scaffold
              Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  title: Row(
                    children: [
                      Image.asset(
                        'assets/images/app_icon.png',
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'CloudInk',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : const Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: themeProvider.isDarkMode
                      ? const Color(0xFF1A1A1A)
                      : const Color(0xFFE8DCC6),
                  elevation: 0,
                  actions: [
                    const ThemeSwitcher(),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'logout') {
                          _showLogoutConfirmation();
                        }
                      },
                      icon: Builder(
                        builder: (context) {
                          final isDark = themeProvider.isDarkMode;
                          final dotColor = isDark ? Colors.white : Colors.black;
                          return SizedBox(
                            width: 20,
                            height: 28,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: dotColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: dotColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: dotColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Logout',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  bottom: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'Notes'),
                      Tab(text: 'Folders'),
                    ],
                    labelColor: themeProvider.isDarkMode
                        ? Colors.white
                        : const Color(0xFF2C3E50),
                    unselectedLabelColor: themeProvider.isDarkMode
                        ? Colors.grey
                        : const Color(0xFF95A5A6),
                    indicatorColor: const Color(0xFFF5B041),
                  ),
                ),
                body: TabBarView(
                  controller: _tabController,
                  children: [_buildNotesTab(), _buildFoldersTab()],
                ),
                floatingActionButton: AnimatedSlide(
                  duration: const Duration(milliseconds: 300),
                  offset: _isScrolledDown ? const Offset(0, 2) : Offset.zero,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _isScrolledDown ? 0.7 : 1.0,
                    child: FloatingActionButton(
                      onPressed: () async {
                        if (_tabController.index == 0) {
                          // Add Note
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddNoteScreen(),
                            ),
                          );
                          if (result == true && mounted) {
                            context.read<NotesProvider>().loadNotes();
                          }
                        } else {
                          // Add Folder
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddFolderScreen(),
                            ),
                          );
                          if (result == true && mounted) {
                            context.read<FoldersProvider>().loadFolders();
                          }
                        }
                      },
                      backgroundColor: const Color(0xFFF5B041),
                      child: Icon(
                        _tabController.index == 0
                            ? Icons.add
                            : Icons.create_new_folder,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ], // children of Stack
          ), // Stack
        ); // Container
      },
    );
  }

  Widget _buildNotesTab() {
    return Consumer2<NotesProvider, FoldersProvider>(
      builder: (context, notesProvider, foldersProvider, child) {
        if (notesProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFF5B041)),
          );
        }

        if (notesProvider.notes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_queue_rounded,
                  size: 100,
                  color: const Color(0xFFF5B041).withValues(alpha: 0.7),
                ),
                const SizedBox(height: 20),
                Text(
                  'Welcome to Cloudink!',
                  style: TextStyle(
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your ideas are waiting in the cloud',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap the + button to create your first note',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: notesProvider.notes.length,
          itemBuilder: (context, index) {
            final note = notesProvider.notes[index];
            final noteColor = _noteColors[note.colorIndex % _noteColors.length];

            // Find folder name and color if note belongs to a folder
            String? folderName;
            Color? folderColor;
            if (note.folderId != null) {
              final folder = foldersProvider.folders.firstWhere(
                (f) => f.id == note.folderId,
                orElse: () => Folder(
                  id: '',
                  name: 'Unknown Folder',
                  description: '',
                  colorIndex: 0,
                  createdAt: DateTime.now(),
                ),
              );
              if (folder.id.isNotEmpty) {
                folderName = folder.name;
                folderColor =
                    _folderColors[folder.colorIndex % _folderColors.length];
              }
            }

            return GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddNoteScreen(note: note),
                  ),
                );
                if (result == true) {
                  context.read<NotesProvider>().loadNotes();
                }
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: noteColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            note.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            note.description,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Show folder info if note belongs to a folder
                          if (folderName != null &&
                              folderName.isNotEmpty &&
                              folderColor != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.folder,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    folderName,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatDateSmart(note.createdAt),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _deleteNote(note.id),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Updated',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          _formatLastUpdated(note.createdAt),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFoldersTab() {
    return Consumer<FoldersProvider>(
      builder: (context, foldersProvider, child) {
        if (foldersProvider.folders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_open_rounded,
                  size: 100,
                  color: const Color(0xFFF5B041).withValues(alpha: 0.7),
                ),
                const SizedBox(height: 20),
                Text(
                  'No Folders Yet',
                  style: TextStyle(
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Organize your notes with folders',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap the + button to create your first folder',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemCount: foldersProvider.folders.length,
          itemBuilder: (context, index) {
            final folder = foldersProvider.folders[index];
            final folderColor =
                _folderColors[folder.colorIndex % _folderColors.length];

            return GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FolderDetailScreen(folder: folder),
                  ),
                );
                if (result == true) {
                  context.read<FoldersProvider>().loadFolders();
                  context.read<NotesProvider>().loadNotes();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: folderColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(
                            Icons.folder,
                            color: Colors.white,
                            size: 32,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatDateSmart(folder.createdAt),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () => _deleteFolder(folder.id),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  folder.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  folder.description,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 12,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
