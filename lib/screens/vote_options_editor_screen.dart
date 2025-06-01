import 'package:flutter/material.dart';
import 'dart:html' as html;
import '../config/vote_options.dart';
import '../models/group.dart';

class VoteOptionsEditorScreen extends StatefulWidget {
  @override
  _VoteOptionsEditorScreenState createState() =>
      _VoteOptionsEditorScreenState();
}

class _VoteOptionsEditorScreenState extends State<VoteOptionsEditorScreen> {
  late List<Group> _groups;
  late List<VoteCategory> _categories;
  int _selectedTabIndex = 0;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _groups = List.from(allGroups);
    _categories = List.from(voteCategories);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('投票オプション管理'),
          actions: [
            if (_hasChanges)
              IconButton(icon: Icon(Icons.save), onPressed: _saveChanges),
          ],
          bottom: TabBar(
            tabs: [Tab(text: '団体管理'), Tab(text: 'カテゴリー管理')],
            onTap: (index) {
              setState(() {
                _selectedTabIndex = index;
              });
            },
          ),
        ),
        body: TabBarView(children: [_buildGroupsTab(), _buildCategoriesTab()]),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_selectedTabIndex == 0) {
              _showAddGroupDialog();
            } else {
              _showAddCategoryDialog();
            }
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  void _markChanges() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  Future<void> _saveChanges() async {
    try {
      // 団体リストの更新
      final groupsString = _groups
          .map((group) {
            return '''  Group(
    id: '${group.id}',
    name: '${group.name}',
    description: '${group.description}',
    imagePath: '${group.imagePath}',
    floor: ${group.floor},
    categories: [${group.categories.map((c) => 'GroupCategory.${c.toString().split('.').last}').join(', ')}],
  ),''';
          })
          .join('\n');

      // カテゴリーリストの更新
      final categoriesString = _categories
          .map((category) {
            return '''  VoteCategory(
    id: '${category.id}',
    name: '${category.name}',
    description: '${category.description}',
    groups: allGroups.where((group) => ${category.eligibleCategories?.map((c) => 'group.hasCategory(GroupCategory.${c.toString().split('.').last})').join(' || ') ?? 'true'}).toList(),
    eligibleCategories: [${category.eligibleCategories?.map((c) => 'GroupCategory.${c.toString().split('.').last}').join(', ')}],
  ),''';
          })
          .join('\n');

      // ファイルの内容を更新
      final content = '''import 'package:shikon_voteapp/models/group.dart';

// config/vote_options.dart
/*
=======投票先一覧を設定する設定ファイル=======

*/
// すべての団体のリスト
final List<Group> allGroups = [
$groupsString
];

final List<VoteCategory> voteCategories = [
$categoriesString
];
''';

      // ファイルをダウンロード
      final blob = html.Blob([content]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor =
          html.AnchorElement(href: url)
            ..setAttribute('download', 'vote_options.dart')
            ..click();
      html.Url.revokeObjectUrl(url);

      setState(() {
        _hasChanges = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('変更を保存しました。vote_options.dartファイルをダウンロードしました。')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('保存に失敗しました: $e')));
    }
  }

  Widget _buildGroupsTab() {
    return ListView.builder(
      itemCount: _groups.length,
      itemBuilder: (context, index) {
        final group = _groups[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: CircleAvatar(backgroundImage: AssetImage(group.imagePath)),
            title: Text(group.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(group.description),
                SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children:
                      group.categories.map((category) {
                        return Chip(
                          label: Text(category.toString().split('.').last),
                          backgroundColor: Colors.blue.shade100,
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoriesTab() {
    return ListView.builder(
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(category.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.description),
                SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children:
                      category.eligibleCategories?.map((category) {
                        return Chip(
                          label: Text(category.toString().split('.').last),
                          backgroundColor: Colors.green.shade100,
                        );
                      }).toList() ??
                      [],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddGroupDialog() {
    final formKey = GlobalKey<FormState>();
    String id = '';
    String name = '';
    String description = '';
    String imagePath = '';
    int floor = 1;
    List<GroupCategory> selectedCategories = [];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('団体の追加'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'ID'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'IDを入力してください';
                        }
                        if (_groups.any((g) => g.id == value)) {
                          return 'このIDは既に使用されています';
                        }
                        return null;
                      },
                      onSaved: (value) => id = value!,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: '団体名'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '団体名を入力してください';
                        }
                        return null;
                      },
                      onSaved: (value) => name = value!,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: '説明'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '説明を入力してください';
                        }
                        return null;
                      },
                      onSaved: (value) => description = value!,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: '画像パス'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '画像パスを入力してください';
                        }
                        return null;
                      },
                      onSaved: (value) => imagePath = value!,
                    ),
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(labelText: '階'),
                      value: floor,
                      items:
                          [1, 2, 3, 4].map((f) {
                            return DropdownMenuItem(
                              value: f,
                              child: Text('$f階'),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          floor = value;
                        }
                      },
                    ),
                    Wrap(
                      spacing: 8,
                      children:
                          GroupCategory.values.map((category) {
                            return FilterChip(
                              label: Text(category.toString().split('.').last),
                              selected: selectedCategories.contains(category),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    selectedCategories.add(category);
                                  } else {
                                    selectedCategories.remove(category);
                                  }
                                });
                              },
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('キャンセル'),
              ),
              TextButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    setState(() {
                      _groups.add(
                        Group(
                          id: id,
                          name: name,
                          description: description,
                          imagePath: imagePath,
                          floor: floor,
                          categories: selectedCategories,
                        ),
                      );
                      _markChanges();
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text('追加'),
              ),
            ],
          ),
    );
  }

  void _showAddCategoryDialog() {
    final formKey = GlobalKey<FormState>();
    String id = '';
    String name = '';
    String description = '';
    List<GroupCategory> selectedCategories = [];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('カテゴリーの追加'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'ID'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'IDを入力してください';
                        }
                        if (_categories.any((c) => c.id == value)) {
                          return 'このIDは既に使用されています';
                        }
                        return null;
                      },
                      onSaved: (value) => id = value!,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'カテゴリー名'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'カテゴリー名を入力してください';
                        }
                        return null;
                      },
                      onSaved: (value) => name = value!,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: '説明'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '説明を入力してください';
                        }
                        return null;
                      },
                      onSaved: (value) => description = value!,
                    ),
                    Wrap(
                      spacing: 8,
                      children:
                          GroupCategory.values.map((category) {
                            return FilterChip(
                              label: Text(category.toString().split('.').last),
                              selected: selectedCategories.contains(category),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    selectedCategories.add(category);
                                  } else {
                                    selectedCategories.remove(category);
                                  }
                                });
                              },
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('キャンセル'),
              ),
              TextButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    formKey.currentState!.save();
                    setState(() {
                      _categories.add(
                        VoteCategory(
                          id: id,
                          name: name,
                          description: description,
                          groups:
                              _groups.where((group) {
                                return group.categories.any(
                                  (category) =>
                                      selectedCategories.contains(category),
                                );
                              }).toList(),
                          eligibleCategories: selectedCategories,
                        ),
                      );
                      _markChanges();
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text('追加'),
              ),
            ],
          ),
    );
  }
}
