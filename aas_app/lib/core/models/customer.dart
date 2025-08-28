class Customer {
  final int id;
  final DateTime createdAt;
  final String clientName;
  final String? contactName;
  final String? contactNumber;
  final String? contactEmail;
  final String? address;
  final String? industrySector;
  final String? contactChannel;
  final String? notes;

  Customer({
    required this.id,
    required this.createdAt,
    required this.clientName,
    this.contactName,
    this.contactNumber,
    this.contactEmail,
    this.address,
    this.industrySector,
    this.contactChannel,
    this.notes,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      clientName: json['client_name'] as String,
      contactName: json['contact_name'] as String?,
      contactNumber: json['contact_number'] as String?,
      contactEmail: json['contact_email'] as String?,
      address: json['address'] as String?,
      industrySector: json['industry_sector'] as String?,
      contactChannel: json['contact_channel'] as String?,
      notes: json['notes'] as String?,
    );
  }

  factory Customer.fromClient(dynamic client) {
    return Customer(
      id: client.id,
      createdAt: client.createdAt,
      clientName: client.clientName,
      contactName: client.contactName,
      contactNumber: client.contactNumber,
      contactEmail: client.contactEmail,
      address: client.address,
      industrySector: client.industrySector,
      contactChannel: client.contactChannel,
      notes: client.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'client_name': clientName,
      'contact_name': contactName,
      'contact_number': contactNumber,
      'contact_email': contactEmail,
      'address': address,
      'industry_sector': industrySector,
      'contact_channel': contactChannel,
      'notes': notes,
    };
  }

  Customer copyWith({
    int? id,
    DateTime? createdAt,
    String? clientName,
    String? contactName,
    String? contactNumber,
    String? contactEmail,
    String? address,
    String? industrySector,
    String? contactChannel,
    String? notes,
  }) {
    return Customer(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      clientName: clientName ?? this.clientName,
      contactName: contactName ?? this.contactName,
      contactNumber: contactNumber ?? this.contactNumber,
      contactEmail: contactEmail ?? this.contactEmail,
      address: address ?? this.address,
      industrySector: industrySector ?? this.industrySector,
      contactChannel: contactChannel ?? this.contactChannel,
      notes: notes ?? this.notes,
    );
  }
}

