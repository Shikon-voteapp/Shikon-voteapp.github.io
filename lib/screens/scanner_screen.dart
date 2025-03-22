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

class _ScannerScreenState extends State<ScannerScreen> {
  final UuidService _uuidService = UuidService();
  final TextEditingController _manualCodeController = TextEditingController();
  bool _showManualInput = false;
  MobileScannerController? _cameraController;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  void _initCamera() {
    _cameraController = MobileScannerController();
  }

  void _disposeCamera() {
    _cameraController?.dispose();
    _cameraController = null;
  }

  @override
  void dispose() {
    _disposeCamera();
    _manualCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TopBar(title: '投票券を読み取らせてください'),
          MessageArea(
            message:
                _showManualInput
                    ? 'コードを直接入力してください'
                    : 'バーコードをカメラにかざしてください \n カメラ映像が表示されない場合は、右下のボタンを押してください。',
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
              if (_cameraController == null) {
                _initCamera();
              }
            }
          });
        },
        child: Icon(_showManualInput ? Icons.qr_code_scanner : Icons.keyboard),
        tooltip: _showManualInput ? 'スキャナーに戻る' : '手動入力に切り替え',
      ),
    );
  }

  Widget _buildScannerUI() {
    // カメラコントローラーがない場合は初期化
    if (_cameraController == null) {
      _initCamera();
    }

    return MobileScanner(
      controller: _cameraController,
      onDetect: (capture) {
        final List<Barcode> barcodes = capture.barcodes;
        for (final barcode in barcodes) {
          final String? code = barcode.rawValue;
          if (code != null) {
            _processBarcode(code);
            break;
          }
        }
      },
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
              hintText: '数字またはUUIDを入力',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.dialpad),
            ),
            keyboardType: TextInputType.text,
            autofocus: true,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_manualCodeController.text.isNotEmpty) {
                _processBarcode(_manualCodeController.text);
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
    // 重複処理を防止するためカメラを一時的に破棄
    _disposeCamera();

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
            if (!_showManualInput) {
              _initCamera();
            }
          });
        }
      });
    } else {
      // 無効なコードの場合、カメラを再初期化
      setState(() {
        if (!_showManualInput) {
          _initCamera();
        }
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('このコードはすでに投票済みか、正しくない形式です')));
    }
  }
}
