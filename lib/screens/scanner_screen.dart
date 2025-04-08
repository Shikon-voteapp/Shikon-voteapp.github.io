// screens/scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/uuid_service.dart';
import '../config/data_range_service.dart'; // 有効期間を管理するサービス
import '../widgets/top_bar.dart';
import '../widgets/message_area.dart';
import '../widgets/bottom_bar.dart';
import 'vote_screen.dart';
import 'out_of_period_screen.dart'; // 有効期間外画面

class ScannerScreen extends StatefulWidget {
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  final UuidService _uuidService = UuidService();
  final DateRangeService _dateRangeService = DateRangeService(); // 有効期間サービス
  final TextEditingController _manualCodeController = TextEditingController();
  bool _showManualInput = false;
  late MobileScannerController _cameraController;
  bool _isProcessingCode = false;
  CameraFacing _currentCamera = CameraFacing.front; // デフォルトはインカメラ

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCameraController();
  }

  void _initCameraController() {
    // 現在選択されているカメラで初期化
    _cameraController = MobileScannerController(
      facing: _currentCamera,
      torchEnabled: false,
    );
  }

  // カメラを切り替える
  void _switchCamera() {
    _currentCamera =
        _currentCamera == CameraFacing.front
            ? CameraFacing.back
            : CameraFacing.front;
    _resetCameraController();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // アプリのライフサイクル状態が変更されたときにカメラを管理
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
    return Scaffold(
      body: Column(
        children: [
          TopBar(title: '投票券読み取り'),
          MessageArea(
            message:
                _showManualInput
                    ? '6桁の数字コードを入力してください'
                    : '投票券のQRコードをカメラにかざしてください \n 何も表示されない場合は、右下のボタンを押して手動で入力してください。',
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
            /*if (!_showManualInput) {
              _manualCodeController.clear();
              // カメラを再開
              _resetCameraController();
            } else {
              // 手動入力モードではカメラを停止
              _cameraController.stop();
            }*/
          });
        },
        child: Icon(_showManualInput ? Icons.qr_code_scanner : Icons.keyboard),
        tooltip: _showManualInput ? 'スキャナーに戻る' : '手動入力に切り替え',
      ),
    );
  }

  Widget _buildScannerUI() {
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
                //                break;
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
        // カメラ操作ボタン
        /*Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          /*child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // カメラ切り替えボタン
              IconButton(
                icon: Icon(Icons.flip_camera_ios, color: Colors.white),
                onPressed: _switchCamera,
                tooltip: 'カメラ切り替え',
              ),
              SizedBox(width: 20),
              // フラッシュ切り替えボタン (アウトカメラ時のみ有効)
              ValueListenableBuilder(
                valueListenable: _cameraController.torchState,
                builder: (context, state, child) {
                  return IconButton(
                    icon: Icon(
                      state == TorchState.on ? Icons.flash_on : Icons.flash_off,
                      color:
                          _currentCamera == CameraFacing.back
                              ? Colors.white
                              : Colors.grey,
                    ),
                    onPressed:
                        _currentCamera == CameraFacing.back
                            ? () => _cameraController.toggleTorch()
                            : null,
                    tooltip: 'フラッシュ',
                  );
                },
              ),
            ],
          ),*/
        ),*/
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
              child: Text('ログイン', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  // Permission deniedエラーダイアログを表示
  void _showPermissionDeniedDialog() {
    // すでに表示されているダイアログを閉じる
    Navigator.of(
      context,
      rootNavigator: true,
    ).popUntil((route) => route.isFirst);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 10),
                Text('アクセス権限エラー'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('投票データへのアクセス権限がありません。'),
                SizedBox(height: 8),
                Text('このコードを使用する権限がないか、データベースのアクセス設定に問題があります。'),
                SizedBox(height: 16),
                Text(
                  '管理者にお問い合わせください。',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('キャンセル'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  // カメラを再開するか手動入力に戻る
                  setState(() {
                    _isProcessingCode = false;
                    if (!_showManualInput) {
                      _resetCameraController();
                    }
                  });
                },
              ),
              ElevatedButton(
                child: Text('再試行'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  // 再試行処理
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
              ),
            ],
          );
        },
      );
    });
  }

  // 現在の日時が有効期間内かチェック
  bool _isWithinValidPeriod() {
    DateTime now = DateTime.now();
    return _dateRangeService.isWithinVotingPeriod(now);
  }

  void _processBarcode(String code) async {
    // 処理中フラグをセット
    setState(() {
      _isProcessingCode = true;
    });

    // スキャナーを一時停止
    _cameraController.stop();

    // 有効期間内かチェック
    if (!_isWithinValidPeriod()) {
      // 有効期間外の場合、専用画面に遷移
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => OutOfPeriodScreen(
                startDate: _dateRangeService.startDate,
                endDate: _dateRangeService.endDate,
              ),
        ),
      ).then((_) {
        // 画面から戻ってきたら処理を再開
        if (mounted) {
          setState(() {
            _isProcessingCode = false;
            if (!_showManualInput) {
              _resetCameraController();
            }
          });
        }
      });
      return;
    }

    try {
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
                _resetCameraController();
              }
            });
          }
        });
      } else {
        // 無効なコードの場合、カメラを再開
        setState(() {
          _isProcessingCode = false;
          if (!_showManualInput) {
            _resetCameraController();
          }
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('このコードはすでに投票済みか、正しくない形式です')));
      }
    } catch (e) {
      print('エラー発生: $e');

      // Permission deniedエラーの場合のみダイアログを表示
      if (e.toString().toLowerCase().contains('permission denied')) {
        _showPermissionDeniedDialog();
      } else {
        // その他のエラーの場合はスナックバーで通知
        setState(() {
          _isProcessingCode = false;
          if (!_showManualInput) {
            _resetCameraController();
          }
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('エラーが発生しました。もう一度お試しください。')));
      }
    }
  }
}
