import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  Future<void> _scanDocument(BuildContext context) async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission caméra refusée')),
        );
        return;
      }

      final pictures = await CunningDocumentScanner.getPictures(
          noOfPages: 10, isGalleryImportAllowed: true);
      if (pictures == null || pictures.isEmpty) return;

      // Demander le nom du fichier
      final nameController = TextEditingController(
          text: 'scan_${DateTime.now().millisecondsSinceEpoch}');
      final fileName = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Nommer le document'),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Nom du fichier'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, nameController.text),
              child: const Text('Sauvegarder'),
            ),
          ],
        ),
      );

      if (fileName == null || fileName.isEmpty) return;

      final pdf = pw.Document();
      for (final path in pictures) {
        final image = pw.MemoryImage(File(path).readAsBytesSync());
        pdf.addPage(pw.Page(build: (_) => pw.Center(child: pw.Image(image))));
      }

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName.pdf');
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Document sauvegardé : $fileName.pdf')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner')),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => _scanDocument(context),
          icon: const Icon(Icons.camera_alt),
          label: const Text('Scanner un document'),
        ),
      ),
    );
  }
}