import 'package:crud_sqflite/db_helper.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _allData = [];
  bool _isLoading = true;

  /// Get All Data
  void _refreshData() async {
    final data = await SQLHelper.getAllData();
    setState(() {
      _allData = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  /// Add Data
  Future<void> _addData() async {
    await SQLHelper.createData(_titleController.text, _descController.text);
    _refreshData();
  }

  /// Update Data
  Future<void> _updateData(int id) async {
    await SQLHelper.updateData(id, _titleController.text, _descController.text);
    _refreshData();
  }

  /// Delete Data
  void _deleteData(int id) async {
    await SQLHelper.deleteData(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.redAccent,
      content: Text("Data Deleted"),
    ));
    _refreshData();
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  void showBottomSheet(int? id) async {
    if (id != null) {
      final existingData =
      _allData.firstWhere((element) => element['id'] == id);
      _titleController.text = existingData['title'];
      _descController.text = existingData['desc'];
    }

    showModalBottomSheet(
        elevation: 5,
        isScrollControlled: true,
        context: context,
        builder: (_) => Container(
          padding: EdgeInsets.only(
              top: 30,
              left: 15,
              right: 15,
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Title",
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Description",
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (id == null) {
                      await _addData();
                    }
                    if (id != null) {
                      await _updateData(id);
                    }

                    _titleController.text = "";
                    _descController.text = "";

                    Navigator.of(context).pop();
                    debugPrint("Data data ");
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Text(
                      id == null ? "Add Data" : "Update Data",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEAF4),
      appBar: AppBar(
        title: const Text("CRUD Operation"),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: _allData.length,
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.all(15),
          child: ListTile(
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(
                _allData[index]['title'],
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            subtitle: Text(_allData[index]['desc']),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    showBottomSheet(_allData[index]['id']);
                  },
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.indigo,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _deleteData(_allData[index]['id']);
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showBottomSheet(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
