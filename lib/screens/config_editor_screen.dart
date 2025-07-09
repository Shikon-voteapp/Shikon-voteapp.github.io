import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import '../models/group.dart' hide VoteCategory;
import '../models/vote_category.dart';
import '../config/vote_options.dart';
import '../platform/platform_utils.dart';

class ConfigEditorScreen extends StatefulWidget {
  const ConfigEditorScreen({super.key});

  @override
  State<ConfigEditorScreen> createState() => _ConfigEditorScreenState();
}

class _ConfigEditorScreenState extends State<ConfigEditorScreen> {
  VotingPeriodConfig? _votingPeriod;
  List<VoteCategory>? _categories;
  List<Group>? _groups;
  Map<GroupCategory, String>? _categoryNames;

  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _startTimeController.dispose();
    _endDateController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  void _loadCurrentConfig() {
    setState(() {
      _votingPeriod = defaultVotingPeriod;
      _categories =
          voteCategories.map((c) => VoteCategory.fromVoteCategory(c)).toList();
      _groups = List.from(allGroups);
      _categoryNames = Map.from(groupCategoryNames);
    });
    _updateDateControllers();
  }

  void _updateDateControllers() {
    _startDateController.text =
        '${_votingPeriod?.startDate.year}/${_votingPeriod?.startDate.month.toString().padLeft(2, '0')}/${_votingPeriod?.startDate.day.toString().padLeft(2, '0')}';
    _startTimeController.text =
        '${_votingPeriod?.startDate.hour.toString().padLeft(2, '0')}:${_votingPeriod?.startDate.minute.toString().padLeft(2, '0')}';
    _endDateController.text =
        '${_votingPeriod?.endDate.year}/${_votingPeriod?.endDate.month.toString().padLeft(2, '0')}/${_votingPeriod?.endDate.day.toString().padLeft(2, '0')}';
    _endTimeController.text =
        '${_votingPeriod?.endDate.hour.toString().padLeft(2, '0')}:${_votingPeriod?.endDate.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _loadVoteOptionsFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['dart'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        final dartCode = String.fromCharCodes(bytes);

        // Dartファイルから設定を解析
        _parseDartFile(dartCode);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('vote_options.dartファイルを読み込みました')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ファイル読み込みエラー: $e')));
    }
  }

  void _parseDartFile(String dartCode) {
    // 簡易的なDartファイル解析（実際の実装では、より堅牢な解析が必要）
    // この例では基本的な設定のみ抽出
    setState(() {
      // 既存の設定を保持（より詳細な解析は必要に応じて実装）
      _loadCurrentConfig();
    });
  }

  void _generateAndDownloadDartFile() {
    try {
      final dartContent = _generateVoteOptionsDart();

      // クリップボードにコピー
      Clipboard.setData(ClipboardData(text: dartContent));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('vote_options.dartの内容をクリップボードにコピーしました！'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('生成エラー: $e')));
    }
  }

  String _generateVoteOptionsDart() {
    final buffer = StringBuffer();

    // ファイルヘッダー
    buffer.writeln('// 自動生成されたvote_options.dartファイル');
    buffer.writeln('// 手動編集しないでください');
    buffer.writeln();
    buffer.writeln("import 'package:shikon_voteapp/models/group.dart';");
    buffer.writeln(
      "import 'package:shikon_voteapp/models/vote_category.dart';",
    );
    buffer.writeln();

    // 投票期間設定
    buffer.writeln('// 投票期間設定');
    buffer.writeln(
      'final VotingPeriodConfig defaultVotingPeriod = VotingPeriodConfig(',
    );
    buffer.writeln(
      '  startDate: DateTime(${_votingPeriod?.startDate.year}, ${_votingPeriod?.startDate.month}, ${_votingPeriod?.startDate.day}, ${_votingPeriod?.startDate.hour}, ${_votingPeriod?.startDate.minute}),',
    );
    buffer.writeln(
      '  endDate: DateTime(${_votingPeriod?.endDate.year}, ${_votingPeriod?.endDate.month}, ${_votingPeriod?.endDate.day}, ${_votingPeriod?.endDate.hour}, ${_votingPeriod?.endDate.minute}),',
    );
    buffer.writeln(
      '  maintenanceEnabled: ${_votingPeriod?.maintenanceEnabled},',
    );
    buffer.writeln(
      '  maintenanceStartHour: ${_votingPeriod?.maintenanceStartHour},',
    );
    buffer.writeln(
      '  maintenanceEndHour: ${_votingPeriod?.maintenanceEndHour},',
    );
    buffer.writeln(');');
    buffer.writeln();

    // グループカテゴリ名
    buffer.writeln('// グループカテゴリ名');
    buffer.writeln('final Map<GroupCategory, String> groupCategoryNames = {');
    _categoryNames?.forEach((category, name) {
      buffer.writeln(
        '  GroupCategory.${category.toString().split('.').last}: \'$name\',',
      );
    });
    buffer.writeln('};');
    buffer.writeln();

    // 全グループ
    buffer.writeln('// 全グループ');
    buffer.writeln('final List<Group> allGroups = [');
    for (final group in _groups ?? []) {
      buffer.writeln('  Group(');
      buffer.writeln('    id: \'${group.id}\',');
      buffer.writeln('    name: \'${group.name}\',');
      buffer.writeln('    groupName: \'${group.groupName}\',');
      buffer.writeln('    description: \'${group.description}\',');
      buffer.writeln(
        '    categories: [${group.categories.map((c) => 'GroupCategory.${c.toString().split('.').last}').join(', ')}],',
      );
      buffer.writeln('    floor: ${group.floor},');
      buffer.writeln('    imagePath: \'${group.imagePath}\',');
      if (group.pamphletPage != null) {
        buffer.writeln('    pamphletPage: ${group.pamphletPage},');
      }
      buffer.writeln('  ),');
    }
    buffer.writeln('];');
    buffer.writeln();

    // 投票カテゴリ
    buffer.writeln('// 投票カテゴリ');
    buffer.writeln('final List<VoteCategory> voteCategories = [');
    for (final category in _categories ?? []) {
      buffer.writeln('  VoteCategory(');
      buffer.writeln('    id: \'${category.id}\',');
      buffer.writeln('    name: \'${category.name}\',');
      buffer.writeln('    description: \'${category.description}\',');
      buffer.writeln('    groups: allGroups.where((g) => [');
      for (final group in category.groups) {
        buffer.writeln('      \'${group.id}\',');
      }
      buffer.writeln('    ].contains(g.id)).toList(),');
      buffer.writeln('    canSkip: ${category.canSkip},');
      if (category.helpUrl != null) {
        buffer.writeln('    helpUrl: \'${category.helpUrl}\',');
      }
      if (category.shortHelpText != null) {
        buffer.writeln('    shortHelpText: \'${category.shortHelpText}\',');
      }
      buffer.writeln('  ),');
    }
    buffer.writeln('];');

    return buffer.toString();
  }

  void _updateVotingPeriod(DateTime startDate, DateTime endDate) {
    setState(() {
      _votingPeriod = VotingPeriodConfig(
        startDate: startDate,
        endDate: endDate,
        maintenanceEnabled: _votingPeriod?.maintenanceEnabled ?? false,
        maintenanceStartHour: _votingPeriod?.maintenanceStartHour ?? 0,
        maintenanceEndHour: _votingPeriod?.maintenanceEndHour ?? 0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            Container(
              color: Theme.of(context).primaryColor,
              child: const TabBar(
                tabs: [
                  Tab(text: 'ファイル', icon: Icon(Icons.folder_open)),
                  Tab(text: '投票期間', icon: Icon(Icons.schedule)),
                  Tab(text: '団体編集', icon: Icon(Icons.groups)),
                  Tab(text: 'カテゴリ編集', icon: Icon(Icons.category)),
                ],
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildFileTab(),
                  _buildVotingPeriodTab(),
                  _buildGroupsTab(),
                  _buildCategoriesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ファイル操作',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '既存ファイルの読み込み',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadVoteOptionsFile,
                    icon: const Icon(Icons.file_upload),
                    label: const Text('vote_options.dartを読み込み'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    '設定ファイルの生成',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      final content = _generateVoteOptionsDart();
                      final timestamp = DateTime.now().millisecondsSinceEpoch;
                      PlatformUtils.downloadFile(
                        content,
                        'vote_options_$timestamp.dart',
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ファイルをダウンロードしました')),
                        );
                      }
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('vote_options.dartをダウンロード'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '使用方法:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text('1. 既存のvote_options.dartファイルを読み込み'),
                  const Text('2. 各タブで設定を編集'),
                  const Text('3. vote_options.dartをクリップボードにコピー または ダウンロード'),
                  const Text(
                    '4. コピーまたはダウンロードした内容でlib/config/vote_options.dartを置き換え',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVotingPeriodTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '投票期間設定',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _startDateController,
                          decoration: const InputDecoration(
                            labelText: '開始日 (YYYY/MM/DD)',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate:
                                  _votingPeriod?.startDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (date != null) {
                              final newStart = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                _votingPeriod?.startDate.hour ?? 0,
                                _votingPeriod?.startDate.minute ?? 0,
                              );
                              _updateVotingPeriod(
                                newStart,
                                _votingPeriod?.endDate ?? DateTime.now(),
                              );
                              _updateDateControllers();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _startTimeController,
                          decoration: const InputDecoration(
                            labelText: '開始時刻 (HH:MM)',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(
                                _votingPeriod?.startDate ?? DateTime.now(),
                              ),
                            );
                            if (time != null) {
                              final newStart = DateTime(
                                _votingPeriod?.startDate.year ?? 0,
                                _votingPeriod?.startDate.month ?? 0,
                                _votingPeriod?.startDate.day ?? 0,
                                time.hour,
                                time.minute,
                              );
                              _updateVotingPeriod(
                                newStart,
                                _votingPeriod?.endDate ?? DateTime.now(),
                              );
                              _updateDateControllers();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _endDateController,
                          decoration: const InputDecoration(
                            labelText: '終了日 (YYYY/MM/DD)',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate:
                                  _votingPeriod?.endDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (date != null) {
                              final newEnd = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                _votingPeriod?.endDate.hour ?? 0,
                                _votingPeriod?.endDate.minute ?? 0,
                              );
                              _updateVotingPeriod(
                                _votingPeriod?.startDate ?? DateTime.now(),
                                newEnd,
                              );
                              _updateDateControllers();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _endTimeController,
                          decoration: const InputDecoration(
                            labelText: '終了時刻 (HH:MM)',
                            border: OutlineInputBorder(),
                          ),
                          readOnly: true,
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(
                                _votingPeriod?.endDate ?? DateTime.now(),
                              ),
                            );
                            if (time != null) {
                              final newEnd = DateTime(
                                _votingPeriod?.endDate.year ?? 0,
                                _votingPeriod?.endDate.month ?? 0,
                                _votingPeriod?.endDate.day ?? 0,
                                time.hour,
                                time.minute,
                              );
                              _updateVotingPeriod(
                                _votingPeriod?.startDate ?? DateTime.now(),
                                newEnd,
                              );
                              _updateDateControllers();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '現在の設定: ${_votingPeriod?.getFormattedDateRange() ?? ''}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '団体一覧',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _addNewGroup,
                icon: const Icon(Icons.add),
                label: const Text('新しい団体'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('登録団体数: ${_groups?.length ?? 0}'),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _groups?.length ?? 0,
              itemBuilder: (context, index) {
                final group = _groups?[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(group?.name.substring(0, 1) ?? ''),
                    ),
                    title: Text(group?.name ?? ''),
                    subtitle: Text(
                      '${group?.groupName ?? ''} - ${group?.description ?? ''}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editGroup(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteGroup(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'カテゴリ一覧',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: _addNewCategory,
                icon: const Icon(Icons.add),
                label: const Text('新しいカテゴリ'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('投票カテゴリ数: ${_categories?.length ?? 0}'),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _categories?.length ?? 0,
              itemBuilder: (context, index) {
                final category = _categories?[index];
                return Card(
                  child: ListTile(
                    title: Text(category?.name ?? ''),
                    subtitle: Text(
                      '${category?.description ?? ''}\n団体数: ${category?.groups.length ?? 0}',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editCategory(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteCategory(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addNewGroup() {
    _showGroupDialog();
  }

  void _editGroup(int index) {
    _showGroupDialog(group: _groups?[index], index: index);
  }

  void _deleteGroup(int index) {
    setState(() {
      _groups?.removeAt(index);
    });
  }

  void _addNewCategory() {
    _showCategoryDialog();
  }

  void _editCategory(int index) {
    _showCategoryDialog(category: _categories?[index], index: index);
  }

  void _deleteCategory(int index) {
    setState(() {
      _categories?.removeAt(index);
    });
  }

  void _showGroupDialog({Group? group, int? index}) {
    final nameController = TextEditingController(text: group?.name ?? '');
    final groupNameController = TextEditingController(
      text: group?.groupName ?? '',
    );
    final descriptionController = TextEditingController(
      text: group?.description ?? '',
    );
    final imagePathController = TextEditingController(
      text: group?.imagePath ?? '',
    );
    List<GroupCategory> selectedCategories =
        group?.categories ?? [GroupCategory.other];
    int selectedFloor = group?.floor ?? 1;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(group == null ? '新しい団体' : '団体を編集'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: '団体名'),
                  ),
                  TextField(
                    controller: groupNameController,
                    decoration: const InputDecoration(labelText: 'グループ名'),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: '説明'),
                  ),
                  TextField(
                    controller: imagePathController,
                    decoration: const InputDecoration(labelText: '画像パス'),
                  ),
                  const SizedBox(height: 16),
                  StatefulBuilder(
                    builder:
                        (context, setDialogState) => Column(
                          children: [
                            const Text('カテゴリ選択:'),
                            ...GroupCategory.values
                                .map(
                                  (category) => CheckboxListTile(
                                    title: Text(
                                      _categoryNames?[category] ??
                                          category.toString(),
                                    ),
                                    value: selectedCategories.contains(
                                      category,
                                    ),
                                    onChanged: (value) {
                                      setDialogState(() {
                                        if (value == true) {
                                          selectedCategories.add(category);
                                        } else {
                                          selectedCategories.remove(category);
                                        }
                                      });
                                    },
                                  ),
                                )
                                .toList(),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<int>(
                              value: selectedFloor,
                              decoration: const InputDecoration(
                                labelText: '階数',
                              ),
                              items:
                                  [1, 2, 3, 4]
                                      .map(
                                        (floor) => DropdownMenuItem(
                                          value: floor,
                                          child: Text(
                                            floor == 4 ? 'ステージ等' : '${floor}階',
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                setDialogState(() {
                                  selectedFloor = value!;
                                });
                              },
                            ),
                          ],
                        ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('キャンセル'),
              ),
              ElevatedButton(
                onPressed: () {
                  final newGroup = Group(
                    id:
                        group?.id ??
                        'group_${DateTime.now().millisecondsSinceEpoch}',
                    name: nameController.text,
                    groupName: groupNameController.text,
                    description: descriptionController.text,
                    categories: selectedCategories,
                    floor: selectedFloor,
                    imagePath: imagePathController.text,
                  );

                  setState(() {
                    if (index != null) {
                      _groups?[index] = newGroup;
                    } else {
                      _groups?.add(newGroup);
                    }
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('保存'),
              ),
            ],
          ),
    );
  }

  void _showCategoryDialog({VoteCategory? category, int? index}) {
    final nameController = TextEditingController(text: category?.name ?? '');
    final descriptionController = TextEditingController(
      text: category?.description ?? '',
    );
    final helpTextController = TextEditingController(
      text: category?.shortHelpText ?? '',
    );
    bool canSkip = category?.canSkip ?? false;
    List<Group> selectedGroups = List.from(category?.groups ?? []);

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category == null ? '新しいカテゴリ' : 'カテゴリを編集',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: StatefulBuilder(
                        builder:
                            (context, setDialogState) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'カテゴリ名',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: descriptionController,
                                  decoration: const InputDecoration(
                                    labelText: '説明',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: helpTextController,
                                  decoration: const InputDecoration(
                                    labelText: 'ヘルプテキスト（任意）',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 16),
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CheckboxListTile(
                                          title: const Text('スキップ可能'),
                                          subtitle: const Text(
                                            'このカテゴリを投票でスキップできるようにする',
                                          ),
                                          value: canSkip,
                                          onChanged: (value) {
                                            setDialogState(() {
                                              canSkip = value ?? false;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              '対象団体を選択',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              '選択中: ${selectedGroups.length}/${_groups?.length ?? 0}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                setDialogState(() {
                                                  selectedGroups.clear();
                                                  selectedGroups.addAll(
                                                    _groups ?? [],
                                                  );
                                                });
                                              },
                                              child: const Text('全選択'),
                                            ),
                                            const SizedBox(width: 8),
                                            ElevatedButton(
                                              onPressed: () {
                                                setDialogState(() {
                                                  selectedGroups.clear();
                                                });
                                              },
                                              child: const Text('全解除'),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                          height: 250,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: ListView.builder(
                                            itemCount: _groups?.length ?? 0,
                                            itemBuilder: (context, i) {
                                              final group = _groups?[i];
                                              final isSelected = selectedGroups
                                                  .any(
                                                    (g) => g.id == group?.id,
                                                  );
                                              return CheckboxListTile(
                                                dense: true,
                                                title: Text(
                                                  group?.name ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  group?.groupName ?? '',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                value: isSelected,
                                                onChanged: (value) {
                                                  setDialogState(() {
                                                    if (value == true) {
                                                      if (group != null &&
                                                          !selectedGroups.any(
                                                            (g) =>
                                                                g.id ==
                                                                group.id,
                                                          )) {
                                                        selectedGroups.add(
                                                          group,
                                                        );
                                                      }
                                                    } else {
                                                      selectedGroups
                                                          .removeWhere(
                                                            (g) =>
                                                                g.id ==
                                                                group?.id,
                                                          );
                                                    }
                                                  });
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('キャンセル'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (nameController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('カテゴリ名を入力してください')),
                            );
                            return;
                          }

                          final newCategory = VoteCategory(
                            id:
                                category?.id ??
                                'category_${DateTime.now().millisecondsSinceEpoch}',
                            name: nameController.text.trim(),
                            description: descriptionController.text.trim(),
                            groups: selectedGroups,
                            canSkip: canSkip,
                            shortHelpText:
                                helpTextController.text.trim().isEmpty
                                    ? null
                                    : helpTextController.text.trim(),
                          );

                          setState(() {
                            if (index != null) {
                              _categories?[index] = newCategory;
                            } else {
                              _categories?.add(newCategory);
                            }
                          });
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('保存'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
