import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../common/Http.dart';
import '../common/SnackBarUtils.dart';
import '../utils/app_theme.dart';
import 'movement_detail_screen.dart';

class InboundOrderDetail extends StatefulWidget {

  final int status;
  final String type;
  final String inboundOderId;

  const InboundOrderDetail({super.key, required this.type, required this.inboundOderId, required this.status});

  @override
  State<InboundOrderDetail> createState() => _InboundOrderDetailState();
}

class _InboundOrderDetailState extends State<InboundOrderDetail> {

  var _row = {};
  bool _isProcessing = false;
  final Map<String, TextEditingController> _quantityControllers = {};

  void _fetchInData() async {
    var response = await Http.get(
      "/purchase/receive/sheet",queryParameters: {"id":widget.inboundOderId}
    );
    _quantityControllers.clear();
    if (response["code"] == 200) {
      setState(() {
        _row = response["data"];

        for (var i = 0; i < response["data"]["details"].length; ++i) {
          var element = response["data"]["details"][i];
          _quantityControllers[element["id"]] = TextEditingController(
            text: element["receiveNum"]?.toString() ?? '',
          );
        }

      });
    } else {
      SnackBarUtils.showError(context, response["msg"]);
    }
  }

  void _update(productId,receiveNum) async{
    var data = {
      "id": _row["id"],
      "products": [
        {
          "description": "",
          "productId": productId,
          "receiveNum": receiveNum
        }
      ],
      "receiveDate": _row["receiveDate"],
      "required": true,
      "scId": _row["scId"],
      "supplierId": _row["supplierId"],
      "purchaseOrderId": _row["purchaseOrderId"]
    };

    try {
      var response = await Http.put("/purchase/receive/sheet",data: data);
      SnackBarUtils.showError(context, response["msg"]);
    }catch(e){
      SnackBarUtils.showError(context, "请联系管理员处理");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("入库详情")
      ),
      body: ListView.builder(
          itemCount: _row["details"] != null ? _row["details"].length : 0,
          itemBuilder: (context,index){
          var data = _row["details"]?[index];
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
            child: Column(
              children: [
                _rowText("产品ID", "${data["productId"]}"),
                _rowText("产品编号", "${data["productCode"]}"),
                _rowText("产品名称", "${data["productName"]}"),
                _rowText("产品SKU编号", "${data["skuCode"]}"),
                _rowText("单位", "${data["unit"]}"),
                _rowText("规格", "${data["spec"]}"),
                _rowText("产品分类", "${data["categoryName"]}"),
                _rowText("产品品牌", "${data["brandName"]}"),
                _rowText("库存数量", "${data["stockNum"]}"),
                _rowText("采购数量", "${data["orderNum"]}"),
                _rowText("剩余收货数量", "${data["remainNum"]}"),
                //_rowText("收货数量", "${data["receiveNum"]}"),
                Visibility(
                  visible: widget.status != 0,
                    child: _rowText("收货数量", "${data["receiveNum"]}")
                ),
                Visibility(
                  visible: widget.status == 0,
                  child: Row(
                    children: [
                      Text('收货数量：', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                      Expanded(
                        child: TextField(
                          readOnly:  widget.status != 0,
                          controller: _quantityControllers["${data["id"]}"],
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            //suffixText: detail.unit,
                          ),
                          onChanged: (value){
                            _update("${data["productId"]}",value);
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )
          );
      }),
      bottomNavigationBar: Visibility(
        visible: widget.status == 0,
        child: SafeArea(child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 16),
            Expanded(child: ElevatedButton(onPressed: _isProcessing ? null : _showApproveDialog,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text("通过", style: TextStyle(color: Colors.white)))
            ),
            const SizedBox(width: 16),
            Expanded(child: OutlinedButton(onPressed: _isProcessing ? null : _showRejectDialog, child: const Text("拒绝", style: TextStyle(color: Colors.red)))),
            const SizedBox(width: 16),
          ],
        ),),
      ),
    );
  }


  void _showRejectDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('拒绝任务'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('请输入拒绝原因：'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: '拒绝原因',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context);
                _rejectMovement(controller.text.trim());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请输入拒绝原因')),
                );
              }
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }


  void _approveMovement() async {
    setState(() {
      _isProcessing = true;
    });
    try {
      var response = await Http.patch("/purchase/receive/sheet/approve/pass", data: {
        "id": widget.inboundOderId
      });
      if (response["code"] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('任务审核通过'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      SnackBarUtils.showError(context, '审核失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showApproveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认审核'),
        content: const Text('确认通过此任务？通过后将自动更新库存。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _approveMovement();
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void _rejectMovement(String reason) async {
    setState(() {
      _isProcessing = true;
    });
    try {
      var response = await Http.patch("/purchase/receive/sheet/approve/refuse", data: {
        "id": widget.inboundOderId,
        "refuseReason": reason
      });
      if (response["code"] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('任务已拒绝'),
            backgroundColor: AppTheme.warningColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      SnackBarUtils.showError(context, '拒绝失败: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _navigateToDetail(BuildContext context, String movementId) {
    print(movementId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovementDetailScreen(movementId: movementId),
      ),
    );
  }

  Widget _rowText(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label：', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Expanded(
            child: Text(value ?? "", style: const TextStyle(color: Colors.black87, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    _fetchInData();
    super.initState();
  }

  @override
  void dispose() {
    for (final controller in _quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}

