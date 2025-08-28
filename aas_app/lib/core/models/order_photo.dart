class OrderPhoto {
  final String id;
  final int orderId;
  final String photoUrl;
  final String? photoName;
  final String? photoDescription;
  final DateTime uploadedAt;
  final String uploadedBy;
  final String? uploaderName;

  OrderPhoto({
    required this.id,
    required this.orderId,
    required this.photoUrl,
    this.photoName,
    this.photoDescription,
    required this.uploadedAt,
    required this.uploadedBy,
    this.uploaderName,
  });

  factory OrderPhoto.fromJson(Map<String, dynamic> json) {
    return OrderPhoto(
      id: json['id'] as String,
      orderId: json['order_id'] as int,
      photoUrl: json['photo_url'] as String,
      photoName: json['photo_name'] as String?,
      photoDescription: json['photo_description'] as String?,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
      uploadedBy: json['uploaded_by'] as String,
      uploaderName: json['uploader_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'photo_url': photoUrl,
      'photo_name': photoName,
      'photo_description': photoDescription,
      'uploaded_at': uploadedAt.toIso8601String(),
      'uploaded_by': uploadedBy,
      'uploader_name': uploaderName,
    };
  }

  OrderPhoto copyWith({
    String? id,
    int? orderId,
    String? photoUrl,
    String? photoName,
    String? photoDescription,
    DateTime? uploadedAt,
    String? uploadedBy,
    String? uploaderName,
  }) {
    return OrderPhoto(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      photoUrl: photoUrl ?? this.photoUrl,
      photoName: photoName ?? this.photoName,
      photoDescription: photoDescription ?? this.photoDescription,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploaderName: uploaderName ?? this.uploaderName,
    );
  }

  @override
  String toString() {
    return 'OrderPhoto(id: $id, orderId: $orderId, photoUrl: $photoUrl, photoName: $photoName, photoDescription: $photoDescription, uploadedAt: $uploadedAt, uploadedBy: $uploadedBy, uploaderName: $uploaderName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderPhoto &&
        other.id == id &&
        other.orderId == orderId &&
        other.photoUrl == photoUrl &&
        other.photoName == photoName &&
        other.photoDescription == photoDescription &&
        other.uploadedAt == uploadedAt &&
        other.uploadedBy == uploadedBy &&
        other.uploaderName == uploaderName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        orderId.hashCode ^
        photoUrl.hashCode ^
        photoName.hashCode ^
        photoDescription.hashCode ^
        uploadedAt.hashCode ^
        uploadedBy.hashCode ^
        uploaderName.hashCode;
  }
}
