import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter/material.dart';
// import 'package:hugeicons/hugeicons.dart';
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
// import 'config_editor_screen.dart';
import '../services/export_service.dart';
import '../platform/platform_utils.dart';
import '../widgets/liquid_glass.dart';


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
          showCustomDialog(
            context: context,
            title: '認証が必要です',
            content: 'このページを表示するには管理者ログインが必要です。',
            closeButtonText: 'OK',
          ).then((_) {
            if (mounted) {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/', (route) => false);
            }
          });
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
    _tabController = TabController(length: 2, vsync: this);
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
      if (mounted) {
        await showCustomDialog(
          context: context,
          title: 'エラー',
          content: '投票データの読み込みに失敗しました。',
          closeButtonText: '閉じる',
        );
      }
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
      if (mounted) {
        await showCustomDialog(
          context: context,
          title: 'エラー',
          content: '管理者ユーザーの読み込みに失敗しました。',
          closeButtonText: '閉じる',
        );
      }
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
          ).pushNamedAndRemoveUntil('/', (route) => false),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: TabBar(
            controller: _tabController,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: '投票結果', icon: Icon(Icons.poll)),
              Tab(text: 'ユーザー管理', icon: Icon(Icons.people)),
            ],
          ),
          actions: [
            _buildAppBarCircleButton(
              icon: Icons.refresh,
              onPressed: _loadAllData,
            ),
            _buildAppBarCircleButton(
              icon: Icons.file_download,
              onPressed: _exportResults,
            ),
            _buildAppBarCircleButton(
              icon: Icons.help,
              onPressed: _showHelpDialog,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _buildAppBarCircleButton(
                icon: Icons.logout,
                onPressed: () async {
                  await _auth.signOut();
                  if (mounted) {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/', (route) => false);
                  }
                },
              ),
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [_buildResultsTab(), _buildUserManagementTab()],
        ),
      ),
    );
  }

  Future<void> _exportResults() async {
    try {
      final bytes = ExportService.buildResultsWorkbook(_getSortedResults);
      final now = DateTime.now();
      final filename =
          '投票結果_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}.xlsx';
      PlatformUtils.downloadBytes(
        bytes,
        filename,
        mimeType:
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );
      await showCustomDialog(
        context: context,
        title: 'エクスポート完了',
        content: 'Excelファイルを保存しました。',
        closeButtonText: 'OK',
      );
    } catch (e) {
      await showCustomDialog(
        context: context,
        title: 'エクスポート失敗',
        content: 'エクスポート中にエラー: ${e.toString()}',
        closeButtonText: '閉じる',
      );
    }
  }

  void _showHelpDialog() {
    showCustomDialog(
      context: context,
      title: 'ヘルプ',
      content: '管理者パネルの詳細な使用方法については、以下の詳細情報をご覧ください。',
      showWikiLink: true,
      wikiUrl: 'https://shikon-voteapp.github.io/guide/public/',
      closeButtonText: '閉じる',
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final glassColor = isDark
        ? Colors.black.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.25);
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: LiquidGlassLayer(
        settings: LiquidGlassSettings(
          glassColor: glassColor,
          thickness: 10.0,
          blur: 15.0,
        ),
        child: LiquidGlass(
          shape: LiquidRoundedRectangle(borderRadius: 24.0),
          child: TabBar(
            controller: _categoryTabController,
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            labelColor: theme.primaryColor,
            unselectedLabelColor: Colors.grey,
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.label,
            tabs:
                voteCategories.map((category) => Tab(text: category.name)).toList(),
          ),
        ),
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
              child: _buildGlassButton(
                label: '全投票データをクリア',
                icon: Icons.delete_sweep,
                color: Theme.of(context).colorScheme.error,
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
          _buildGlassButton(
            label: 'QRコードスキャナーを起動',
            icon: Icons.qr_code_scanner,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ScannerScreen(startWithScanner: true),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _adminUsers.isEmpty
              ? const Center(child: Text('管理者がいません'))
              : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _adminUsers.length,
                itemBuilder: (context, index) {
                  final user = _adminUsers[index];
                  return _buildGlassCard(
                    child: ListTile(
                      tileColor: Colors.transparent,
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                        child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                      ),
                      title: Text(user.email, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        '${user.name.isNotEmpty ? user.name + ' • ' : ''}追加日: ${_formatDate(user.createdAt)}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteUserConfirmation(user),
                      ),
                    ),
                  );
                },
              ),
          const SizedBox(height: 16),
          _buildGlassButton(
            label: '新規管理者を追加',
            icon: Icons.person_add,
            onPressed: _showAddUserDialog,
          ),
        ],
      ),
    );
  }

  // 設定エディタ機能は管理画面から削除

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }

  void _showClearConfirmation() {
    showCustomDialog(
      context: context,
      title: '全投票データを削除',
      content: 'すべての投票データを削除します。この操作は元に戻せません。よろしいですか？',
      closeButtonText: 'キャンセル',
      primaryActionText: '削除する',
      onPrimaryAction: () async {
        Navigator.of(context).pop();
        await _database.remove();
        _loadAllData();
      },
    );
  }

  void _showDeleteUserConfirmation(UserData user) {
    showCustomDialog(
      context: context,
      title: '管理者を削除',
      content: '${user.email} を管理者から削除しますか？\nこの操作は元に戻せません。',
      closeButtonText: 'キャンセル',
      primaryActionText: '削除する',
      onPrimaryAction: () async {
        Navigator.of(context).pop();
        await _deleteAdminUser(user);
      },
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
      closeButtonText: 'キャンセル',
      primaryActionText: '追加',
      onPrimaryAction: () async {
        if (formKey.currentState!.validate()) {
          try {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder:
                  (context) => const Center(child: CircularProgressIndicator()),
            );

            await _createAdminUser(
              email: emailController.text.trim(),
              password: passwordController.text,
              name: nameController.text.trim(),
            );

            Navigator.of(context).pop();
            Navigator.of(context).pop();
            await showCustomDialog(
              context: context,
              title: '完了',
              content: '管理者を追加しました',
              closeButtonText: 'OK',
            );
          } catch (e) {
            Navigator.of(context).pop();
            await showCustomDialog(
              context: context,
              title: 'エラー',
              content: 'エラーが発生しました: ${e.toString()}',
              closeButtonText: '閉じる',
            );
          }
        }
      },
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
      await showCustomDialog(
        context: context,
        title: '操作できません',
        content: '自分自身を削除することはできません',
        closeButtonText: 'OK',
      );
      return;
    }
    await _firestore.collection('admin_users').doc(user.uid).delete();
    _loadAdminUsers();
    await showCustomDialog(
      context: context,
      title: '完了',
      content: '${user.email} を削除しました',
      closeButtonText: 'OK',
    );
  }

  Widget _buildGlassButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = color ?? theme.colorScheme.primary;
    final glassColor = isDark
        ? Colors.black.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.25);

    return LiquidGlassLayer(
      settings: LiquidGlassSettings(
        glassColor: glassColor,
        thickness: 10.0,
        blur: 15.0,
      ),
      child: LiquidGlass(
        shape: LiquidRoundedRectangle(borderRadius: 24.0),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24.0),
          child: Container(
            height: 48.0,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(24.0),
              border: Border.all(
                color: primary.withValues(alpha: 0.4),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: isDark ? Colors.white : primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : primary,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarCircleButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final glassColor = isDark
        ? Colors.black.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.25);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: LiquidGlassLayer(
        settings: LiquidGlassSettings(
          glassColor: glassColor,
          thickness: 10.0,
          blur: 12.0,
        ),
        child: LiquidGlass(
          shape: LiquidRoundedRectangle(borderRadius: 20.0),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(20.0),
            child: SizedBox(
              width: 40.0,
              height: 40.0,
              child: Center(
                child: Icon(
                  icon,
                  color: theme.colorScheme.onSurface,
                  size: 20.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final glassColor = isDark
        ? Colors.black.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.25);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: LiquidGlassLayer(
        settings: LiquidGlassSettings(
          glassColor: glassColor,
          thickness: 12.0,
          blur: 15.0,
        ),
        child: LiquidGlass(
          shape: LiquidRoundedRectangle(borderRadius: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: child,
          ),
        ),
      ),
    );
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
