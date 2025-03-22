import 'package:flutter/material.dart';
import 'confirm_page.dart';

class VotePage extends StatefulWidget {
  final String uuid;
  const VotePage({super.key, required this.uuid});

  @override
  State<VotePage> createState() => _VotePageState();
}

class _VotePageState extends State<VotePage> {
  String? selectedGroup;

  final List<Map<String, String>> groups = [
    {"id": "A", "name": "団体A", "image": "assets/group_a.png"},
    {"id": "B", "name": "団体B", "image": "assets/group_b.png"},
    {"id": "C", "name": "団体C", "image": "assets/group_c.png"},
    {"id": "D", "name": "団体D", "image": "assets/group_d.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("投票画面")),
      body: ListView(
        children:
            groups.map((group) {
              bool isSelected = selectedGroup == group["id"];
              return ListTile(
                leading: Image.asset(group["image"]!),
                title: Text(group["name"]!),
                tileColor: isSelected ? Colors.redAccent : null,
                onTap: () => setState(() => selectedGroup = group["id"]),
              );
            }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            selectedGroup != null
                ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ConfirmPage(
                            uuid: widget.uuid,
                            vote: selectedGroup!,
                          ),
                    ),
                  );
                }
                : null,
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
