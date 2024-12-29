import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';
import './modal_window.dart';

class UserListPage extends StatefulWidget {
  final String currentUserId;

  const UserListPage({super.key, required this.currentUserId});

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  String _searchQuery = '';

  // Method to update the online status of the current user
  void setOnlineStatus(bool status) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'isOnline': status});
      }
    } catch (e) {
      print("Error setting online status: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    // Set the user as online when the page is initialized
    setOnlineStatus(true);
  }

  // Stream to get users with their latest messages
  Stream<List<Map<String, dynamic>>> _getUserListWithMessages() {
    return FirebaseFirestore.instance.collection('users').snapshots().asyncMap(
      (userSnapshot) async {
        final userDocs = userSnapshot.docs;

        List<Map<String, dynamic>> userWithMessages = [];
        for (var userDoc in userDocs) {
          final userData = userDoc.data();
          final userId = userData['uid'];

          if (userId == widget.currentUserId) continue;

          final lastMessageQuery = await FirebaseFirestore.instance
              .collection('messages')
              .where('senderId', whereIn: [widget.currentUserId, userId])
              .where('receiverId', whereIn: [widget.currentUserId, userId])
              .orderBy('timestamp', descending: true)
              .limit(1)
              .get();

          final lastMessage = lastMessageQuery.docs.isNotEmpty
              ? MessageModel.fromMap(lastMessageQuery.docs.first.data())
              : null;

          userWithMessages.add({
            'user': UserModel.fromMap(userData),
            'lastMessage': lastMessage,
          });
        }

        userWithMessages.sort((a, b) {
          final aTimestamp = a['lastMessage']?.timestamp ?? DateTime(0);
          final bTimestamp = b['lastMessage']?.timestamp ?? DateTime(0);
          return bTimestamp.compareTo(aTimestamp);
        });

        return userWithMessages;
      },
    );
  }

  void _showLogoutModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => LogoutModal(
        onConfirm: () async {
          await FirebaseAuth.instance.signOut();
          setOnlineStatus(
              false); // Set the current user as offline when logging out
          Navigator.pushReplacementNamed(context, '/logout');
        },
        onCancel: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[300],
            child: Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () => _showLogoutModal(context),
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              // Listen to user data changes
              stream: _getUserListWithMessages(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: const Color.fromARGB(255, 14, 130, 225),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No users found.'));
                }

                final userWithMessages = snapshot.data!.where((userData) {
                  final user = userData['user'] as UserModel;
                  return user.email
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase());
                }).toList();

                if (userWithMessages.isEmpty) {
                  return Center(
                    child: Text(
                      'NO USERS FOUND',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: userWithMessages.length,
                  itemBuilder: (context, index) {
                    final user = userWithMessages[index]['user'] as UserModel;
                    final lastMessage =
                        userWithMessages[index]['lastMessage'] as MessageModel?;
                    final emailPrefix = user.email.split('@').first;

                    return Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 4.0,
                                spreadRadius: 1.0,
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: Stack(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blueGrey,
                                  backgroundImage: NetworkImage(
                                    user.avatarUrl ??
                                        'https://via.placeholder.com/150',
                                  ),
                                  child: user.avatarUrl == null
                                      ? Text(
                                          emailPrefix[0].toUpperCase(),
                                          style: TextStyle(color: Colors.white),
                                        )
                                      : null,
                                ),
                                if (user.isOnline)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            title: Text(
                              user.uid == widget.currentUserId
                                  ? 'Saved Message'
                                  : emailPrefix,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              lastMessage?.content ?? 'No messages yet.',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey),
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/chatbox',
                                arguments: user.uid,
                              );
                            },
                          ),
                        ),
                        Divider(),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
