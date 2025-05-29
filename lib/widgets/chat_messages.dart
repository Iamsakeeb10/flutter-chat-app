import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.white));
        }

        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No messages found...',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        if (chatSnapshots.hasError) {
          return Center(
            child: Text(
              'Something went wrong...',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        final loadedMessages = chatSnapshots.data!.docs;

        return ListView.builder(
          padding: EdgeInsets.only(bottom: 40, right: 20, left: 20),
          itemCount: loadedMessages.length,
          reverse: true,
          itemBuilder: (context, index) {
            final chatMessage = loadedMessages[index].data();

            final nextChatMessage = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1].data()
                : null;

            final currentMessageUserId = chatMessage['userId'];
            final nextMessageUserId = nextChatMessage != null
                ? nextChatMessage['userId']
                : null;

            final nextUserIsSame = nextMessageUserId == currentMessageUserId;

            if (nextUserIsSame) {
              return MessageBubble.next(
                message: chatMessage['text'],
                isMe: currentUser.uid == currentMessageUserId,
              );
            } else {
              return MessageBubble.first(
                userImage: chatMessage['userImage'],
                username: chatMessage['username'],
                message: chatMessage['text'],
                isMe: currentUser.uid == currentMessageUserId,
              );
            }
          },
        );
      },
    );
  }
}
