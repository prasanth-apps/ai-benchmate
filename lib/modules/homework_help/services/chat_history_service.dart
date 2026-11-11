import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/chat_message.dart';

class ChatHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user's conversations collection.
  CollectionReference<Map<String, dynamic>> get _conversations {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Please log in to access chat history.');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('conversations');
  }

  // Create a new conversation.
  Future<String> createConversation(String title) async {
    final doc = await _conversations.add({
      'title': title,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  // Save a message inside a conversation.
  Future<void> saveMessage(String conversationId, ChatMessage message) async {
    await _conversations
        .doc(conversationId)
        .collection('messages')
        .doc(message.id)
        .set(message.toMap());

    await _conversations.doc(conversationId).update({
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get all conversations, newest first.
  Stream<QuerySnapshot<Map<String, dynamic>>> getConversations() {
    return _conversations.orderBy('updatedAt', descending: true).snapshots();
  }

  // Get messages from a conversation.
  Stream<List<ChatMessage>> getMessages(String conversationId) {
    return _conversations
        .doc(conversationId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatMessage.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  // Delete a conversation and its messages.

  Future<void> deleteConversation(String conversationId) async {
    final messagesCollection = _conversations
        .doc(conversationId)
        .collection('messages');

    while (true) {
      final snapshot = await messagesCollection.limit(450).get();

      if (snapshot.docs.isEmpty) {
        break;
      }

      final batch = _firestore.batch();

      for (final message in snapshot.docs) {
        batch.delete(message.reference);
      }

      await batch.commit();
    }

    await _conversations.doc(conversationId).delete();
  }
}
