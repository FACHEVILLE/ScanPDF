import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  Future<void> _scanDocument(BuildContext context) async {
    try {
      final pictures = await CunningDocumentScanner.getPictures(noOfPages: 10, isGalleryImportAllowed: true);
      if (pictures == null || pictures.isEmpty) return;

      final pdf = pw.Document();
      for (final path in pictures) {
        final image = pw.MemoryImage(File(path).readAsBytesSync());
        pdf.addPage(pw.Page(build: (_) => pw.Center(child: pw.Image(image))));
      }

      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Document sauvegardé : $fileName')),
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