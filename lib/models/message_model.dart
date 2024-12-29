import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final bool isRead; // Indicates if the message has been read
  final String? fileUrl; // URL for the uploaded file (if any)
  final String? fileName; // Name of the uploaded file (if any)

  MessageModel({
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    this.isRead = false, // Default to false
    this.fileUrl, // Optional field
    this.fileName, // Optional field
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp':
          Timestamp.fromDate(timestamp), // Store as Firestore Timestamp
      'isRead': isRead,
      'fileUrl': fileUrl, // Include file URL if present
      'fileName': fileName, // Include file name if present
    };
  }

  static MessageModel fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      content: map['content'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
      fileUrl: map['fileUrl'], // Extract file URL if present
      fileName: map['fileName'], // Extract file name if present
    );
  }
}
