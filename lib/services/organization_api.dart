import '../core/errors/app_exception.dart';
import 'api_service.dart';

class OrganizationApi {
  static Future<Map<String, dynamic>> createOrganization({
    required String name,
    required String address,
    String? phone,
    String? email,
    String? website,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        'address': address,
      };
      if (phone != null) data['phone'] = phone;
      if (email != null) data['email'] = email;
      if (website != null) data['website'] = website;

      final result = await ApiService.post('/organizations', data: data);
      return result as Map<String, dynamic>;
    } catch (e) {
      throw AppException('Failed to create organization: ${e.toString()}');
    }
  }

  static Future<List<Map<String, dynamic>>> getAllOrganizations() async {
    try {
      final result = await ApiService.get('/organizations');
      return (result as List).map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      throw AppException('Failed to fetch organizations: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> getOrganizationById(String id) async {
    try {
      final result = await ApiService.get('/organizations/$id');
      return result as Map<String, dynamic>;
    } catch (e) {
      throw AppException('Failed to fetch organization: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> updateOrganization(String id, {
    String? name,
    String? address,
    String? phone,
    String? email,
    String? website,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (address != null) data['address'] = address;
      if (phone != null) data['phone'] = phone;
      if (email != null) data['email'] = email;
      if (website != null) data['website'] = website;

      final result = await ApiService.patch('/organizations/$id', data: data);
      return result as Map<String, dynamic>;
    } catch (e) {
      throw AppException('Failed to update organization: ${e.toString()}');
    }
  }

  static Future<void> deleteOrganization(String id) async {
    try {
      await ApiService.delete('/organizations/$id');
    } catch (e) {
      throw AppException('Failed to delete organization: ${e.toString()}');
    }
  }
}
