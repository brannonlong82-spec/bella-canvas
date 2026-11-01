import 'package:flutter/material.dart';
import '../data/coloring_pages.dart';

class ThumbnailSidebar extends StatelessWidget {
  final List<ColoringPageItem> pages;
  final String selectedPagePath;
  final ValueChanged<String> onPageSelected;
  final bool isExpanded;
  final VoidCallback onToggleExpand;

  const ThumbnailSidebar({
    super.key,
    required this.pages,
    required this.selectedPagePath,
    required this.onPageSelected,
    required this.isExpanded,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isExpanded ? 130 : 45,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header / Toggle Collapse Button
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isExpanded)
                  const Expanded(
                    child: Text(
                      'Pages',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ),
                IconButton(
                  icon: Icon(isExpanded ? Icons.chevron_right : Icons.chevron_left, size: 20),
                  onPressed: onToggleExpand,
                  tooltip: isExpanded ? 'Collapse Pages' : 'Expand Pages',
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Expanded or Minimized Thumbnail List
          if (isExpanded)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  final page = pages[index];
                  final isSelected = selectedPagePath == page.path;
                  return GestureDetector(
                    onTap: () => onPageSelected(page.path),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Colors.green.shade700 : Colors.transparent,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              height: 60,
                              color: Colors.white,
                              child: Image.asset(
                                page.path,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image, color: Colors.grey, size: 24),
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            page.title,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.green.shade800 : Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  final page = pages[index];
                  final isSelected = selectedPagePath == page.path;
                  return GestureDetector(
                    onTap: () => onPageSelected(page.path),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Colors.green.shade700 : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          height: 32,
                          color: Colors.white,
                          child: Image.asset(
                            page.path,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image, color: Colors.grey, size: 16),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}