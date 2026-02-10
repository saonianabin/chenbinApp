import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  // 增加一个变量防止多次重复返回
  bool isFinished = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('正在扫描')),
      body: MobileScanner(
        onDetect: (capture) {
          if (isFinished) return; // 如果已经返回了，就不再处理

          final barcode = capture.barcodes.first;
          final String? code = barcode.rawValue;

          if (code != null) {
            isFinished = true;
            // 【关键】使用 pop 将结果返回给调用者
            Navigator.pop(context, code);
          }
        },
      ),
    );
  }
}