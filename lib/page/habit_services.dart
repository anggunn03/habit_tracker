import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:habit_tracker/page/model_habit.dart';
import 'dart:io';

class HabitService {
  final _client = Supabase.instance.client;

  String _validateUser() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Pengguna belum login.');
    }
    return userId;
  }

  Future<List<Habit>> fetchHabits() async {
    final userId = _validateUser();

    try {
      final response = await _client
          .from('habits')
          .select()
          .eq('user_id', userId)
          .order('name')
          .execute();

      if (response.error != null) {
        throw Exception('Gagal mengambil data: ${response.error!.message}');
      }

      if (response.data == null || response.data is! List) {
        throw Exception('Data yang diterima tidak valid.');
      }

      final data = response.data as List;
      try {
        return data.map((e) => Habit.fromMap(e)).toList();
      } catch (e) {
        throw Exception('Data yang diterima memiliki format yang salah.');
      }
    } on SocketException {
      throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    } catch (e) {
      print('Error: $e');
      throw Exception('Terjadi kesalahan saat mengambil data.');
    }
  }

  Future<void> addHabit(Habit habit) async {
    final userId = _validateUser();

    if (habit.name.isEmpty) {
      throw Exception('Nama habit tidak boleh kosong.');
    }
    if (habit.description == null || habit.description!.isEmpty) {
      throw Exception('Deskripsi habit tidak boleh kosong.');
    }

    try {
      final data = habit.toMap(userId);
      final response = await _client.from('habits').insert(data).execute();

      if (response.error != null) {
        throw Exception('Gagal menambahkan habit: ${response.error!.message}');
      }
    } on SocketException {
      throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    } catch (e) {
      print('Error: $e');
      throw Exception('Terjadi kesalahan saat menambahkan habit.');
    }
  }

  Future<void> deleteHabit(String id) async {
    if (id.isEmpty) {
      throw Exception('ID habit tidak boleh kosong.');
    }

    try {
      final response = await _client.from('habits').delete().eq('id', id).execute();

      if (response.error != null) {
        throw Exception('Gagal menghapus habit: ${response.error!.message}');
      }
    } on SocketException {
      throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet Anda.');
    } catch (e) {
      print('Error: $e');
      throw Exception('Terjadi kesalahan saat menghapus habit.');
    }
  }
}