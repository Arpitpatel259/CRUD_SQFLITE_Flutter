import 'package:flutter/material.dart';
import 'package:crud_sqflite/db_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _allData = [];

  // Value Controller
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  /// Get All Data
  void _refreshData() async {
    final data = await SQLHelper.getAllData();
    setState(() {
      _allData = data;
      _isLoading = false;
    });
  }

  /// Add Data
  Future<void> _addData() async {
    await SQLHelper.insertData(_titleController.text, _descController.text);
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
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.redAccent,
      content: Text("Data Deleted with id no : ${id.toString()}"),
    ));
    _refreshData();
  }

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

  // Basic Loading View
  Widget _buildSkeletonLoader() {
    return ListView.builder(
      itemCount: 5, // Number of skeleton items to show
      itemBuilder: (context, index) => Card(
        margin: const EdgeInsets.all(15),
        child: ListTile(
          title: Container(
            height: 20,
            width: double.infinity,
            color: Colors.grey[300],
          ),
          subtitle: Container(
            height: 14,
            width: double.infinity,
            color: Colors.grey[300],
            margin: const EdgeInsets.only(top: 10),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEAF4),
      appBar: AppBar(
        title: const Text(
          "CRUD Operation",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black87,
      ),
      body:
          _isLoading // if it is true than called Skeleton else called Listview.
              ? _buildSkeletonLoader()
              : _allData.isEmpty
                  ? const Center(
                      child: Text("No Data Found"),
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
                          subtitle: Text(_allData[index]['desc'] +
                              "\n" +
                              _allData[index]['createdAt']),
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
        backgroundColor: Colors.black,
        onPressed: () => showBottomSheet(null),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
