import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../models/message_model.dart';
import '../helper/s3_uploader.dart';

class ChatBoxPage extends StatefulWidget {
  final String receiverId;
  // reciever name
  

  const ChatBoxPage({super.key, required this.receiverId});

  @override
  _ChatBoxPageState createState() => _ChatBoxPageState();
}

class _ChatBoxPageState extends State<ChatBoxPage> {
  final TextEditingController _messageController = TextEditingController();
  late String _currentUserId;

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _currentUserId = currentUser.uid;
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _sendMessage({String? content, String? fileUrl, String? fileName}) {
    if ((content == null || content.trim().isEmpty) && fileUrl == null) return;

    final message = MessageModel(
      senderId: _currentUserId,
      receiverId: widget.receiverId,
      content: content ?? '',
      timestamp: DateTime.now(),
      fileUrl: fileUrl,
      fileName: fileName,
    );
    

    FirebaseFirestore.instance.collection('messages').add(message.toMap());
    _messageController.clear();
  }

  Future<void> _sendFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(withData: true);

      if (result != null) {
        final fileBytes = result.files.single.bytes;
        final filePath = result.files.single.path;
        final fileName = result.files.single.name;

        String uploadedFileUrl;

        if (fileBytes != null) {
          final extension = fileName.split('.').last;
          uploadedFileUrl =
              await S3Uploader.uploadFileBytes(fileBytes, extension);
        } else if (filePath != null) {
          uploadedFileUrl = await S3Uploader.uploadFile(File(filePath));
        } else {
          throw Exception("No valid file selected.");
        }

        _sendMessage(fileUrl: uploadedFileUrl, fileName: fileName);
      }
    } catch (e) {
      print('Error picking or uploading file: $e');
    }
  }

  // Format timestamp to display time in AM/PM format
  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour % 12;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = timestamp.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background for the entire screen
      appBar: AppBar(
        title: Text('Chat with ${widget.receiverId}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('senderId',
                      whereIn: [_currentUserId, widget.receiverId])
                  .where('receiverId',
                      whereIn: [_currentUserId, widget.receiverId])
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Start the conversation!'));
                }

                final messages = snapshot.data!.docs.map((doc) {
                  return MessageModel.fromMap(
                      doc.data() as Map<String, dynamic>);
                }).toList();

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isSender = message.senderId == _currentUserId;
                    final formattedTime = _formatTime(message.timestamp);

                    return Align(
                      alignment: isSender
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8.0),
                        padding: EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isSender
                              ? Colors.blue[300] // Blue for sender
                              : Colors.grey[300], // Whitish for receiver
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(8.0),
                            bottomLeft:
                                isSender ? Radius.circular(8.0) : Radius.zero,
                            bottomRight:
                                isSender ? Radius.zero : Radius.circular(8.0),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (message.fileUrl != null)
                              GestureDetector(
                                onTap: () {
                                  // Handle file opening logic, e.g., with url_launcher.
                                },
                                child: Column(
                                  children: [
                                    Icon(Icons.insert_drive_file,
                                        color: Colors.blue),
                                    Text(
                                      message.fileName ?? 'File',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (message.content.isNotEmpty)
                              Text(
                                message.content,
                                style: TextStyle(fontSize: 16.0),
                              ),
                            if (formattedTime.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  formattedTime,
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.black45,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.attachment),
                  onPressed: _sendFile,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () =>
                      _sendMessage(content: _messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
