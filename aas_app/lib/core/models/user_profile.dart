import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_role.dart';

class UserProfile {
  final String id;
  final String? displayName;
  final String? email;
  final UserRole role;
  final String? contactNumber;
  final String? department;
  final String? location;
  final String? empId;
  final DateTime createdAt;
  final String? assignedBy;
  final DateTime? assignedAt;
  final String status;

  UserProfile({
    required this.id,
    this.displayName,
    this.email,
    required this.role,
    this.contactNumber,
    this.department,
    this.location,
    this.empId,
    required this.createdAt,
    this.assignedBy,
    this.assignedAt,
    this.status = 'active',
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      displayName: json['display_name'] as String?,
      email: json['user_email'] as String?, // Fixed: use 'user_email' instead of 'email'
      role: UserRole.fromString(json['role'] as String? ?? 'unassigned'),
      contactNumber: json['contact_number'] as String?,
      department: json['department'] as String?,
      location: json['location'] as String?,
      empId: json['emp_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      assignedBy: json['assigned_by'] as String?,
      assignedAt: json['assigned_at'] != null 
          ? DateTime.parse(json['assigned_at'] as String) 
          : null,
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'user_email': email, // Fixed: use 'user_email' instead of 'email'
      'role': role.toDatabaseString(),
      'contact_number': contactNumber,
      'department': department,
      'location': location,
      'emp_id': empId,
      'created_at': createdAt.toIso8601String(),
      'assigned_by': assignedBy,
      'assigned_at': assignedAt?.toIso8601String(),
      'status': status,
    };
  }

  UserProfile copyWith({
    String? id,
    String? displayName,
    String? email,
    UserRole? role,
    String? contactNumber,
    String? department,
    String? location,
    String? empId,
    DateTime? createdAt,
    String? assignedBy,
    DateTime? assignedAt,
    String? status,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      role: role ?? this.role,
      contactNumber: contactNumber ?? this.contactNumber,
      department: department ?? this.department,
      location: location ?? this.location,
      empId: empId ?? this.empId,
      createdAt: createdAt ?? this.createdAt,
      assignedBy: assignedBy ?? this.assignedBy,
      assignedAt: assignedAt ?? this.assignedAt,
      status: status ?? this.status,
    );
  }

  bool get isUnassigned => role == UserRole.unassigned;
  bool get isAdmin => role == UserRole.admin;
  bool get isManager => role == UserRole.manager;
  bool get isSalesRep => role == UserRole.salesRep;
  bool get isTechnician => role == UserRole.technician;
  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';
}
