import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../utils/constants.dart';

// ==================== RESPONSIVE HELPER ====================
class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
          MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 2; // Mobile: 2 columns
    if (width < 900) return 3; // Tablet portrait: 3 columns
    if (width < 1200) return 4; // Tablet landscape: 4 columns
    if (width < 1600) return 5; // Desktop: 5 columns
    return 6; // Large desktop: 6 columns
  }

  static double getGridSpacing(BuildContext context) {
    if (isMobile(context)) return 12.0;
    if (isTablet(context)) return 14.0;
    return 16.0;
  }

  static double getGridChildAspectRatio(BuildContext context) {
    if (isMobile(context)) return 0.65;
    if (isTablet(context)) return 0.7;
    return 0.75;
  }

  static EdgeInsets getGridPadding(BuildContext context) {
    if (isMobile(context)) return const EdgeInsets.all(12);
    if (isTablet(context)) return const EdgeInsets.all(16);
    return const EdgeInsets.all(20);
  }

  // Constrain max width for web to prevent stretching on large screens
  static double getMaxContentWidth(BuildContext context) {
    if (!kIsWeb) return double.infinity;
    return MediaQuery.of(context).size.width > 1400 ? 1400 : double.infinity;
  }

  // Get responsive grid delegate
  static SliverGridDelegate getGridDelegate(BuildContext context, {
    int? customColumns,
    double? customSpacing,
    double? customAspectRatio,
  }) {
    final columns = customColumns ?? getGridColumns(context);
    final spacing = customSpacing ?? getGridSpacing(context);
    final aspectRatio = customAspectRatio ?? getGridChildAspectRatio(context);

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      childAspectRatio: aspectRatio,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
    );
  }
}

// ==================== PAGINATED GRIDVIEW ====================
class PaginatedGridView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext, T) itemBuilder;
  final Future<void> Function() onLoadMore;
  final Future<void> Function() onRefresh;
  final bool hasMore;
  final bool isLoadingMore;
  final Widget? emptyWidget;
  final Color? loadingColor;

  // Optional: Override responsive defaults
  final int? customColumns;
  final double? customSpacing;
  final double? customAspectRatio;
  final EdgeInsets? customPadding;

  const PaginatedGridView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.onRefresh,
    required this.hasMore,
    required this.isLoadingMore,
    this.emptyWidget,
    this.loadingColor,
    this.customColumns,
    this.customSpacing,
    this.customAspectRatio,
    this.customPadding,
  });

  @override
  PaginatedGridViewState<T> createState() => PaginatedGridViewState<T>();
}

class PaginatedGridViewState<T> extends State<PaginatedGridView<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!widget.isLoadingMore && widget.hasMore) {
        widget.onLoadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveHelper.getMaxContentWidth(context);
    final gridDelegate = ResponsiveHelper.getGridDelegate(
      context,
      customColumns: widget.customColumns,
      customSpacing: widget.customSpacing,
      customAspectRatio: widget.customAspectRatio,
    );
    final padding = widget.customPadding ?? ResponsiveHelper.getGridPadding(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: RefreshIndicator(
          onRefresh: widget.onRefresh,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Empty state
              if (widget.items.isEmpty && !widget.isLoadingMore)
                SliverToBoxAdapter(
                  child: widget.emptyWidget ?? const SizedBox.shrink(),
                )
              // Grid items
              else
                SliverPadding(
                  padding: padding,
                  sliver: SliverGrid(
                    gridDelegate: gridDelegate,
                    delegate: SliverChildBuilderDelegate(
                          (context, index) => widget.itemBuilder(context, widget.items[index]),
                      childCount: widget.items.length,
                    ),
                  ),
                ),

              // Loading indicator
              if (widget.isLoadingMore)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: widget.loadingColor ?? Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),

              // End of list message
              if (!widget.hasMore && widget.items.isNotEmpty)
                 SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text('No more items to load',style: bodyStyleStyleB3SemiBold.copyWith(color: kPrimaryColor),),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}