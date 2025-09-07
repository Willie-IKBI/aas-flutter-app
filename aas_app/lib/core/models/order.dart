enum OrderStatus {
  draft,
  inProgress,
  waitingApproval,
  approved,
  inProduction,
  complete,
  cancelled;

  static OrderStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'draft':
        return OrderStatus.draft;
      case 'in_progress':
        return OrderStatus.inProgress;
      case 'waiting_approval':
        return OrderStatus.waitingApproval;
      case 'approved':
        return OrderStatus.approved;
      case 'in_production':
        return OrderStatus.inProduction;
      case 'complete':
        return OrderStatus.complete;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.draft;
    }
  }

  String toDatabaseString() {
    switch (this) {
      case OrderStatus.draft:
        return 'draft';
      case OrderStatus.inProgress:
        return 'in_progress';
      case OrderStatus.waitingApproval:
        return 'waiting_approval';
      case OrderStatus.approved:
        return 'approved';
      case OrderStatus.inProduction:
        return 'in_production';
      case OrderStatus.complete:
        return 'complete';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  String toDisplayString() {
    switch (this) {
      case OrderStatus.draft:
        return 'Draft';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.waitingApproval:
        return 'Waiting Approval';
      case OrderStatus.approved:
        return 'Approved';
      case OrderStatus.inProduction:
        return 'In Production';
      case OrderStatus.complete:
        return 'Complete';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

enum OrderStage {
  orderCaptured,
  washBay,
  assessment,
  quotation,
  approval,
  jobCommence,
  paint,
  dispatch;

  static OrderStage fromString(String value) {
    switch (value.toLowerCase()) {
      case 'order_captured':
        return OrderStage.orderCaptured;
      case 'wash_bay':
        return OrderStage.washBay;
      case 'assessment':
        return OrderStage.assessment;
      case 'quotation':
        return OrderStage.quotation;
      case 'approval':
        return OrderStage.approval;
      case 'job_commence':
        return OrderStage.jobCommence;
      case 'paint':
        return OrderStage.paint;
      case 'dispatch':
        return OrderStage.dispatch;
      default:
        return OrderStage.orderCaptured;
    }
  }

  String toDatabaseString() {
    switch (this) {
      case OrderStage.orderCaptured:
        return 'order_captured';
      case OrderStage.washBay:
        return 'wash_bay';
      case OrderStage.assessment:
        return 'assessment';
      case OrderStage.quotation:
        return 'quotation';
      case OrderStage.approval:
        return 'approval';
      case OrderStage.jobCommence:
        return 'job_commence';
      case OrderStage.paint:
        return 'paint';
      case OrderStage.dispatch:
        return 'dispatch';
    }
  }

  String toDisplayString() {
    switch (this) {
      case OrderStage.orderCaptured:
        return 'Order Captured';
      case OrderStage.washBay:
        return 'Wash Bay';
      case OrderStage.assessment:
        return 'Assessment';
      case OrderStage.quotation:
        return 'Quotation';
      case OrderStage.approval:
        return 'Approval';
      case OrderStage.jobCommence:
        return 'Job Commence';
      case OrderStage.paint:
        return 'Paint';
      case OrderStage.dispatch:
        return 'Dispatch';
    }
  }
}

class Order {
  Order({
    required this.id,
    required this.createdAt,
    required this.orderDate,
    required this.description,
    required this.capturedBy,
    required this.customerId,
    this.salesRepId,
    required this.status,
    required this.currentStage,
    this.pdfUrl,
    this.equipmentType,
    this.equipmentModel,
    this.equipmentSerialNumber,
    this.customerName,
    this.customerContactName,
    this.salesRepName,
    this.salesRepEmail,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // Extract customer information from the joined data
    final customerData = json['customers'] as Map<String, dynamic>?;
    final salesRepData = json['sales_rep'] as Map<String, dynamic>?;

    return Order(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      orderDate: DateTime.parse(json['order_date'] as String),
      description: json['description'] as String,
      capturedBy: json['captured_by'] as String,
      customerId: json['customer_id'] as int,
      salesRepId: json['sales_rep_id'] as String?,
      status: OrderStatus.fromString(json['status'] as String),
      currentStage: OrderStage.fromString(json['current_stage'] as String),
      pdfUrl: json['pdf_url'] as String?,
      equipmentType: json['equipment_type'] as String?,
      equipmentModel: json['equipment_model'] as String?,
      equipmentSerialNumber: json['equipment_serial_number'] as String?,
      customerName: customerData?['client_name'] as String? ??
          'Customer #${json['customer_id']}',
      customerContactName: customerData?['contact_name'] as String?,
      salesRepName: salesRepData?['display_name'] as String?,
      salesRepEmail: salesRepData?['user_email'] as String?,
    );
  }
  final int id;
  final DateTime createdAt;
  final DateTime orderDate;
  final String description;
  final String capturedBy;
  final int customerId;
  final String? salesRepId;
  final OrderStatus status;
  final OrderStage currentStage;
  final String? pdfUrl;
  final String? equipmentType;
  final String? equipmentModel;
  final String? equipmentSerialNumber;
  final String? customerName;
  final String? customerContactName;
  final String? salesRepName;
  final String? salesRepEmail;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'order_date': orderDate.toIso8601String(),
      'description': description,
      'captured_by': capturedBy,
      'customer_id': customerId,
      'sales_rep_id': salesRepId,
      'status': status.toDatabaseString(),
      'current_stage': currentStage.toDatabaseString(),
      'pdf_url': pdfUrl,
      'equipment_type': equipmentType,
      'equipment_model': equipmentModel,
      'equipment_serial_number': equipmentSerialNumber,
      'customer_name': customerName,
      'customer_contact_name': customerContactName,
      'sales_rep_name': salesRepName,
      'sales_rep_email': salesRepEmail,
    };
  }

  Order copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? orderDate,
    String? description,
    String? capturedBy,
    int? customerId,
    String? salesRepId,
    OrderStatus? status,
    OrderStage? currentStage,
    String? pdfUrl,
    String? equipmentType,
    String? equipmentModel,
    String? equipmentSerialNumber,
    String? customerName,
    String? customerContactName,
    String? salesRepName,
    String? salesRepEmail,
  }) {
    return Order(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      orderDate: orderDate ?? this.orderDate,
      description: description ?? this.description,
      capturedBy: capturedBy ?? this.capturedBy,
      customerId: customerId ?? this.customerId,
      salesRepId: salesRepId ?? this.salesRepId,
      status: status ?? this.status,
      currentStage: currentStage ?? this.currentStage,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      equipmentType: equipmentType ?? this.equipmentType,
      equipmentModel: equipmentModel ?? this.equipmentModel,
      equipmentSerialNumber:
          equipmentSerialNumber ?? this.equipmentSerialNumber,
      customerName: customerName ?? this.customerName,
      customerContactName: customerContactName ?? this.customerContactName,
      salesRepName: salesRepName ?? this.salesRepName,
      salesRepEmail: salesRepEmail ?? this.salesRepEmail,
    );
  }
}
