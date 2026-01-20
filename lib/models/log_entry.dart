class LogEntry {
  final DateTime timestamp;
  final String type;
  final String message;
  final Map<String, dynamic>? data;

  LogEntry({
    required this.timestamp,
    required this.type,
    required this.message,
    this.data,
  });

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: json['type'] as String,
      message: json['message'] as String,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'message': message,
      if (data != null) 'data': data,
    };
  }

  LogEntry copyWith({
    DateTime? timestamp,
    String? type,
    String? message,
    Map<String, dynamic>? data,
  }) {
    return LogEntry(
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}
