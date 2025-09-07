class Part {
  Part({
    this.id,
    this.createdAt,
    required this.partName,
    this.partDescription,
    this.partImageUrl,
    this.partLocation,
    this.partNumber,
    this.partStatus,
  });

  // Factory constructor for creating from JSON (Supabase response)
  factory Part.fromJson(Map<String, dynamic> json) {
    return Part(
      id: json['id'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      partName: json['part_name'] as String,
      partDescription: json['part_description'] as String?,
      partImageUrl: json['part_image_url'] as String?,
      partLocation: json['part_location'] as String?,
      partNumber: json['part_number'] as String?,
      partStatus: json['part_status'] as String? ?? 'Active',
    );
  }
  final int? id;
  final DateTime? createdAt;
  final String partName;
  final String? partDescription;
  final String? partImageUrl;
  final String? partLocation;
  final String? partNumber;
  final String? partStatus;

  // Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      'part_name': partName,
      if (partDescription != null) 'part_description': partDescription,
      if (partImageUrl != null) 'part_image_url': partImageUrl,
      if (partLocation != null) 'part_location': partLocation,
      if (partNumber != null) 'part_number': partNumber,
      if (partStatus != null) 'part_status': partStatus,
    };
  }

  // Copy with method for updating
  Part copyWith({
    int? id,
    DateTime? createdAt,
    String? partName,
    String? partDescription,
    String? partImageUrl,
    String? partLocation,
    String? partNumber,
    String? partStatus,
  }) {
    return Part(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      partName: partName ?? this.partName,
      partDescription: partDescription ?? this.partDescription,
      partImageUrl: partImageUrl ?? this.partImageUrl,
      partLocation: partLocation ?? this.partLocation,
      partNumber: partNumber ?? this.partNumber,
      partStatus: partStatus ?? this.partStatus,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Part && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Part(id: $id, partName: $partName, partNumber: $partNumber)';
  }

  // Helper methods for display
  String get displayName => partName;
  String get displayNumber => partNumber ?? 'No Part Number';
  String get displayLocation => partLocation ?? 'No Location';
  String get displayStatus => partStatus ?? 'Active';
  bool get isActive => (partStatus ?? 'Active') == 'Active';
  bool get hasImage => partImageUrl != null && partImageUrl!.isNotEmpty;

  // Debug method to print part details
  void printDetails() {
    print('Part Details:');
    print('  ID: $id');
    print('  Name: $partName');
    print('  Number: $partNumber');
    print('  Status: $partStatus');
    print('  Location: $partLocation');
  }
}
