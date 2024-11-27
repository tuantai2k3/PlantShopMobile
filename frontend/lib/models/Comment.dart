class Comment {
  final String user;
  final String? content;
  final DateTime createdAt;

  // Constructor
  Comment({
    required this.user,
    required this.content,
    required this.createdAt,
  });

  // Factory method to create a Comment from a JSON object
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      user: json['name'] ?? 'Anonymous', // Default to 'Anonymous' if name is null
      content: json['content'] ?? '', // Default to empty string if content is null
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(), // Default to current time if created_at is null
    );
  }

  // Convert the Comment object back to JSON (if needed)
  Map<String, dynamic> toJson() {
    return {
      'name': user,
      'content': content,
      'created_at': createdAt.toIso8601String(), // Format DateTime to ISO8601 string
    };
  }
}
