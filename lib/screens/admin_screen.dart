import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/vote_options.dart';
import '../models/group.dart';
import '../widgets/main_layout.dart';
import '../widgets/admin_category_results.dart';
import '../widgets/admin_chart.dart';
import '../widgets/admin_pie_chart.dart';
import 'scanner_screen.dart';
// import 'selection_screen.dart';
import '../widgets/custom_dialog.dart';
import 'config_editor_screen.dart';
import '../platform/platform_utils.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with TickerProviderStateMixin {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child(
    'votes',
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Vote>? _votes;
  List<UserData> _adminUsers = [];
  bool _isLoading = true;
  bool _isLoggedIn = false;
  int _selectedCategoryIndex = 0;

  late TabController _tabController;
  late TabController _categoryTabController;

  @override
  void initState() {
    super.initState();
    _checkLoginAndLoadData();
  }

  Future<void> _checkLoginAndLoadData() async {
    setState(() {
      _isLoading = true;
    });

    final user = _auth.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _isLoggedIn = false;
      });

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder:
                (dialogContext) => AlertDialog(
                  title: const Text('認証が必要です'),
                  content: const Text('このページを表示するには管理者ログインが必要です。'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil('/scanner', (route) => false);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
          );
        });
      }
    } else {
      setState(() {
        _isLoggedIn = true;
      });
      _initializeControllers();
      await _loadAllData();
    }
  }

  void _initializeControllers() {
    _tabController = TabController(length: 3, vsync: this);
    _categoryTabController = TabController(
      length: voteCategories.length,
      vsync: this,
    );
    _categoryTabController.addListener(() {
      if (mounted && !_categoryTabController.indexIsChanging) {
        setState(() {
          _selectedCategoryIndex = _categoryTabController.index;
        });
      }
    });
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    await Future.wait([_loadVotes(), _loadAdminUsers()]);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _categoryTabController.dispose();
    super.dispose();
  }

  Future<void> _loadVotes() async {
    try {
      final snapshot = await _database.get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        List<Vote> votes = [];

        data.forEach((key, value) {
          Map<String, String> selections = {};
          if (value['selections'] != null) {
            (value['selections'] as Map<dynamic, dynamic>).forEach((k, v) {
              selections[k.toString()] = v.toString();
            });
          }
          DateTime timestamp;
          try {
            timestamp = DateTime.parse(value['timestamp'] ?? '');
          } catch (e) {
            timestamp = DateTime.now();
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
        setState(() => _votes = votes);
      } else {
        setState(() => _votes = []);
      }
    } catch (e) {
      print('投票データ読み込みエラー: $e');
      setState(() => _votes = []);
    }
  }

  Future<void> _loadAdminUsers() async {
    try {
      final snapshot = await _firestore.collection('admin_users').get();
      List<UserData> users =
          snapshot.docs
              .map(
                (doc) => UserData(
                  uid: doc.id,
                  email: doc['email'],
                  name: doc['name'] ?? '',
                  createdAt: (doc['createdAt'] as Timestamp).toDate(),
                ),
              )
              .toList();
      setState(() => _adminUsers = users);
    } catch (e) {
      print('管理者ユーザー読み込みエラー: $e');
    }
  }

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

  List<MapEntry<Group, int>> _getSortedResults(String categoryId) {
    final results = _getCategoryResults(categoryId);
    final category = voteCategories.firstWhere((c) => c.id == categoryId);
    List<MapEntry<Group, int>> sortedResults = [];
    for (var group in category.groups) {
      sortedResults.add(MapEntry(group, results[group.id] ?? 0));
    }
    sortedResults.sort((a, b) => b.value.compareTo(a.value));
    return sortedResults;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || !_isLoggedIn) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return MainLayout(
      title: '管理者パネル',
      icon: Icons.admin_panel_settings,
      onHome:
          () => Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/scanner', (route) => false),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: '投票結果', icon: Icon(Icons.poll)),
              Tab(text: 'ユーザー管理', icon: Icon(Icons.people)),
              Tab(text: '設定エディタ', icon: Icon(Icons.settings)),
            ],
          ),
          actions: [
            IconButton(icon: Icon(Icons.refresh), onPressed: _loadAllData),
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await _auth.signOut();
                if (mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/selection', (route) => false);
                }
              },
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildResultsTab(),
            _buildUserManagementTab(),
            _buildConfigEditorTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsTab() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 60.0),
          child:
              _votes == null || _votes!.isEmpty
                  ? Center(child: Text('投票データがありません'))
                  : _buildCategoryResults(),
        ),
        Positioned(bottom: 0, left: 0, right: 0, child: _buildCategoryTabs()),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      margin: const EdgeInsets.all(8.0),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _categoryTabController,
        isScrollable: true,
        tabAlignment: TabAlignment.center,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorSize: TabBarIndicatorSize.label,
        tabs:
            voteCategories.map((category) => Tab(text: category.name)).toList(),
      ),
    );
  }

  Widget _buildCategoryResults() {
    final category = voteCategories[_selectedCategoryIndex];
    final results = _getSortedResults(category.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${category.name} の結果',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 8),
          Text(
            '総投票数: ${_votes?.length ?? 0}票',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 24),
          AdminCategoryResults(results: results),
          SizedBox(height: 24),
          SizedBox(height: 300, child: AdminChart(results: results)),
          SizedBox(height: 24),
          SizedBox(height: 300, child: AdminPieChart(results: results)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.delete_sweep),
                label: Text('全投票データをクリア'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: _showClearConfirmation,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserManagementTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('管理者一覧', style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: 16),
          ElevatedButton.icon(
            icon: Icon(Icons.qr_code_scanner),
            label: Text('QRコードスキャナーを起動'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ScannerScreen(startWithScanner: true),
                ),
              );
            },
          ),
          SizedBox(height: 16),
          _adminUsers.isEmpty
              ? Center(child: Text('管理者がいません'))
              : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
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
                        onPressed: () => _showDeleteUserConfirmation(user),
                      ),
                    ),
                  );
                },
              ),
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

  Widget _buildConfigEditorTab() {
    return const ConfigEditorScreen();
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }

  void _showClearConfirmation() {
    showCustomDialog(
      context: context,
      title: '全投票データを削除',
      content: 'すべての投票データを削除します。この操作は元に戻せません。よろしいですか？',
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('キャンセル'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await _database.remove();
            _loadAllData();
          },
          child: Text('削除する'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
      ],
    );
  }

  void _showDeleteUserConfirmation(UserData user) {
    showCustomDialog(
      context: context,
      title: '管理者を削除',
      content: '${user.email} を管理者から削除しますか？\nこの操作は元に戻せません。',
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('キャンセル'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await _deleteAdminUser(user);
          },
          child: Text('削除する'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
      ],
    );
  }

  void _showAddUserDialog() {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showCustomDialog(
      context: context,
      title: '新規管理者を追加',
      contentWidget: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'メールアドレス'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) => value!.isEmpty ? 'メールアドレスを入力してください' : null,
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'パスワード (6文字以上)'),
              obscureText: true,
              validator: (value) => value!.length < 6 ? '6文字以上で入力してください' : null,
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: '名前 (任意)'),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('キャンセル'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
        ),
        ElevatedButton(
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              try {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder:
                      (context) => Center(child: CircularProgressIndicator()),
                );

                await _createAdminUser(
                  email: emailController.text.trim(),
                  password: passwordController.text,
                  name: nameController.text.trim(),
                );

                Navigator.of(context).pop();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('管理者を追加しました')));
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('エラー: ${e.toString()}')));
              }
            }
          },
          child: Text('追加'),
        ),
      ],
    );
  }

  Future<void> _createAdminUser({
    required String email,
    required String password,
    String name = '',
  }) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _firestore
        .collection('admin_users')
        .doc(userCredential.user!.uid)
        .set({
          'email': email,
          'name': name,
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': _auth.currentUser?.email ?? 'unknown',
        });
    _loadAdminUsers();
  }

  Future<void> _deleteAdminUser(UserData user) async {
    if (_auth.currentUser?.uid == user.uid) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('自分自身を削除することはできません')));
      return;
    }
    await _firestore.collection('admin_users').doc(user.uid).delete();
    _loadAdminUsers();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${user.email} を削除しました')));
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
