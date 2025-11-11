import 'package:equatable/equatable.dart';

class Blog extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String? imageUrl;
  final bool published;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? authorPseudo;

  const Blog({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.published,
    required this.createdAt,
    required this.updatedAt,
    this.authorPseudo,
  });

  factory Blog.fromMap(Map<String, dynamic> map) {
    return Blog(
      id: map['id'],
      userId: map['user_id'],
      title: map['title'],
      content: map['content'],
      imageUrl: map['image_url'],
      published: map['published'] ?? false,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      authorPseudo: map['author_pseudo'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'published': published,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'author_pseudo': authorPseudo,
    };
  }

  Blog copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    String? imageUrl,
    bool? published,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? authorPseudo,
  }) {
    return Blog(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      published: published ?? this.published,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authorPseudo: authorPseudo ?? this.authorPseudo,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    content,
    imageUrl,
    published,
    createdAt,
    updatedAt,
    authorPseudo,
  ];
}
