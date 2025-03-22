import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'vote_page.dart';
import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  String uuid = "未スキャン";
  String typeData = "";

  Future scan() async {
    try {
      var scan = await BarcodeScanner.scan();
      setState(() => {uuid = scan.rawContent, typeData = scan.format.name});
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        setState(() {
          uuid = 'Camera permissions are not valid.';
        });
      } else {
        setState(() => uuid = 'Unexplained error : $e');
      }
    } on FormatException {
      setState(
        () =>
            uuid =
                'Failed to read (I used the back button before starting the scan).',
      );
    } catch (e) {
      setState(() => uuid = 'Unknown error : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("バーコードスキャン")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("スキャン結果: $uuid", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: scan, child: const Text("バーコードをスキャン")),
          ],
        ),
      ),
    );
  }
}
