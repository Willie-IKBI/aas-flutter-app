import 'package:flutter/material.dart';
import '../../../../core/models/order.dart';
import '../../../../core/models/order_photo.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/services/photo_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../widgets/document_upload_widget.dart';
import '../widgets/document_list_widget.dart';
import '../widgets/photo_gallery.dart';
import '../../../admin/presentation/widgets/inline_editable_text.dart';

class OrderDetailsPage extends StatefulWidget {
  const OrderDetailsPage({
    super.key,
    required this.orderId,
  });
  final int orderId;

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage>
    with SingleTickerProviderStateMixin {
  Order? _order;
  List<OrderPhoto> _photos = [];
  bool _isLoading = true;
  String? _errorMessage;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadOrder();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final order = await OrderService.getOrderById(widget.orderId);
      final photos = await PhotoService.getOrderPhotos(widget.orderId);
      setState(() {
        _order = order;
        _photos = photos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load order: $e';
        _isLoading = false;
      });
    }
  }

  void _onDocumentUploadComplete() {
    // Refresh the document list
    setState(() {});
  }

  void _onPhotosChanged() {
    // Refresh the photos
    _loadOrder();
  }

  Future<void> _updateOrderField(String field, String newValue) async {
    try {
      var success = false;

      switch (field) {
        case 'equipmentType':
          success = await OrderService.updateOrder(
            orderId: _order!.id,
            equipmentType: newValue,
            notes: 'Equipment type updated',
          );
          break;
        case 'equipmentModel':
          success = await OrderService.updateOrder(
            orderId: _order!.id,
            equipmentModel: newValue,
            notes: 'Equipment model updated',
          );
          break;
        case 'equipmentSerialNumber':
          success = await OrderService.updateOrder(
            orderId: _order!.id,
            equipmentSerialNumber: newValue,
            notes: 'Equipment serial number updated',
          );
          break;
        case 'description':
          success = await OrderService.updateOrder(
            orderId: _order!.id,
            description: newValue,
            notes: 'Order description updated',
          );
          break;
      }

      if (success) {
        // Refresh the order data
        await _loadOrder();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$field updated successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update $field'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating $field: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      appBar: _buildAppBar(),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _order == null
                  ? _buildNotFoundState()
                  : _buildContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Order #${widget.orderId}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.onSurface,
      elevation: 0,
      centerTitle: false,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: _loadOrder,
            icon: const Icon(
              Icons.refresh,
              color: AppColors.primary,
            ),
            tooltip: 'Refresh',
          ),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.onSurfaceVariant,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: const [
          Tab(icon: Icon(Icons.info_outline), text: 'Details'),
          Tab(icon: Icon(Icons.photo_library_outlined), text: 'Photos'),
          Tab(icon: Icon(Icons.folder_outlined), text: 'Documents'),
          Tab(icon: Icon(Icons.history), text: 'History'),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          const Text(
            'Error Loading Order',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadOrder,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.onSurfaceVariant,
          ),
          SizedBox(height: 16),
          Text(
            'Order Not Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'The order you are looking for does not exist or has been deleted.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildDetailsTab(),
        _buildPhotosTab(),
        _buildDocumentsTab(),
        _buildHistoryTab(),
      ],
    );
  }

  Widget _buildDetailsTab() {
    return ResponsiveLayout(
      mobile: _buildMobileDetailsLayout(),
      tablet: _buildTabletDetailsLayout(),
      desktop: _buildDesktopDetailsLayout(),
    );
  }

  Widget _buildMobileDetailsLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildOrderHeader(),
          const SizedBox(height: 16),
          _buildOrderInformation(),
          const SizedBox(height: 16),
          _buildEquipmentInformation(),
          const SizedBox(height: 16),
          _buildCustomerInformation(),
          const SizedBox(height: 16),
          _buildSalesRepInformation(),
          const SizedBox(height: 16),
          _buildActions(),
          const SizedBox(height: 24), // Bottom padding for safe area
        ],
      ),
    );
  }

  Widget _buildTabletDetailsLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildOrderHeader(),
          const SizedBox(height: 24),
          _buildOrderInformation(),
          const SizedBox(height: 24),
          _buildEquipmentInformation(),
          const SizedBox(height: 24),
          _buildCustomerInformation(),
          const SizedBox(height: 24),
          _buildSalesRepInformation(),
          const SizedBox(height: 24),
          _buildActions(),
          const SizedBox(height: 32), // Bottom padding for safe area
        ],
      ),
    );
  }

  Widget _buildDesktopDetailsLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          _buildOrderHeader(),
          const SizedBox(height: 32),
          _buildOrderInformation(),
          const SizedBox(height: 32),
          _buildEquipmentInformation(),
          const SizedBox(height: 32),
          _buildCustomerInformation(),
          const SizedBox(height: 32),
          _buildSalesRepInformation(),
          const SizedBox(height: 32),
          _buildActions(),
          const SizedBox(height: 40), // Bottom padding for safe area
        ],
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.assignment,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${_order!.id}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _order!.customerName != null
                          ? _order!.customerName!
                          : 'Customer ID: ${_order!.customerId}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(_order!.status),
            ],
          ),
          if (_order!.description.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.outline.withValues(alpha: 0.1),
                ),
              ),
              child: InlineEditableText(
                key: ValueKey(
                    'description_${_order!.id}_${_order!.description}'),
                initialValue: _order!.description,
                hintText: 'Enter order description',
                onSave: (newValue) =>
                    _updateOrderField('description', newValue),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description cannot be empty';
                  }
                  return null;
                },
                textStyle: const TextStyle(
                  fontSize: 16,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderInformation() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.infoGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Order Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Order Date', _formatDate(_order!.orderDate)),
          _buildInfoRow('Status', _order!.status.toDisplayString()),
          _buildInfoRow(
              'Current Stage', _order!.currentStage.toDisplayString()),
          _buildInfoRow('Created', _formatDateTime(_order!.createdAt)),
          _buildInfoRow('Last Updated', _formatDateTime(_order!.createdAt)),
        ],
      ),
    );
  }

  Widget _buildEquipmentInformation() {
    if (_order!.equipmentType == null && _order!.equipmentModel == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.warningGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.build_outlined,
                  color: Colors.white,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Equipment Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (_order!.equipmentType != null)
            _buildEditableInfoRow(
                'Equipment Type', _order!.equipmentType!, 'equipmentType'),
          if (_order!.equipmentModel != null)
            _buildEditableInfoRow(
                'Equipment Model', _order!.equipmentModel!, 'equipmentModel'),
          if (_order!.equipmentSerialNumber != null)
            _buildEditableInfoRow('Serial Number',
                _order!.equipmentSerialNumber!, 'equipmentSerialNumber'),
        ],
      ),
    );
  }

  Widget _buildCustomerInformation() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.successGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_outline,
                  color: Colors.white,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Customer Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Customer',
              _order!.customerName ?? 'Customer ID: ${_order!.customerId}'),
          if (_order!.customerContactName != null)
            _buildInfoRow('Contact Person', _order!.customerContactName!),
        ],
      ),
    );
  }

  Widget _buildSalesRepInformation() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.people_outline,
                  color: Colors.white,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Sales Representative',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (_order!.salesRepId != null) ...[
            _buildInfoRow(
                'Sales Rep', _order!.salesRepName ?? _order!.salesRepId!),
            if (_order!.salesRepEmail != null)
              _buildInfoRow('Sales Rep Email', _order!.salesRepEmail!),
          ] else
            _buildInfoRow('Sales Rep', 'Not Assigned'),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onBackground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _generatePDF,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Generate PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.onSurface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.outline),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DocumentUploadWidget(
            orderId: widget.orderId,
            onUploadComplete: _onDocumentUploadComplete,
          ),
          const SizedBox(height: 24),
          DocumentListWidget(
            orderId: widget.orderId,
            onDocumentDeleted: _onDocumentUploadComplete,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: PhotoGallery(
        orderId: widget.orderId,
        photos: _photos,
        onPhotosChanged: _onPhotosChanged,
      ),
    );
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.outline.withValues(alpha: 0.2),
            ),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history,
                size: 64,
                color: AppColors.onSurfaceVariant,
              ),
              SizedBox(height: 16),
              Text(
                'Order History',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Order history and stage events will be displayed here',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case OrderStatus.inProgress:
        color = AppColors.info;
        label = 'In Progress';
        icon = Icons.pending;
        break;
      case OrderStatus.complete:
        color = AppColors.success;
        label = 'Completed';
        icon = Icons.check_circle;
        break;
      case OrderStatus.cancelled:
        color = AppColors.error;
        label = 'Cancelled';
        icon = Icons.cancel;
        break;
      case OrderStatus.waitingApproval:
        color = AppColors.warning;
        label = 'Waiting Approval';
        icon = Icons.schedule;
        break;
      default:
        color = AppColors.onSurfaceVariant;
        label = status.toDisplayString();
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.onSurface,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableInfoRow(String label, String value, String fieldName) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: InlineEditableText(
              key: ValueKey('${fieldName}_${_order!.id}_$value'),
              initialValue: value,
              hintText: 'Enter $label',
              onSave: (newValue) => _updateOrderField(fieldName, newValue),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '$label cannot be empty';
                }
                return null;
              },
              textStyle: const TextStyle(
                fontSize: 15,
                color: AppColors.onSurface,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _generatePDF() {
    // This would generate a PDF of the order
    NotificationService.showSuccessNotification(
      context,
      'PDF generation feature coming soon!',
    );
  }
}
