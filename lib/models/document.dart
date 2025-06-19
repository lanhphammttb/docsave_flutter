class Document {
  final String id;
  final String title;
  final String type; // 'text', 'file', 'link'
  final String topic;
  final String category;
  final String userEmail;
  final String? content; // chỉ có khi type = 'text'
  final String? fileName; // chỉ có khi type = 'file'
  final String? fileType; // chỉ có khi type = 'file'
  final String? link; // chỉ có khi type = 'link'
  final DateTime createdAt;
  final DateTime updatedAt;

  Document({
    required this.id,
    required this.title,
    required this.type,
    required this.topic,
    required this.category,
    required this.userEmail,
    this.content,
    this.fileName,
    this.fileType,
    this.link,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['_id'] ?? '', // MongoDB ObjectId
      title: json['title'] ?? '',
      type: json['type'] ?? 'text',
      topic: json['topic'] ?? '',
      category: json['category'] ?? '',
      userEmail: json['userEmail'] ?? '',
      content: json['content'],
      fileName: json['fileName'],
      fileType: json['fileType'],
      link: json['link'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'type': type,
      'topic': topic,
      'category': category,
      'userEmail': userEmail,
      'content': content,
      'fileName': fileName,
      'fileType': fileType,
      'link': link,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper getters
  String get displayTitle => title.isNotEmpty ? title : 'Untitled Document';

  String get typeIcon {
    switch (type.toLowerCase()) {
      case 'text':
        return '��';
      case 'file':
        return '📁';
      case 'link':
        return '🔗';
      default:
        return '📄';
    }
  }

  String get typeLabel {
    switch (type.toLowerCase()) {
      case 'text':
        return 'Text Document';
      case 'file':
        return 'File';
      case 'link':
        return 'Link';
      default:
        return 'Document';
    }
  }

  bool get isText => type == 'text';
  bool get isFile => type == 'file';
  bool get isLink => type == 'link';

  String get displayContent {
    if (isText && content != null) {
      return content!;
    } else if (isLink && link != null) {
      return link!;
    } else if (isFile && fileName != null) {
      return fileName!;
    }
    return 'No content available';
  }
}