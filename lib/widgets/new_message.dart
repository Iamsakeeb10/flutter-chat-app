import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _sendMessages() async {
    final enteredMessage = _inputController.text.trim();

    if (enteredMessage.isEmpty) return;

    _inputController.clear();
    if (mounted) {
      FocusScope.of(context).unfocus();
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You must be logged in to send messages.")),
      );
      return;
    }

    try {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      print('🟨 ${userData.data()}');

      await FirebaseFirestore.instance.collection('chat').add({
        'text': enteredMessage,
        'createdAt': Timestamp.now(),
        'userId': user.uid,
        'username': userData.data()?['username'] ?? 'Unknown',
        'userImage': userData.data()?['image_base64'] ?? '',
      });
    } catch (error) {
      print("💥 Error sending message: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send message. Try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: TextStyle(color: Colors.white),
              autocorrect: true,
              controller: _inputController,
              decoration: InputDecoration(
                labelText: 'Send a message...',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  // Change default underline color
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: UnderlineInputBorder(
                  // Change focused underline color
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ),
              enableSuggestions: true,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          IconButton(
            onPressed: _sendMessages,
            icon: Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
