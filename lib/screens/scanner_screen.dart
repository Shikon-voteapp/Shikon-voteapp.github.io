// screens/scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/uuid_service.dart';
import '../widgets/top_bar.dart';
import '../widgets/message_area.dart';
import '../widgets/bottom_bar.dart';
import 'vote_screen.dart';

class ScannerScreen extends StatefulWidget {
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  final UuidService _uuidService = UuidService();
  final TextEditingController _manualCodeController = TextEditingController();
  bool _showManualInput = false;
  MobileScannerController _cameraController = MobileScannerController();
  bool _isProcessingCode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // アプリのライフサイクル状態が変更されたときにカメラを管理
    if (state == AppLifecycleState.resumed) {
      if (!_showManualInput && _cameraController.isStarting != true) {
        _cameraController.start();
      }
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _cameraController.stop();
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
    return Scaffold(
      body: Column(
        children: [
          TopBar(title: '投票券読み取り'),
          MessageArea(
            message:
                _showManualInput
                    ? '6桁の数字コードを入力してください'
                    : '投票券のQRコードをカメラにかざしてください \n 読み取れない場合は、右下のボタンを押してください。',
            title: "",
          ),
          Expanded(
            child: _showManualInput ? _buildManualInputUI() : _buildScannerUI(),
          ),
          BottomBar(uuid: '', showNextButton: false),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _showManualInput = !_showManualInput;
            if (!_showManualInput) {
              _manualCodeController.clear();
              // カメラを再開
              _cameraController.start();
            } else {
              // 手動入力モードではカメラを停止
              _cameraController.stop();
            }
          });
        },
        child: Icon(_showManualInput ? Icons.qr_code_scanner : Icons.keyboard),
        tooltip: _showManualInput ? 'スキャナーに戻る' : '手動入力に切り替え',
      ),
    );
  }

  Widget _buildScannerUI() {
    // カメラUIを構築
    return Stack(
      children: [
        MobileScanner(
          controller: _cameraController,
          onDetect: (capture) {
            if (_isProcessingCode) return; // 既に処理中なら無視

            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              final String? code = barcode.rawValue;
              if (code != null) {
                _processBarcode(code);
                break;
              }
            }
          },
          overlay: Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        // カメラの状態表示
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Center(
            child: ValueListenableBuilder(
              valueListenable: _cameraController.torchState,
              builder: (context, state, child) {
                return IconButton(
                  icon: Icon(
                    state == TorchState.on ? Icons.flash_on : Icons.flash_off,
                    color: Colors.white,
                  ),
                  onPressed: () => _cameraController.toggleTorch(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManualInputUI() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _manualCodeController,
            decoration: InputDecoration(
              labelText: 'バーコード番号',
              hintText: '6桁の数字を入力',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.dialpad),
            ),
            keyboardType: TextInputType.number, // 数字キーボードを表示
            autofocus: true,
            maxLength: 6, // 6桁に制限
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_manualCodeController.text.isNotEmpty) {
                if (_manualCodeController.text.length == 6) {
                  _processBarcode(_manualCodeController.text);
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('6桁の数字を入力してください')));
                }
              } else {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('コードを入力してください')));
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 24.0,
              ),
              child: Text('送信', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  void _processBarcode(String code) async {
    // 処理中フラグをセット
    setState(() {
      _isProcessingCode = true;
    });

    // スキャナーを一時停止
    _cameraController.stop();

    bool isValid = await _uuidService.validateUuid(code);
    if (isValid) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VoteScreen(uuid: code, categoryIndex: 0),
        ),
      ).then((_) {
        // complete_screenから戻ってきたら、
        // カメラを再初期化して画面を更新
        if (mounted) {
          setState(() {
            _isProcessingCode = false;
            if (!_showManualInput) {
              _cameraController.start();
            }
          });
        }
      });
    } else {
      // 無効なコードの場合、カメラを再開
      setState(() {
        _isProcessingCode = false;
        if (!_showManualInput) {
          _cameraController.start();
        }
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('このコードはすでに投票済みか、正しくない形式です')));
    }
  }
}
