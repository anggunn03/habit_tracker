import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

final supabase = Supabase.instance.client;

class HabitTrackerPage extends StatefulWidget {
  const HabitTrackerPage({super.key});

  @override
  State<HabitTrackerPage> createState() => _HabitTrackerPageState();
}

class _HabitTrackerPageState extends State<HabitTrackerPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _loading = true;
  List<Map<String, dynamic>> _habits = [];

  @override
  void initState() {
    super.initState();
    _fetchHabits();
  }

  Future<void> _fetchHabits() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengguna belum login.')),
      );
      setState(() {
        _habits = [];
        _loading = false;
      });
      return;
    }

    setState(() => _loading = true);

    try {
    final data = await supabase
        .from('habits')
        .select()
        .eq('user_id', userId)
        .order('name');
      setState(() {
      _habits = List<Map<String, dynamic>>.from(data);
      _loading = false;
    });
  } catch (e) {
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal mengambil data: $e')),
    );
  }
}

  Future<void> _addHabit() async {
    final name = _nameController.text;
    final desc = _descController.text;
    final userId = supabase.auth.currentUser?.id;

    if (name.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan deskripsi tidak boleh kosong')),
      );
      return;
    }

    final newHabit = {
      'id': const Uuid().v4(),
      'name': name,
      'description': desc,
      'user_id': userId,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'done': false,
    };

    setState(() => _loading = true);
    try {
      await supabase.from('habits').insert(newHabit);
      _nameController.clear();
      _descController.clear();
      _fetchHabits();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan habit: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateHabitStatus(String id, bool done) async {
    setState(() => _loading = true);
    try {
      await supabase.from('habits').update({'done': done}).eq('id', id);
      _fetchHabits();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui status habit: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteHabit(String id) async {
    setState(() => _loading = true);
    try {
      await supabase.from('habits').delete().eq('id', id);
      _fetchHabits();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus habit: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Habit Tracker')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _habits.length,
              itemBuilder: (context, index) {
                final habit = _habits[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(habit['name']),
                    subtitle: habit['description'] != null ? Text(habit['description']) : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: habit['done'],
                          onChanged: (bool? value) {
                            _updateHabitStatus(habit['id'], value!);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteHabit(habit['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Tambah Habit'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama'),
                ),
                TextField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _addHabit();
                },
                child: const Text('Simpan'),
              )
            ],
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}