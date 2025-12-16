import 'dart:convert';

class Note {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final int colorIndex;
  final String? folderId; // Optional folder ID

  Note({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.colorIndex,
    this.folderId,
  });

  // Convert Note to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'colorIndex': colorIndex,
      'folderId': folderId,
    };
  }

  // Create Note from Map
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      colorIndex: map['colorIndex'] ?? 0,
      folderId: map['folderId'],
    );
  }

  // Convert to JSON
  String toJson() => json.encode(toMap());

  // Create from JSON
  factory Note.fromJson(String source) => Note.fromMap(json.decode(source));

  // Copy with method for updates
  Note copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    int? colorIndex,
    String? folderId,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      colorIndex: colorIndex ?? this.colorIndex,
      folderId: folderId ?? this.folderId,
    );
  }

  // Getter for content (alias for description)
  String get content => description;

  @override
  String toString() {
    return 'Note(id: $id, title: $title, description: $description, createdAt: $createdAt, colorIndex: $colorIndex)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Note &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.createdAt == createdAt &&
        other.colorIndex == colorIndex;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        createdAt.hashCode ^
        colorIndex.hashCode;
  }
}
