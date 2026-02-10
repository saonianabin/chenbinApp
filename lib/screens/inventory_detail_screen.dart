import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';
import '../models/inventory_item.dart';
import '../utils/app_theme.dart';

class InventoryDetailScreen extends StatefulWidget {
  final String itemId;

  const InventoryDetailScreen({
    super.key,
    required this.itemId,
  });

  @override
  State<InventoryDetailScreen> createState() => _InventoryDetailScreenState();
}

class _InventoryDetailScreenState extends State<InventoryDetailScreen> {
  InventoryItem? _item;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  // 编辑控制器
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _currentStockController = TextEditingController();
  final TextEditingController _frozenStockController = TextEditingController();
  final TextEditingController _minStockController = TextEditingController();
  final TextEditingController _maxStockController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentStockController.dispose();
    _frozenStockController.dispose();
    _minStockController.dispose();
    _maxStockController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadItem() {
    final inventoryProvider = context.read<InventoryProvider>();
    final item = inventoryProvider.getItemById(widget.itemId);
    if (item != null) {
      setState(() {
        _item = item;
        _nameController.text = item.name;
        _currentStockController.text = item.currentStock.toString();
        _frozenStockController.text = item.frozenStock.toString();
        _minStockController.text = item.minStock.toString();
        _maxStockController.text = item.maxStock.toString();
        _locationController.text = item.location ?? '';
        _descriptionController.text = item.description ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_item == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑商品' : '商品详情'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          if (_isEditing)
            TextButton(
              onPressed: _saveItem,
              child: const Text(
                '保存',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 商品基本信息卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '基本信息',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // SKU (只读)
                      _buildInfoRow('SKU', _item!.sku),
                      const SizedBox(height: 16),
                      // 商品名称
                      _buildTextFormField(
                        controller: _nameController,
                        label: '商品名称',
                        isRequired: true,
                        enabled: _isEditing,
                      ),
                      const SizedBox(height: 16),
                      // 分类
                      _buildInfoRow('分类', _item!.category),
                      const SizedBox(height: 16),
                      // 单位
                      _buildInfoRow('单位', _item!.unit),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 库存信息卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '库存信息666',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 现有库存
                    _buildTextFormField(
                      controller: _currentStockController,
                      label: '现有库存4444',
                      isRequired: true,
                      enabled: _isEditing,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    // 冻结库存
                    _buildTextFormField(
                      controller: _frozenStockController,
                      label: '冻结库存',
                      isRequired: true,
                      enabled: _isEditing,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    // 最小库存
                    _buildTextFormField(
                      controller: _minStockController,
                      label: '最小库存444',
                      isRequired: true,
                      enabled: _isEditing,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    // 最大库存
                    _buildTextFormField(
                      controller: _maxStockController,
                      label: '最大库存',
                      isRequired: true,
                      enabled: _isEditing,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    // 库存状态显示
                    _buildStockStatusCard(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 其他信息卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '其他信息',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 库位
                    _buildTextFormField(
                      controller: _locationController,
                      label: '库位',
                      enabled: _isEditing,
                    ),
                    const SizedBox(height: 16),
                    // 描述
                    _buildTextFormField(
                      controller: _descriptionController,
                      label: '描述',
                      enabled: _isEditing,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    // 最后更新时间
                    _buildInfoRow('最后更新', _formatDateTime(_item!.lastUpdated)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    bool enabled = true,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: '$label${isRequired ? ' *' : ''}',
        border: const OutlineInputBorder(),
        filled: !enabled,
        fillColor: Colors.grey[100],
      ),
      validator: isRequired && enabled
          ? (value) {
              if (value == null || value.isEmpty) {
                return '请输入$label';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildStockStatusCard() {
    final availableStock = _item!.currentStock - _item!.frozenStock;
    final stockStatus = _item!.stockStatus;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getStatusColor(_item!.stockStatusColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getStatusColor(_item!.stockStatusColor).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '可用库存:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                '$availableStock ${_item!.unit}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(_item!.stockStatusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '库存状态:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                stockStatus,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(_item!.stockStatusColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      try {
        final updatedItem = _item!.copyWith(
          name: _nameController.text.trim(),
          currentStock: double.parse(_currentStockController.text),
          frozenStock: double.parse(_frozenStockController.text),
          minStock: double.parse(_minStockController.text),
          maxStock: double.parse(_maxStockController.text),
          location: _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          lastUpdated: DateTime.now(),
        );

        context.read<InventoryProvider>().updateItem(updatedItem);

        setState(() {
          _item = updatedItem;
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('保存成功'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('保存失败: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String statusColor) {
    switch (statusColor) {
      case 'red':
        return AppTheme.errorColor;
      case 'orange':
        return AppTheme.warningColor;
      case 'green':
        return AppTheme.successColor;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}