import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/models/bvid_info.dart';

/// Search result list with pagination controls.
class SearchResultList extends StatelessWidget {
  final List<BvidInfo> results;
  final int currentPage;
  final int totalPages;
  final ValueChanged<BvidInfo> onVideoTap;
  final ValueChanged<int> onPageChanged;

  const SearchResultList({
    super.key,
    required this.results,
    required this.currentPage,
    required this.totalPages,
    required this.onVideoTap,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            key: PageStorageKey<String>('search_results_page_$currentPage'),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final video = results[index];
              return ListTile(
                leading: video.coverUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          video.coverUrl!,
                          width: 80,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 50,
                            color: colorScheme.surfaceContainerHighest,
                            child: const Icon(Icons.video_library),
                          ),
                        ),
                      )
                    : null,
                title: Text(video.title,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  '${video.owner} · ${Formatters.formatDuration(Duration(seconds: video.duration))}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => onVideoTap(video),
              );
            },
          ),
        ),
        _buildPaginationBar(colorScheme),
      ],
    );
  }

  // ── Pagination bar ──────────────────────────────────────────────────

  Widget _buildPaginationBar(ColorScheme colorScheme) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              iconSize: 20,
              visualDensity: VisualDensity.compact,
              onPressed: currentPage > 1
                  ? () => onPageChanged(currentPage - 1)
                  : null,
              tooltip: '上一页',
            ),
            const SizedBox(width: 4),
            ..._buildPageNumbers(colorScheme),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              iconSize: 20,
              visualDensity: VisualDensity.compact,
              onPressed: currentPage < totalPages
                  ? () => onPageChanged(currentPage + 1)
                  : null,
              tooltip: '下一页',
            ),
            const SizedBox(width: 8),
            _buildJumpToPage(colorScheme),
          ],
        ),
      ),
    );
  }

  /// Build page number buttons with ellipsis, Google/browser style:
  /// [1] ... [4] [5] [*6*] [7] [8] ... [50]
  List<Widget> _buildPageNumbers(ColorScheme colorScheme) {
    final pages = <Widget>[];
    const int siblings = 2;

    final int rangeStart = (currentPage - siblings).clamp(1, totalPages);
    final int rangeEnd = (currentPage + siblings).clamp(1, totalPages);

    if (rangeStart > 1) {
      pages.add(_buildPageButton(1, colorScheme));
      if (rangeStart > 2) {
        pages.add(_buildEllipsis(colorScheme));
      }
    }

    for (int i = rangeStart; i <= rangeEnd; i++) {
      pages.add(_buildPageButton(i, colorScheme));
    }

    if (rangeEnd < totalPages) {
      if (rangeEnd < totalPages - 1) {
        pages.add(_buildEllipsis(colorScheme));
      }
      pages.add(_buildPageButton(totalPages, colorScheme));
    }

    return pages;
  }

  Widget _buildEllipsis(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
        width: 32,
        height: 32,
        child: Center(
          child: Text(
            '…',
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJumpToPage(ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 48,
          height: 32,
          child: Center(
            child: TextField(
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: colorScheme.onSurface, height: 1.0),
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                isDense: true,
                hintText: '$currentPage',
                hintStyle: TextStyle(
                    fontSize: 13, color: colorScheme.onSurfaceVariant),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onSubmitted: (value) {
                final page = int.tryParse(value);
                if (page != null && page >= 1 && page <= totalPages) {
                  onPageChanged(page);
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '/ $totalPages',
          style: TextStyle(
            fontSize: 13,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildPageButton(int page, ColorScheme colorScheme) {
    final isActive = page == currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
        width: 32,
        height: 32,
        child: Material(
          color: isActive ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: isActive ? null : () => onPageChanged(page),
            child: Center(
              child: Text(
                '$page',
                style: TextStyle(
                  fontSize: 13,
                  color: isActive
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
