import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/generated/app_localizations.dart';

import '../application/parse_notifier.dart';
import '../domain/models/bvid_info.dart';
import 'widgets/search_result_list.dart';
import 'widgets/video_detail_view.dart';

/// Main search screen with unified input for BV number parsing and keyword search.
///
/// Flow:
/// 1. User enters a BV number/URL → parses the video directly
/// 2. User enters a keyword → searches Bilibili and shows results
/// 3. Tapping a search result → parses that video
/// 4. Parsed video detail shows info, page selection, and "Add to Playlist"
/// 5. Playlist picker lets user choose target playlist
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  List<BvidInfo> _searchResults = [];
  bool _isSearching = false;
  int _currentPage = 1;
  int _totalPages = 1;
  String _currentKeyword = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final bvid = Formatters.parseBvid(text);
    if (bvid != null) {
      setState(() => _searchResults = []);
      ref.read(parseNotifierProvider.notifier).parseInput(text);
    } else {
      _currentKeyword = text;
      _performSearch(text, page: 1);
    }
  }

  Future<void> _performSearch(String keyword, {int page = 1}) async {
    ref.read(parseNotifierProvider.notifier).reset();
    setState(() {
      _isSearching = true;
      _currentPage = page;
    });
    final searchResult = await ref
        .read(parseNotifierProvider.notifier)
        .searchVideos(keyword, page: page);
    setState(() {
      _searchResults = searchResult.results;
      _totalPages = searchResult.numPages;
      _isSearching = false;
    });
  }

  void _goToPage(int page) {
    if (_currentKeyword.isNotEmpty && page >= 1 && page <= _totalPages) {
      _performSearch(_currentKeyword, page: page);
    }
  }

  void _onVideoTap(BvidInfo video) {
    ref.read(parseNotifierProvider.notifier).parseInput(video.bvid);
  }

  void _backToResults() {
    ref.read(parseNotifierProvider.notifier).reset();
  }

  Future<void> _onPaste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      _controller.text = data.text!;
      _handleSubmit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final parseState = ref.watch(parseNotifierProvider);
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    final showVideoDetail = parseState.whenOrNull(
      success: (info) => info,
      selectingPages: (info, _) => info,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.search), centerTitle: false),
      body: Column(
        children: [
          // ── Input bar ──
          _buildInputBar(l10n, parseState),

          // ── Error banner ──
          parseState.whenOrNull(
                error: (msg) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: colorScheme.errorContainer,
                  child: Text(msg,
                      style:
                          TextStyle(color: colorScheme.onErrorContainer)),
                ),
              ) ??
              const SizedBox.shrink(),

          // ── Content area ──
          if (parseState.whenOrNull(parsing: () => true) == true)
            const Expanded(
                child: Center(child: CircularProgressIndicator()))
          else if (showVideoDetail != null)
            Expanded(
              child: VideoDetailView(
                parseState: parseState,
                showBackButton: _searchResults.isNotEmpty,
                onBack: _backToResults,
              ),
            )
          else if (_isSearching)
            const Expanded(
                child: Center(child: CircularProgressIndicator()))
          else if (_searchResults.isNotEmpty)
            Expanded(
              child: SearchResultList(
                results: _searchResults,
                currentPage: _currentPage,
                totalPages: _totalPages,
                onVideoTap: _onVideoTap,
                onPageChanged: _goToPage,
              ),
            )
          else
            Expanded(child: _buildEmptyState(l10n, colorScheme)),
        ],
      ),
    );
  }

  // ── Input bar ───────────────────────────────────────────────────────

  Widget _buildInputBar(AppLocalizations l10n, ParseState parseState) {
    final isParsing =
        parseState.whenOrNull(parsing: () => true) == true;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: l10n.parseInput,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.content_paste),
                  tooltip: '粘贴',
                  onPressed: _onPaste,
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
              onSubmitted: (_) => _handleSubmit(),
              enabled: !isParsing,
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: isParsing ? null : _handleSubmit,
            icon: isParsing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.search),
            label: Text(isParsing ? l10n.parsing : l10n.search),
          ),
        ],
      ),
    );
  }

  // ── Empty state ─────────────────────────────────────────────────────

  Widget _buildEmptyState(AppLocalizations l10n, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, size: 64, color: colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text(l10n.parseInput,
              style: TextStyle(color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text('搜索关键词或输入BV号',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

