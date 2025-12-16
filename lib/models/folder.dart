import 'dart:convert';

class Folder {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final int colorIndex;

  Folder({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.colorIndex,
  });

  // Convert Folder to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'colorIndex': colorIndex,
    };
  }

  // Create Folder from Map
  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      colorIndex: map['colorIndex'] ?? 0,
    );
  }

  // Convert to JSON
  String toJson() => json.encode(toMap());

  // Create from JSON
  factory Folder.fromJson(String source) => Folder.fromMap(json.decode(source));

  // Copy with method for updates
  Folder copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    int? colorIndex,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }

  @override
  String toString() {
    return 'Folder(id: $id, name: $name, description: $description, createdAt: $createdAt, colorIndex: $colorIndex)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Folder &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.createdAt == createdAt &&
        other.colorIndex == colorIndex;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        createdAt.hashCode ^
        colorIndex.hashCode;
  }
}
