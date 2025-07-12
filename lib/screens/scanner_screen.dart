import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/uuid_service.dart';
import '../config/data_range_service.dart';
import '../widgets/main_layout.dart';
import '../platform/platform_utils.dart';
import 'vote_screen.dart';
import 'out_of_period_screen.dart';
import 'student_verification_screen.dart';
import '../widgets/custom_dialog.dart';

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
    return MainLayout(
      title: '投票券情報入力',
      icon: Icons.confirmation_number_outlined,
      helpTitle: '投票券情報入力',
      helpContent:
          'パンフレットに同封、または準備日・入場時に配布された投票券に記載されている番号10桁を入力してください。\n配布されていない場合は、お手数ですが文準本部室までお越しください。',
      onHome: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: const Text(
                'パンフレットに同封されている投票券に記載された番号(10桁)を入力してください。',
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: TextField(
                controller: _manualCodeController,
                decoration: InputDecoration(
                  labelText: 'ID',
                  border: InputBorder.none,
                  labelStyle: TextStyle(color: Colors.grey.shade600),
                ),
                keyboardType: TextInputType.number,
                autofocus: true,
                maxLength: 10,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'ログイン',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                ],
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                backgroundColor: const Color(0xFF592C7A), // Shikon color
                elevation: 0,
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
            child: FloatingActionButton(
              onPressed: () => PlatformUtils.reloadApp(),
              child: const Icon(Icons.home),
              backgroundColor: Colors.black54,
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

  bool _isWithinValidPeriod() {
    DateTime now = DateTime.now();
    return _dateRangeService.isWithinVotingPeriod(now);
  }

  Future<void> _processBarcode(String code) async {
    if (_isProcessingCode) return;
    setState(() {
      _isProcessingCode = true;
    });

    try {
      if (!_isWithinValidPeriod()) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (context) => OutOfPeriodScreen(
                  startDate: _dateRangeService.startDate,
                  endDate: _dateRangeService.endDate,
                ),
          ),
        );
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
