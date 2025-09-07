enum UserRole {
  unassigned,
  admin,
  manager,
  salesRep,
  technician;

  static UserRole fromString(String value) {
    switch (value.toLowerCase()) {
      case 'unassigned':
        return UserRole.unassigned;
      case 'admin':
        return UserRole.admin;
      case 'manager':
        return UserRole.manager;
      case 'salesrep':
      case 'sales_rep':
        return UserRole.salesRep;
      case 'technician':
        return UserRole.technician;
      default:
        return UserRole.unassigned; // Default to unassigned
    }
  }

  String toDisplayString() {
    switch (this) {
      case UserRole.unassigned:
        return 'Unassigned';
      case UserRole.admin:
        return 'Administrator';
      case UserRole.manager:
        return 'Manager';
      case UserRole.salesRep:
        return 'Sales Representative';
      case UserRole.technician:
        return 'Technician';
    }
  }

  String toDatabaseString() {
    switch (this) {
      case UserRole.unassigned:
        return 'unassigned';
      case UserRole.admin:
        return 'admin';
      case UserRole.manager:
        return 'manager';
      case UserRole.salesRep:
        return 'salesRep'; // Match the database enum value
      case UserRole.technician:
        return 'technician';
    }
  }

  bool get canAssignRoles => this == UserRole.admin;

  bool get canAccessDashboard =>
      this != UserRole.unassigned; // Unassigned users cannot access dashboard

  bool get canManageUsers => this == UserRole.admin || this == UserRole.manager;

  bool get canManageParts =>
      this == UserRole.admin ||
      this == UserRole.manager ||
      this == UserRole.technician;

  bool get canManageSales =>
      this == UserRole.admin ||
      this == UserRole.manager ||
      this == UserRole.salesRep;
}
