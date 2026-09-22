import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/uuid_service.dart';
import '../services/database_service.dart';
import '../config/data_range_service.dart';
import '../widgets/main_layout.dart';
import '../widgets/neumorphic_wrappers.dart';
import '../platform/platform_utils.dart';
import 'vote_screen.dart';
import 'student_verification_screen.dart';
import '../widgets/custom_dialog.dart';
import '../config/special_ids.dart';
import '../config/vote_options.dart';
import '../models/group.dart' hide VoteCategory;
import '../models/vote_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_3_expressive/material_3_expressive.dart';
import '../widgets/gaknum_text.dart';

class ScannerScreen extends StatefulWidget {
  final bool startWithScanner;

  const ScannerScreen({super.key, this.startWithScanner = false});

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  final UuidService _uuidService = UuidService();
  final DatabaseService _dbService = DatabaseService();
  final DateRangeService _dateRangeService = DateRangeService();
  final TextEditingController _manualCodeController = TextEditingController();
  late bool _showManualInput;
  late MobileScannerController _cameraController;
  bool _isProcessingCode = false;
  CameraFacing _currentCamera = CameraFacing.front;

  @override
  void initState() {
    super.initState();
    _showManualInput = !widget.startWithScanner;
    WidgetsBinding.instance.addObserver(this);
    _initCameraController();
  }

  void _initCameraController() {
    _cameraController = MobileScannerController(
      facing: _currentCamera,
      torchEnabled: false,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_showManualInput && !_isProcessingCode) {
        _resetCameraController();
      }
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _cameraController.stop();
    }
  }

  void _resetCameraController() {
    _cameraController.dispose();
    _initCameraController();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController.dispose();
    _manualCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _showManualInput ? _buildManualInputScaffold() : _buildScannerUI();
  }

  Widget _buildManualInputScaffold() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final totalSteps = voteCategories.length + 2;
    final progress = totalSteps > 0 ? 1.0 / totalSteps : 0.0;

    return MainLayout(
      title: '投票券情報入力',
      icon: Icons.confirmation_number,
      progressValue: progress,
      helpTitle: '投票について',
      helpContent:
          'パンフレットに同封、または準備日・入場時に配布された投票券に記載されている番号10桁を入力してください。\n配布されていない場合は、お手数ですが文準本部室までお越しください。',
      onHome: () {},
      onNext: _isProcessingCode
          ? null
          : () {
              if (_manualCodeController.text.isNotEmpty) {
                if (_manualCodeController.text.length == 10) {
                  _processBarcode(_manualCodeController.text);
                } else {
                  showCustomDialog(
                    context: context,
                    title: '入力エラー',
                    content: '10桁の数字を入力してください。',
                  );
                }
              } else {
                showCustomDialog(
                  context: context,
                  title: '入力エラー',
                  content: 'コードを入力してください。',
                );
              }
            },
      nextLabel: 'ログイン',
      nextLoading: _isProcessingCode,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            neumorphicCard(
              context: context,
              padding: const EdgeInsets.all(24.0),
              borderRadius: BorderRadius.circular(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'パンフレットに同封されている投票券に記載された番号(10桁)を入力してください。',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ID',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black.withValues(alpha: 0.2)
                              : Colors.black.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context)
                                .dividerColor
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: TextField(
                            controller: _manualCodeController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 12,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            autofocus: true,
                            maxLength: 10,
                            buildCounter: (
                              context, {
                              required currentLength,
                              required isFocused,
                              maxLength,
                            }) =>
                                null,
                            style: const TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'GakNumBold',
                              letterSpacing: 2.0,
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text.rich(
                          TextSpan(
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                            children: [
                              gakNumSpan(
                                '${_manualCodeController.text.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                              const TextSpan(text: '/'),
                              gakNumSpan(
                                '10',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerUI() {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: _cameraController,
            onDetect: (capture) {
              if (_isProcessingCode) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? code = barcode.rawValue;
                if (code != null) {
                  _processBarcode(code);
                }
              }
            },
          ),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: ElevatedButton(
              onPressed: () => PlatformUtils.reloadApp(),
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: Colors.black.withValues(alpha: 0.6),
                padding: const EdgeInsets.all(16),
                elevation: 0,
              ),
              child: const Icon(Icons.home, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// 無効・エラー理由を区別して表示するダイアログ
  void _showInvalidUuidDialog(UuidValidationResult reason) {
    final String title;
    final Widget contentWidget;
    final theme = Theme.of(context);

    switch (reason) {
      case UuidValidationResult.invalidFormat:
        title = '番号の形式が正しくありません';
        contentWidget = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildErrorBadge(
              icon: Icons.format_clear_rounded,
              label: '形式エラー',
              color: theme.colorScheme.error,
              theme: theme,
            ),
            const SizedBox(height: 12),
            Text(
              '入力された番号が10桁の数字ではありません。投票券に記載されている10桁の番号を正しく入力してください。',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        );
        break;
      case UuidValidationResult.outOfRange:
        title = '使用できない番号です';
        contentWidget = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildErrorBadge(
              icon: Icons.block_rounded,
              label: '番号範囲外',
              color: theme.colorScheme.error,
              theme: theme,
            ),
            const SizedBox(height: 12),
            Text(
              'この番号は紫紺祭で発行された投票券の番号ではありません。パンフレット同封の投票券をご確認いただくか、文準本部室にお越しください。',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        );
        break;
      case UuidValidationResult.invalidated:
        title = 'この番号は無効化されています';
        contentWidget = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildErrorBadge(
              icon: Icons.remove_circle_outline_rounded,
              label: '番号無効',
              color: Colors.orange,
              theme: theme,
            ),
            const SizedBox(height: 12),
            Text(
              'この番号は管理者により無効化されています。紛失・汚損・再発行等の理由により使用できません。\nお心当たりがある場合は、文準本部室にお越しください。',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        );
        break;
      default:
        title = '番号エラー';
        contentWidget = Text(
          'このコードは無効か、すでに使われているかもしれません。\nお手数ですが、文準本部室までお越しください。',
          style: theme.textTheme.bodyMedium,
        );
    }

    showCustomDialog(
      context: context,
      title: title,
      contentWidget: contentWidget,
      primaryActionText: '再入力する',
      onPrimaryAction: () {
        Navigator.of(context).pop();
        if (_showManualInput) {
          setState(() {
            _isProcessingCode = false;
          });
        } else {
          setState(() {
            _isProcessingCode = false;
            _resetCameraController();
          });
        }
      },
      closeButtonText: '閉じる',
    );
  }

  Widget _buildErrorBadge({
    required IconData icon,
    required String label,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  /// 既投票番号でログインした場合の投票内容確認UI
  Future<void> _showAlreadyVotedDialog(String uuid) async {
    final theme = Theme.of(context);

    // Firebase から投票データを取得
    Vote? existingVote;
    try {
      existingVote = await _dbService.getVoteByUuid(uuid);
    } catch (_) {}

    if (!mounted) return;

    await M3ESideSheet.show<void>(
      context,
      title: 'この番号は投票済みです',
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 警告バナー
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.how_to_vote_rounded,
                    color: theme.colorScheme.error,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'この投票券はすでに使用済みです',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.error,
                          ),
                        ),
                        if (existingVote != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '投票日時: ${_formatDateTime(existingVote.timestamp)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 投票内容の表示
            if (existingVote != null && existingVote.selections.isNotEmpty) ...[
              Text(
                '記録されている投票内容',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...voteCategories.map((category) {
                final groupId = existingVote!.selections[category.id];
                if (groupId == null) {
                  return _buildVoteItemTile(
                    theme: theme,
                    categoryName: category.name,
                    groupName: '選択なし',
                    isSkipped: true,
                  );
                }
                final group = allGroups.firstWhere(
                  (g) => g.id == groupId,
                  orElse: () => Group(
                    id: 'unknown',
                    name: '不明な団体',
                    groupName: '',
                    description: '',
                    imagePath: 'assets/Stage/No Select.jpg',
                    floor: 0,
                    categories: [],
                  ),
                );
                return _buildVoteItemTile(
                  theme: theme,
                  categoryName: category.name,
                  groupName: group.name,
                  groupSubName: group.groupName,
                  isSkipped: false,
                );
              }),
              const SizedBox(height: 16),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '投票内容の詳細を取得できませんでした。',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 案内テキスト
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '投票内容を修正したい場合は「投票を編集する」を押してください。投票内容は上書き保存されます。\n不正な使用と判断された場合はご連絡させていただく場合があります。',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Expanded(
          child: M3EButton.icon(
            style: M3EButtonStyle.filled,
            size: M3EButtonSize.md,
            shape: M3EButtonShape.round,
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('投票を編集する'),
            onPressed: () {
              Navigator.of(context).pop();
              // 既存の投票内容を持たせて投票画面へ遷移
              final existingSelections = existingVote?.selections ?? {};
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => VoteScreen(
                    uuid: uuid,
                    categoryIndex: 0,
                    selections: existingSelections,
                    restoreSelection: existingSelections.isNotEmpty,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );

    // Side sheet が閉じられた（編集しない場合）
    if (mounted) {
      setState(() {
        _isProcessingCode = false;
      });
    }
  }

  Widget _buildVoteItemTile({
    required ThemeData theme,
    required String categoryName,
    String? groupName,
    String? groupSubName,
    required bool isSkipped,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isSkipped
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
            : theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSkipped
              ? theme.colorScheme.outlineVariant.withValues(alpha: 0.4)
              : theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSkipped
                ? Icons.do_not_disturb_on_outlined
                : Icons.check_circle_outline_rounded,
            color: isSkipped
                ? theme.colorScheme.onSurface.withValues(alpha: 0.35)
                : theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  isSkipped ? '選択なし' : (groupName ?? ''),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSkipped
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.45)
                        : theme.colorScheme.onSurface,
                  ),
                ),
                if (!isSkipped && groupSubName != null && groupSubName.isNotEmpty)
                  Text(
                    groupSubName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showOutOfPeriodDialog() async {
    final theme = Theme.of(context);
    final now = DateTime.now();
    String _format(DateTime dt) {
      String two(int n) => n.toString().padLeft(2, '0');
      return '${dt.year}年${dt.month}月${dt.day}日 ${two(dt.hour)}:${two(dt.minute)}';
    }

    await showCustomDialog(
      context: context,
      title: '投票期間外です',
      contentWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '現在は投票を受け付けていません。\n以下の期間内に再度お試しください。\nなお、毎日深夜02:45～03:00はサーバーメンテナンスのため投票できません。',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.schedule, size: 18),
              const SizedBox(width: 6),
              Text('現在時刻: ', style: theme.textTheme.titleSmall),
              Expanded(child: Text(_format(now))),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.play_arrow, color: Colors.green),
                    const SizedBox(width: 8),
                    Text('開始：', style: theme.textTheme.titleMedium),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_formatDateTime(_dateRangeService.startDate)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.stop, color: theme.colorScheme.error),
                    const SizedBox(width: 8),
                    Text('終了：', style: theme.textTheme.titleMedium),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_formatDateTime(_dateRangeService.endDate)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      closeButtonText: '閉じる',
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}年${dateTime.month}月${dateTime.day}日 ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  bool _isWithinValidPeriod() {
    DateTime now = DateTime.now();
    return _dateRangeService.isWithinVotingPeriod(now);
  }

  Future<void> _processBarcode(String code) async {
    if (_isProcessingCode) return;
    setState(() {
      _isProcessingCode = true;
    });

    // 1.1秒の待機時間
    await Future.delayed(const Duration(milliseconds: 1100));

    try {
      // 特別IDは時間・UUID検証をスキップして投票画面へ
      if (code == specialBypassUuid) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VoteScreen(uuid: code, categoryIndex: 0),
            ),
          );
        }
        return;
      }

      if (!_isWithinValidPeriod()) {
        await _showOutOfPeriodDialog();
        return;
      }

      // 詳細な検証結果を取得
      final validationResult = await _uuidService.validateUuidWithReason(code);

      if (validationResult == UuidValidationResult.alreadyVoted) {
        // 既投票番号：投票内容を表示して編集するか問う
        if (mounted) {
          await _showAlreadyVotedDialog(code);
        }
        return;
      }

      if (validationResult != UuidValidationResult.valid) {
        // 無効番号：理由を区別して表示
        if (mounted) {
          _showInvalidUuidDialog(validationResult);
        }
        return;
      }

      final bool isStudent = await _uuidService.requiresStudentVerification(code);
      if (mounted) {
        if (isStudent) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => StudentVerificationScreen(uuid: code),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VoteScreen(uuid: code, categoryIndex: 0),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showInvalidUuidDialog(UuidValidationResult.outOfRange);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingCode = false;
        });
      }
    }
  }
}
