// lib/providers/user_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waste_sorter_app/models/user_models.dart';
import 'package:waste_sorter_app/services/authentication/auth.dart';

final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authService = AuthService();
  return await authService.getCurrentUser();
});
