import 'dart:convert';
import 'dart:developer';

import 'package:chenbin_app/screens/inbound_order_detail.dart';
import 'package:flutter/material.dart';
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


  void _fetchInData(String code) async {
    if (code.isEmpty) code = "000000000";
    var response = await Http.get(
      "/purchase/receive/sheet/query",
      queryParameters: {
        "code": null
      },
    );


    if (response["code"] == 200) {
      setState(() {
        //print(jsonDecode(response));
        _listAll = response["data"]["datas"];
        //_focusNode.unfocus();
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
      //textEditingController.text = code;
      //_fetchInData(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("入库"),
        actions: [
          IconButton(
            onPressed: () => _startScan(context),
            icon: Image.asset(
              color: Colors.white,
              "assets/images/saoma2.png",
              width: 30,
              height: 30,
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _listAll.length,
          itemBuilder: (context,index){
          var data = _listAll[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              // 使用更柔和的阴影
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                ),
              ],
              // 侧边装饰条，增强视觉识别度
              // border: Border(
              //   left: BorderSide(color: StatusStyle.getStatusColor(index), width: 6),
              // ),
            ),
            child: InkWell(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '单据号：${data["code"]}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(data["status"] == 0?'待审核':(data["status"] == 3?'审核通过':'审核拒绝'),style: TextStyle(color: selectColor('1'), fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  //_rowText("单据号", "${data["code"]}"),
                  //_rowText("状态", data["status"] == 0?'待审核':(data["status"] == 3?'审核通过':'审核拒绝')),
                  _rowText("仓库编号", "${data["scCode"]}"),
                  _rowText("仓库名称", "${data["scName"]}"),
                  _rowText("供应商编号", "${data["supplierCode"]}"),
                  _rowText("供应商名称", "${data["supplierName"]}"),
                  _rowText("产品数量", "${data["totalNum"]}"),
                  _rowText("采购订单", "${data["purchaseOrderCode"]}"),
                  _rowText("操作人", "${data["createBy"]}"),
                  _rowText("操作时间", "${data["createTime"]}")
                ],
              ),
              onTap: (){
                _navigateToDetail(context,"${data["id"]}",data["status"]);
              }
            ),
          );
      }),
    );
  }

  // 原始颜色函数
  Color selectColor(String status) {
    if (status == '0') {
      return const Color(0xFFBDC7D8);
    } else if (status == '1') {
      return Colors.redAccent;
    } else {
      return Colors.blue;
    }
  }

  void _navigateToDetail(BuildContext context, String movementId, int status) {
    print(movementId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InboundOrderDetail(
          type: widget.type,
          inboundOderId: movementId,
          status: status,
        ),
      ),
    ).then((value) => {
      _fetchInData(code),
    });
  }

  Widget _rowText(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label：', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Expanded(
            child: Text(value ?? '-', style: const TextStyle(color: Colors.black87, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    _fetchInData(code);
    super.initState();
  }
}

