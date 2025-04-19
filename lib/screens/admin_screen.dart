import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestoreも利用
import '../config/vote_options.dart';
import '../models/group.dart';
import '../widgets/admin_category_results.dart';
import '../widgets/admin_chart.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child(
    'votes',
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Vote>? _votes;
  List<UserData> _adminUsers = [];
  bool _isLoading = true;
  int _selectedCategoryIndex = 0;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadVotes();
    _loadAdminUsers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadVotes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // RTDBからデータを取得
      final snapshot = await _database.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        List<Vote> votes = [];

        data.forEach((key, value) {
          // RTDBのデータをVoteオブジェクトに変換
          Map<String, String> selections = {};

          if (value['selections'] != null) {
            (value['selections'] as Map<dynamic, dynamic>).forEach((k, v) {
              selections[k.toString()] = v.toString();
            });
          }

          // タイムスタンプを処理（文字列からDateTime）
          DateTime timestamp;
          try {
            timestamp = DateTime.parse(value['timestamp'] ?? '');
          } catch (e) {
            timestamp = DateTime.now(); // フォールバック
          }

          votes.add(
            Vote(
              id: key.toString(),
              userId: value['uuid']?.toString() ?? '',
              timestamp: timestamp,
              selections: selections,
            ),
          );
        });

        setState(() {
          _votes = votes;
          _isLoading = false;
        });
      } else {
        setState(() {
          _votes = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('投票データ読み込みエラー: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 管理者ユーザーの一覧を取得
  Future<void> _loadAdminUsers() async {
    try {
      // Firestoreから管理者ユーザー情報を取得
      final snapshot = await _firestore.collection('admin_users').get();
      List<UserData> users = [];

      for (var doc in snapshot.docs) {
        users.add(
          UserData(
            uid: doc.id,
            email: doc['email'],
            name: doc['name'] ?? '',
            createdAt: (doc['createdAt'] as Timestamp).toDate(),
          ),
        );
      }

      setState(() {
        _adminUsers = users;
      });
    } catch (e) {
      print('管理者ユーザー読み込みエラー: $e');
    }
  }

  // 特定のカテゴリーの集計結果を取得
  Map<String, int> _getCategoryResults(String categoryId) {
    Map<String, int> results = {};

    if (_votes == null) return results;

    for (var vote in _votes!) {
      if (vote.selections.containsKey(categoryId)) {
        String groupId = vote.selections[categoryId]!;
        results[groupId] = (results[groupId] ?? 0) + 1;
      }
    }

    return results;
  }

  // 票数でソートしたグループリストを取得
  List<MapEntry<Group, int>> _getSortedResults(String categoryId) {
    final results = _getCategoryResults(categoryId);
    final category = voteCategories.firstWhere((c) => c.id == categoryId);

    List<MapEntry<Group, int>> sortedResults = [];

    for (var group in category.groups) {
      int votes = results[group.id] ?? 0;
      sortedResults.add(MapEntry(group, votes));
    }

    // 票数の多い順にソート
    sortedResults.sort((a, b) => b.value.compareTo(a.value));

    return sortedResults;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('管理画面'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _loadVotes();
              _loadAdminUsers();
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.of(context).pop(); // 管理画面を閉じる
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '投票結果', icon: Icon(Icons.poll)),
            Tab(text: 'ユーザー管理', icon: Icon(Icons.people)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 投票結果タブ
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  _buildCategoryTabs(),
                  Expanded(
                    child:
                        _votes == null || _votes!.isEmpty
                            ? Center(child: Text('投票データがありません'))
                            : _buildCategoryResults(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.delete),
                      label: Text('投票データをクリア'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _showClearConfirmation,
                    ),
                  ),
                ],
              ),

          // ユーザー管理タブ
          _buildUserManagementTab(),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: voteCategories.length,
        itemBuilder: (context, index) {
          final category = voteCategories[index];
          final isSelected = index == _selectedCategoryIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  category.name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryResults() {
    final category = voteCategories[_selectedCategoryIndex];
    final results = _getSortedResults(category.id);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            '${category.name} の結果',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            '総投票数: ${_votes?.length ?? 0}票',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          SizedBox(height: 24),

          // 上位3位の結果表示
          AdminCategoryResults(results: results),

          SizedBox(height: 24),

          // チャート表示
          Expanded(child: AdminChart(results: results)),
        ],
      ),
    );
  }

  // ユーザー管理タブ
  Widget _buildUserManagementTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '管理者ユーザー一覧',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),

          // ユーザー一覧
          Expanded(
            child:
                _adminUsers.isEmpty
                    ? Center(child: Text('管理者ユーザーがいません'))
                    : ListView.builder(
                      itemCount: _adminUsers.length,
                      itemBuilder: (context, index) {
                        final user = _adminUsers[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(child: Icon(Icons.person)),
                            title: Text(user.email),
                            subtitle: Text(
                              '${user.name.isNotEmpty ? user.name + ' • ' : ''}追加日: ${_formatDate(user.createdAt)}',
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed:
                                  () => _showDeleteUserConfirmation(user),
                            ),
                          ),
                        );
                      },
                    ),
          ),

          // 新規ユーザー追加ボタン
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(Icons.person_add),
              label: Text('新規管理者を追加'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _showAddUserDialog,
            ),
          ),
        ],
      ),
    );
  }

  // 日付フォーマット
  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }

  // 投票データ削除確認ダイアログ
  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('全投票データを削除'),
            content: Text('すべての投票データを削除します。この操作は元に戻せません。'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('キャンセル'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _clearAllVotes();
                  _loadVotes();
                },
                child: Text('削除する', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  // ユーザー削除確認ダイアログ
  void _showDeleteUserConfirmation(UserData user) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('管理者を削除'),
            content: Text('${user.email} を管理者から削除しますか？'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('キャンセル'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _deleteAdminUser(user);
                },
                child: Text('削除する', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  // 新規ユーザー追加ダイアログ
  void _showAddUserDialog() {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text('新規管理者を追加'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'メールアドレス',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'パスワード',
                            border: OutlineInputBorder(),
                            helperText: '※ 6文字以上入力してください',
                          ),
                          obscureText: true,
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: '名前（任意）',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        if (isLoading)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed:
                          isLoading
                              ? null
                              : () {
                                Navigator.of(context).pop();
                              },
                      child: Text('キャンセル'),
                    ),
                    TextButton(
                      onPressed:
                          isLoading
                              ? null
                              : () async {
                                if (emailController.text.isEmpty ||
                                    passwordController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('メールアドレスとパスワードを入力してください'),
                                    ),
                                  );
                                  return;
                                }

                                if (passwordController.text.length < 6) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('パスワードは6文字以上入力してください'),
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  isLoading = true;
                                });

                                try {
                                  await _createAdminUser(
                                    email: emailController.text.trim(),
                                    password: passwordController.text,
                                    name: nameController.text.trim(),
                                  );
                                  Navigator.of(context).pop();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('管理者を追加しました')),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('エラーが発生しました: $e')),
                                  );
                                } finally {
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              },
                      child: Text('追加'),
                    ),
                  ],
                ),
          ),
    );
  }

  // 投票データをすべて削除
  Future<void> _clearAllVotes() async {
    try {
      // 親ノードを空に
      await _database.remove();
      print('すべての投票が削除されました');
    } catch (e) {
      print('投票削除エラー: $e');
    }
  }

  // 新規管理者ユーザーを作成
  Future<void> _createAdminUser({
    required String email,
    required String password,
    String name = '',
  }) async {
    try {
      // 新規ユーザー作成
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Firestoreにユーザー情報を保存
      await _firestore
          .collection('admin_users')
          .doc(userCredential.user!.uid)
          .set({
            'email': email,
            'name': name,
            'createdAt': FieldValue.serverTimestamp(),
            'createdBy': _auth.currentUser?.email ?? 'unknown',
          });

      // ユーザー一覧を再取得
      await _loadAdminUsers();
    } catch (e) {
      print('ユーザー作成エラー: $e');
      throw e;
    }
  }

  // 管理者ユーザーを削除
  Future<void> _deleteAdminUser(UserData user) async {
    try {
      // まずそのユーザーでサインイン
      final currentUser = _auth.currentUser;

      // 自分自身は削除できないようにする
      if (currentUser?.email == user.email) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('現在ログイン中のユーザーは削除できません')));
        return;
      }

      // Firestoreからユーザー情報を削除
      await _firestore.collection('admin_users').doc(user.uid).delete();

      // ユーザー一覧を再取得
      await _loadAdminUsers();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${user.email} を削除しました')));
    } catch (e) {
      print('ユーザー削除エラー: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('エラーが発生しました: $e')));
    }
  }
}

class Vote {
  final String id;
  final String userId;
  final DateTime timestamp;
  final Map<String, String> selections;

  Vote({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.selections,
  });
}

class UserData {
  final String uid;
  final String email;
  final String name;
  final DateTime createdAt;

  UserData({
    required this.uid,
    required this.email,
    required this.name,
    required this.createdAt,
  });
}
