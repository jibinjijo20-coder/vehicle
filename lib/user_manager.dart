import 'package:supabase_flutter/supabase_flutter.dart';

class UserManager {
  static final UserManager _instance = UserManager._internal();
  factory UserManager() => _instance;
  UserManager._internal();

  final _supabase = Supabase.instance.client;
  List<String> _allowedUsers = [];

  List<String> get allowedUsers => List.unmodifiable(_allowedUsers);

  Future<void> fetchUsers() async {
    try {
      final data = await _supabase.from('drivers').select('full_name');
      _allowedUsers = (data as List)
          .map((row) => row['full_name'] as String)
          .toList();
    } catch (e) {
      print('Error fetching drivers: $e');
    }
  }

  Future<void> addUser(String username) async {
    if (username.isNotEmpty && !_allowedUsers.contains(username)) {
      try {
        await _supabase.from('drivers').insert({'full_name': username});
        _allowedUsers.add(username);
      } catch (e) {
        print('Error adding driver: $e');
      }
    }
  }

  Future<void> removeUser(String username) async {
    try {
      await _supabase.from('drivers').delete().eq('full_name', username);
      _allowedUsers.remove(username);
    } catch (e) {
      print('Error removing driver: $e');
    }
  }

  bool isValidUser(String username) {
    return _allowedUsers.any(
      (user) => user.toLowerCase() == username.toLowerCase(),
    );
  }
}

final userManager = UserManager();
