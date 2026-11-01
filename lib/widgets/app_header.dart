import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onDownloadArt;
  final VoidCallback onDownloadPrintablePage;

  const AppHeader({
    super.key,
    required this.onDownloadArt,
    required this.onDownloadPrintablePage,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.green.shade600,
      elevation: 2,
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              'assets/logo/paw_heart.png',
              width: 36,
              height: 36,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.pets, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(width: 12),
          // Updated Title
          const Text(
            'Bella Art Studio',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      actions: [
        // Download Button with a Popup Menu for Art vs Printable Page
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'art') {
                onDownloadArt();
              } else if (value == 'printable') {
                onDownloadPrintablePage();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'art',
                child: Row(
                  children: [
                    Icon(Icons.image, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Download My Artwork'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'printable',
                child: Row(
                  children: [
                    Icon(Icons.print, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Print Blank Page'),
                  ],
                ),
              ),
            ],
            child: ElevatedButton.icon(
              onPressed: null, // Let PopupMenuButton handle tap handling via wrapper
              icon: const Icon(Icons.download, color: Colors.white),
              label: const Text('Download', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                disabledBackgroundColor: Colors.green.shade700,
                elevation: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}