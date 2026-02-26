import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  List<File> _documents = [];

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    final dir = await getApplicationDocumentsDirectory();
    final files = dir.listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.pdf'))
        .toList();
    setState(() => _documents = files);
  }

  Future<void> _deleteDocument(File file) async {
    await file.delete();
    _loadDocuments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Documents')),
      body: _documents.isEmpty
          ? const Center(child: Text('Aucun document scanné'))
          : ListView.builder(
              itemCount: _documents.length,
              itemBuilder: (context, index) {
                final file = _documents[index];
                final name = file.path.split('/').last;
                return ListTile(
                  leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                  title: Text(name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteDocument(file),
                  ),
                );
              },
            ),
    );
  }
}