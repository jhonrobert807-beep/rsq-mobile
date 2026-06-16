import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<UserProvider>().loadAllUsers();
      }
    });
  }

  void _filterUsers(String query) {
    final provider = context.read<UserProvider>();
    if (query.isEmpty) {
      _filteredUsers = provider.users;
    } else {
      _filteredUsers = provider.users
          .where((user) =>
              user.name.toLowerCase().contains(query.toLowerCase()) ||
              (user.email?.toLowerCase().contains(query.toLowerCase()) ?? false))
          .toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.blue,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 15),
                  Text('Error: ${userProvider.error}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => userProvider.loadAllUsers(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final users = _filteredUsers.isEmpty && _searchController.text.isEmpty
              ? userProvider.users
              : _filteredUsers;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterUsers,
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              Expanded(
                child: users.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isEmpty
                              ? 'No users found'
                              : 'No results for "${_searchController.text}"',
                        ),
                      )
                    : ListView.builder(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return _buildUserTile(context, user, userProvider);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserTile(
      BuildContext context, UserModel user, UserProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(user.name[0]),
        ),
        title: Text(user.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email ?? 'No email'),
            Text(user.phone ?? 'No phone',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text('Role: ${user.role}',
                style: const TextStyle(fontSize: 12, color: Colors.blue)),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('View'),
              onTap: () => _showUserDetails(user),
            ),
            PopupMenuItem(
              child: const Text('Edit'),
              onTap: () => _showEditDialog(user, provider),
            ),
            PopupMenuItem(
              child: const Text('Delete'),
              onTap: () => _showDeleteConfirm(user, provider),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserDetails(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('ID', user.id),
              _detailRow('Email', user.email ?? 'N/A'),
              _detailRow('Phone', user.phone ?? 'N/A'),
              _detailRow('Role', user.role),
              _detailRow('Verified', user.verified ? 'Yes' : 'No'),
              _detailRow('Active', user.isActive ? 'Yes' : 'No'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }

  void _showEditDialog(UserModel user, UserProvider provider) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email ?? '');
    final phoneController = TextEditingController(text: user.phone ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!mounted) return;
              try {
                await provider.updateUser(
                  user.id,
                  name: nameController.text,
                  email: emailController.text,
                  phone: phoneController.text,
                );
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User updated successfully')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(UserModel user, UserProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!mounted) return;
              try {
                await provider.deleteUser(user.id);
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User deleted successfully')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
