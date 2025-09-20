import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/uuid_service.dart';
import '../config/data_range_service.dart';
import '../widgets/main_layout.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import '../widgets/neumorphic_wrappers.dart';
import '../platform/platform_utils.dart';
import 'vote_screen.dart';
import 'student_verification_screen.dart';
import '../widgets/custom_dialog.dart';
import '../config/special_ids.dart';
import 'package:icons_plus/icons_plus.dart';

class ScannerScreen extends StatefulWidget {
  final bool startWithScanner;

  const ScannerScreen({super.key, this.startWithScanner = false});

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  final UuidService _uuidService = UuidService();
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
    return MainLayout(
      title: '投票券情報入力',
      icon: FontAwesome.ticket_simple_solid,
      helpTitle: '投票について',
      helpContent:
          'パンフレットに同封、または準備日・入場時に配布された投票券に記載されている番号10桁を入力してください。\n配布されていない場合は、お手数ですが文準本部室までお越しください。',
      onHome: () {},
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
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Neumorphic(
                        style: NeumorphicStyle(
                          depth: -4,
                          intensity: 0.8,
                          boxShape: NeumorphicBoxShape.roundRect(
                            BorderRadius.circular(12.0),
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: TextField(
                              controller: _manualCodeController,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                filled: true,
                                fillColor: Colors.transparent,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 12,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              autofocus: true,
                              maxLength: 10,
                              buildCounter:
                                  (
                                    context, {
                                    required currentLength,
                                    required isFocused,
                                    maxLength,
                                  }) => null,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${_manualCodeController.text.length}/10',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            NeumorphicButton(
              onPressed:
                  _isProcessingCode
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
              style: NeumorphicStyle(
                color:
                    _isProcessingCode
                        ? null
                        : (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black),
                depth: _isProcessingCode ? -4 : 6,
                intensity: 0.8,
                boxShape: NeumorphicBoxShape.roundRect(
                  BorderRadius.circular(30.0),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder:
                    (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                child:
                    _isProcessingCode
                        ? SizedBox(
                          key: const ValueKey('loading'),
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        )
                        : Row(
                          key: const ValueKey('label'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'ログイン',
                              style: TextStyle(
                                fontSize: 18,
                                color:
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.black
                                        : Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              FontAwesome.arrow_right_solid,
                              size: 16,
                              color:
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.black
                                      : Colors.white,
                            ),
                          ],
                        ),
              ),
            ),
            const SizedBox(height: 20),
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
            child: NeumorphicButton(
              onPressed: () => PlatformUtils.reloadApp(),
              style: const NeumorphicStyle(
                boxShape: NeumorphicBoxShape.circle(),
                depth: 6,
                color: Colors.black,
              ),
              padding: const EdgeInsets.all(16),
              child: const Icon(Icons.home, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showCustomDialog(
      context: context,
      title: 'アクセス権限エラー',
      content: 'このコードは無効か、すでに使われているかもしれません。\nお手数ですが、文準本部室までお越しください。',
      primaryActionText: '再試行',
      onPrimaryAction: () {
        Navigator.of(context).pop();
        if (_showManualInput) {
          if (_manualCodeController.text.isNotEmpty) {
            _processBarcode(_manualCodeController.text);
          }
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
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
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
      final bool isValid = await _uuidService.validateUuid(code);
      if (!isValid) {
        _showPermissionDeniedDialog();
        return;
      }

      final bool isStudent = await _uuidService.requiresStudentVerification(
        code,
      );
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
      _showPermissionDeniedDialog();
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingCode = false;
        });
      }
    }
  }
}
