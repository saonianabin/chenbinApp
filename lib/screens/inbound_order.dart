import 'dart:convert';
import 'dart:developer';

import 'package:chenbin_app/screens/inbound_order_detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../common/Http.dart';
import '../common/SnackBarUtils.dart';
import '../utils/ScannerPage.dart';

class InboundOrder extends StatefulWidget {
  final String type;

  const InboundOrder({super.key, required this.type});

  @override
  State<InboundOrder> createState() => _InboundOrderState();
}

class _InboundOrderState extends State<InboundOrder> {
  String code = "";
  List _listAll = [];
  final FocusNode _focusNode = FocusNode();
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 可以在此处初始化数据
  }

  void _fetchInData(String code) async {
    if (code.isEmpty) code = "000000000";
    var response;
    if ("inbound" == widget.type) {
      response = await Http.get("/purchase/receive/sheet/query",
          queryParameters: {"code": code});
    } else if ("outbound" == widget.type) {
      response = await Http.get("/sale/out/sheet/query",
          queryParameters: {"code": code});
    }
    if (response["code"] == 200) {
      setState(() {
        _listAll = response["data"]["datas"];
        _focusNode.unfocus();
      });
    } else {
      SnackBarUtils.showError(context, response["msg"]);
    }
  }

  void _startScan(BuildContext context) async {
    final String? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScannerPage()),
    );
    if (result != null && context.mounted) {
      code = result;
      textEditingController.text = code;
      _fetchInData(code);
    }
  }

  // 搜索栏适配
  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textEditingController,
              focusNode: _focusNode,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                hintText: '请输入单号...',
                hintStyle: TextStyle(color: theme.hintColor),
                // 适配输入框背景
                filled: true,
                fillColor: theme.cardColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          TDButton(
            text: "搜索",
            size: TDButtonSize.large,
            type: TDButtonType.fill,
            shape: TDButtonShape.rectangle,
            theme: TDButtonTheme.primary,
            onTap: () => _fetchInData(textEditingController.text),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 【核心修改】获取当前主题数据
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.type == "inbound" ? "入库单查询" : "出库单查询"),
        actions: [
          IconButton(
            onPressed: () => _startScan(context),
            icon: Image.asset(
              "assets/images/saoma2.png",
              color: Colors.white, // AppBar通常为深色背景，保持白色图标
              width: 26,
              height: 26,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(theme),
          Expanded(
            child: _listAll.isEmpty
                ? _buildEmptyState(theme)
                : ListView.builder(
              itemCount: _listAll.length,
              itemBuilder: (context, index) {
                var data = _listAll[index];
                return _buildOrderCard(data, theme, isDark);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _startScan(context),
        backgroundColor: theme.primaryColor,
        child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
      ),
    );
  }

  // 空状态展示
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 64, color: theme.disabledColor),
          const SizedBox(height: 16),
          Text("暂无单据数据", style: TextStyle(color: theme.disabledColor)),
        ],
      ),
    );
  }

  // 单据卡片适配
  Widget _buildOrderCard(dynamic data, ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardColor, // 【核心】使用主题卡片色
        borderRadius: BorderRadius.circular(12),
        // 深色模式下阴影改为细边框，视觉更通透
        border: isDark ? Border.all(color: Colors.white10, width: 1) : null,
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToDetail(context, "${data["id"]}", data["status"]),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '单据号：${data["code"]}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  _buildStatusBadge(data["status"]),
                ],
              ),
              const Divider(height: 24),
              _rowText("仓库信息", "${data["scCode"]} - ${data["scName"]}", theme),

              if ("inbound" == widget.type) ...[
                _rowText("供应商编号", "${data["supplierCode"]}", theme),
                _rowText("供应商名称", "${data["supplierName"]}", theme),
              ],

              if ("outbound" == widget.type) ...[
                _rowText("客户编号", "${data["customerCode"]}", theme),
                _rowText("客户名称", "${data["customerName"]}", theme),
              ],

              _rowText("产品数量", "${data["totalNum"]}", theme),
              _rowText("操作人员", "${data["createBy"]}", theme),
              _rowText("操作时间", "${data["createTime"]}", theme),
            ],
          ),
        ),
      ),
    );
  }

  // 状态标签适配
  Widget _buildStatusBadge(int status) {
    String text = '未知';
    Color color = Colors.grey;
    if (status == 0) {
      text = '待审核';
      color = const Color(0xFFBDC7D8);
    } else if (status == 3) {
      text = '审核通过';
      color = Colors.green;
    } else {
      text = '审核拒绝';
      color = Colors.redAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _rowText(String label, String? value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
                '$label：',
                style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    fontSize: 13
                )
            ),
          ),
          Expanded(
            child: Text(
                value ?? '-',
                style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 13
                )
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, String movementId, int status) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InboundOrderDetail(
          type: widget.type,
          inboundOderId: movementId,
          status: status,
        ),
      ),
    ).then((value) {
      if (textEditingController.text.isNotEmpty) {
        _fetchInData(textEditingController.text);
      }
    });
  }
}