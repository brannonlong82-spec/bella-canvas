import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/drawing_point.dart';
import 'drawing_helper.dart';

class PdfUtility {
  static Future<ui.Image?> _loadUiImageFromBytes(Uint8List bytes) async {
    try {
      final completer = Completer<ui.Image>();
      ui.decodeImageFromList(bytes, (ui.Image img) {
        if (!completer.isCompleted) completer.complete(img);
      });
      return await completer.future;
    } catch (e) {
      debugPrint('Error loading ui.Image from bytes: $e');
      return null;
    }
  }

  static Future<pw.MemoryImage?> captureColoredCanvasAsPdfImage(
      String pagePath,
      List<List<DrawingPoint?>> points,
      ) async {
    try {
      debugPrint('=== PDF CAPTURE DEBUG START ===');
      debugPrint('Page Path: $pagePath');
      debugPrint('Total Stroke Sequences: ${points.length}');

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Match the exact same canvas size used by CanvasViewer (800x1000)
      const size = Size(800, 1000);

      // 1. Draw white background
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.white,
      );

      // 2. Draw coloring page image matching BoxFit.fill / BoxFit.fitBounds
      final byteData = await rootBundle.load(pagePath);
      final pageImage = await _loadUiImageFromBytes(byteData.buffer.asUint8List());

      if (pageImage != null) {
        debugPrint('Loaded page asset native size: width=${pageImage.width}, height=${pageImage.height}');
        // Use BoxFit.fill matching the Image.asset widget inside CanvasViewer's SizedBox(width: 800, height: 1000)
        canvas.drawImageRect(
          pageImage,
          Rect.fromLTWH(0, 0, pageImage.width.toDouble(), pageImage.height.toDouble()),
          Rect.fromLTWH(0, 0, size.width, size.height),
          Paint(),
        );
      } else {
        debugPrint('WARNING: pageImage failed to load from bytes!');
      }

      // 3. Play back recorded strokes using the exact same size
      DrawingHelper.paintStrokes(canvas, size, points, pagePath: pagePath);

      final picture = recorder.endRecording();
      final img = await picture.toImage(size.width.toInt(), size.height.toInt());
      final finalByteData = await img.toByteData(format: ui.ImageByteFormat.png);

      if (finalByteData == null) {
        debugPrint('ERROR: finalByteData is null');
        return null;
      }

      debugPrint('=== PDF CAPTURE SUCCESS ===');
      return pw.MemoryImage(finalByteData.buffer.asUint8List());
    } catch (e, stackTrace) {
      debugPrint('Error capturing canvas for PDF: $e');
      debugPrint('$stackTrace');
      return null;
    }
  }

  static Future printColoredArtwork(
      BuildContext context,
      String pagePath,
      List<List<DrawingPoint?>> points,
      ) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preparing your colored masterpiece for printing...')),
    );

    try {
      final coloredImage = await captureColoredCanvasAsPdfImage(pagePath, points);
      final logoProvider = await imageFromAssetBundle('assets/logo/bella_logo.png');

      if (!context.mounted) return;

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                pw.Center(
                  child: coloredImage != null
                      ? pw.Image(coloredImage, fit: pw.BoxFit.fill) // <-- Changed from contain to fill
                      : pw.Container(),
                ),
                pw.Positioned(
                  top: 16,
                  left: 16,
                  child: pw.Image(logoProvider, width: 64, height: 64),
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'Bella_Art_Masterpiece.pdf',
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error printing artwork: $e')),
      );
    }
  }

  static Future downloadArtworkFile(
      BuildContext context,
      String pagePath,
      List<List<DrawingPoint?>> points,
      ) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Downloading your masterpiece PDF...')),
    );

    try {
      final coloredImage = await captureColoredCanvasAsPdfImage(pagePath, points);
      final logoProvider = await imageFromAssetBundle('assets/logo/bella_logo.png');

      if (!context.mounted) return;

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                pw.Center(
                  child: coloredImage != null
                      ? pw.Image(coloredImage, fit: pw.BoxFit.contain)
                      : pw.Container(),
                ),
                pw.Positioned(
                  top: 16,
                  left: 16,
                  child: pw.Image(logoProvider, width: 64, height: 64),
                ),
              ],
            );
          },
        ),
      );

      final bytes = await pdf.save();
      await Printing.sharePdf(bytes: bytes, filename: 'Bella_Art_Masterpiece.pdf');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading file: $e')),
      );
    }
  }

  static Future printBlankPage(
      BuildContext context,
      String pagePath,
      ) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preparing blank page for printing...')),
    );

    try {
      final pageProvider = await imageFromAssetBundle(pagePath);
      final logoProvider = await imageFromAssetBundle('assets/logo/bella_logo.png');

      if (!context.mounted) return;

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                pw.Center(
                  child: pw.Image(pageProvider, fit: pw.BoxFit.contain),
                ),
                pw.Positioned(
                  top: 16,
                  left: 16,
                  child: pw.Image(logoProvider, width: 64, height: 64),
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'Bella_Coloring_Page.pdf',
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error preparing page: $e')),
      );
    }
  }
}