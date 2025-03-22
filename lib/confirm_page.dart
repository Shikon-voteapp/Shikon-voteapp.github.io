import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConfirmPage extends StatelessWidget {
  final String uuid;
  final String vote;
  const ConfirmPage({super.key, required this.uuid, required this.vote});

  Future<void> submitVote(BuildContext context) async {
    final docRef = FirebaseFirestore.instance.collection("votes").doc(uuid);
    final doc = await docRef.get();

    if (doc.exists) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("すでに投票済みです")));
      return;
    }

    await docRef.set({
      "uuid": uuid,
      "vote": vote,
      "timestamp": FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("投票が完了しました！")));

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("投票確認")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("投票先: $vote", style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => submitVote(context),
              child: const Text("投票を確定"),
            ),
          ],
        ),
      ),
    );
  }
}
