class Client {
  Client({
    this.id,
    this.createdAt,
    required this.clientName,
    this.contactName,
    this.contactNumber,
    this.contactEmail,
    this.address,
    this.industrySector,
    this.contactChannel,
    this.notes,
  });

  // Factory constructor for creating from JSON (Supabase response)
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
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
  final int? id; // bigserial in Supabase
  final DateTime? createdAt;
  final String clientName; // required
  final String? contactName;
  final String? contactNumber;
  final String? contactEmail;
  final String? address;
  final String? industrySector;
  final String? contactChannel;
  final String? notes;

  // Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      'client_name': clientName,
      if (contactName != null) 'contact_name': contactName,
      if (contactNumber != null) 'contact_number': contactNumber,
      if (contactEmail != null) 'contact_email': contactEmail,
      if (address != null) 'address': address,
      if (industrySector != null) 'industry_sector': industrySector,
      if (contactChannel != null) 'contact_channel': contactChannel,
      if (notes != null) 'notes': notes,
    };
  }

  // Copy with method for updating
  Client copyWith({
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
    return Client(
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Client && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Client(id: $id, clientName: $clientName, contactEmail: $contactEmail)';
  }

  // Helper methods for display
  String get displayName => clientName;
  String get primaryContact =>
      contactName ?? contactEmail ?? contactNumber ?? 'No contact info';
  String get contactInfo => contactEmail ?? contactNumber ?? 'No contact info';
  bool get hasContactInfo => contactEmail != null || contactNumber != null;
}
