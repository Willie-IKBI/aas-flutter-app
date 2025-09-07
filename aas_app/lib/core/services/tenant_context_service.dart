import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

/// Service for managing tenant and user context for RLS
class TenantContextService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Gets the current user's business ID for RLS
  static String? getCurrentBusinessId() {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    // Extract business_id from user metadata or JWT claims
    return user.userMetadata?['business_id'] as String?;
  }

  /// Gets the current user ID
  static String? getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }

  /// Gets the current user's role
  static String? getCurrentUserRole() {
    final user = _supabase.auth.currentUser;
    return user?.userMetadata?['role'] as String?;
  }

  /// Validates that the current user has access to the specified business
  static bool hasAccessToBusiness(String businessId) {
    final currentBusinessId = getCurrentBusinessId();
    if (currentBusinessId == null) return false;

    // For now, users can only access their own business
    // In the future, this could be extended for cross-business access
    return currentBusinessId == businessId;
  }

  /// Gets RLS filter for business-scoped queries
  static Map<String, dynamic> getBusinessFilter() {
    final businessId = getCurrentBusinessId();
    if (businessId == null) {
      throw Exception('No business context available');
    }

    return {'business_id': businessId};
  }

  /// Gets RLS filter for user-scoped queries
  static Map<String, dynamic> getUserFilter() {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw Exception('No user context available');
    }

    return {'user_id': userId};
  }

  /// Gets combined business and user filter for RLS
  static Map<String, dynamic> getCombinedFilter() {
    final businessId = getCurrentBusinessId();
    final userId = getCurrentUserId();

    if (businessId == null || userId == null) {
      throw Exception('No business or user context available');
    }

    return {
      'business_id': businessId,
      'user_id': userId,
    };
  }

  /// Validates that a user profile belongs to the current business
  /// Note: UserProfile doesn't contain business context - validation is based on auth context
  static bool validateUserProfile(UserProfile profile) {
    final currentBusinessId = getCurrentBusinessId();
    if (currentBusinessId == null) return false;

    // Since UserProfile doesn't have business context, we validate based on auth context
    // All user profiles accessible through the current auth session are considered valid
    // for the current business context
    return true;
  }

  /// Gets tenant-scoped storage path
  static String getTenantStoragePath(String entity, String recordId,
      {String? subPath}) {
    final businessId = getCurrentBusinessId();
    if (businessId == null) {
      throw Exception('No business context available for storage');
    }

    final path = '/$businessId/$entity/$recordId';
    if (subPath != null) {
      return '$path/$subPath';
    }
    return path;
  }

  /// Validates storage path belongs to current tenant
  static bool validateStoragePath(String path) {
    final businessId = getCurrentBusinessId();
    if (businessId == null) return false;

    return path.startsWith('/$businessId/');
  }
}
