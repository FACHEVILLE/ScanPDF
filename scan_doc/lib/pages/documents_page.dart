import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';

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

  Future<void> _renameDocument(File file) async {
    final name = file.path.split('/').last.replaceAll('.pdf', '');
    final controller = TextEditingController(text: name);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renommer'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('OK')),
        ],
      ),
    );
    if (newName == null || newName.isEmpty) return;
    final dir = file.parent;
    await file.rename('${dir.path}/$newName.pdf');
    _loadDocuments();
  }

  void _showOptions(BuildContext context, File file) {
    final name = file.path.split('/').last;
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Partager'),
              onTap: () {
                Navigator.pop(context);
                Share.shareXFiles([XFile(file.path)], text: name);
              },
            ),
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline),
              title: const Text('Renommer'),
              onTap: () {
                Navigator.pop(context);
                _renameDocument(file);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Supprimer', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteDocument(file);
              },
            ),
          ],
        ),
      ),
    );
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
                  onTap: () => OpenFilex.open(file.path),
                  onLongPress: () => _showOptions(context, file),
                );
              },
            ),
    );
  }
}