import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_crud_operation/database/sql_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SQLITE',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _journals = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = true;

  void _refreshJournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _journals = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshJournals();
    print('number of items ${_journals.length}');
  }

  Future<void> _addItem() async {
    await SQLHelper.createItem(
        _titleController.text, _descriptionController.text);
    _refreshJournals();
    print('number of items ${_journals.length}');
  }

  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id, _titleController.text, _descriptionController.text);
    _refreshJournals();
  }

  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully deleted a journal')));
        _refreshJournals();
  }

  void showForm(int? id) async {
    if (id != null) {
      final existingJournal =
          _journals.firstWhere((element) => element['id'] == id);
      _titleController.text = existingJournal['title'];
      _descriptionController.text = existingJournal['description'];
    }
    showModalBottomSheet(
      context: context,
      builder: (_) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
              left: 15,
              top: 15,
              right: 15,
              bottom: MediaQuery.of(context).viewInsets.bottom + 130),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(hintText: 'Title'),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(hintText: 'Description'),
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () async {
                    if (id == null) {
                      await _addItem();
                    }
                    if (id != null) {
                      // await _updateItem(id);
                      await _updateItem(id);
                    }
                    //clear the text field
                    _titleController.text = '';
                    _descriptionController.text = '';

                    //Close the bottom sheet
                    Navigator.of(context).pop();
                  },
                  child: Text(id == null ? 'Create New' : 'Update'))
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.green, size: 22),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Personal Todo',
          style: TextStyle(color: Colors.green, fontSize: 25,fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Icon(Icons.more_vert_rounded, color: Colors.green),
          )
        ],
      ),
      body: ListView.builder(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(parent: BouncingScrollPhysics()),
        itemCount: _journals.length,
        itemBuilder: ((context, index) {
          return Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.green.shade50, width: 2),
              borderRadius: BorderRadius.circular(15)
            ),
            elevation: 15,
            child: ListTile(
                title: Text(_journals[index]['title']),
                subtitle: Text(_journals[index]['description']),
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () => showForm(_journals[index]['id']),
                          icon: Icon(
                            Icons.edit_rounded,
                            color: Colors.green,
                          )),
                      IconButton(
                          onPressed: () => _deleteItem(_journals[index]['id']),
                          icon: Icon(
                            Icons.delete_rounded,
                            color: Colors.red,
                          ))
                    ],
                  ),
                )),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => showForm(null),
        child: Icon(Icons.add),
      ),
    );
  }
}
