import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/screens/components/app_bar_common.dart';
import 'package:thenexstore/utils/size_config.dart';
import '../../data/models/home_model.dart';
import '../../data/models/product_model.dart';
import '../../data/providers/product_provider.dart';
import '../../utils/constants.dart';
import '../../routes/navigator_services.dart';
import '../../routes/routes_names.dart';
import '../../utils/assets.dart';
import '../common/error_screen_new.dart';
import '../common/empty_data_screen.dart';
import '../components/common_app_bar.dart';
import '../components/language_bottom_sheet.dart';
import '../components/custom_pagination_gridview.dart';
import '../components/product_list_loader.dart';
import 'components/filter_bottom_sheet.dart';
import '../home/components/product_card.dart';

class ProductsScreen extends StatefulWidget {
  final int categoryId;
  final String categoryTitle;

  const ProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  State<ProductsScreen> createState() => _ProductsListingScreenState();
}

class _ProductsListingScreenState extends State<ProductsScreen> with SingleTickerProviderStateMixin {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeScreen();
      }
    });
  }

  Future<void> _initializeScreen() async {
    if (!mounted || _isInitialized) return;

    final provider = context.read<ProductsDataProvider>();
    if (provider.selectedCategoryId != widget.categoryId) {
      await provider.clearAllCache();
      await provider.initialize(widget.categoryId);
    }
    _isInitialized = true;
  }

  Future<void> _refreshProducts() async {
    if (!mounted) return;
    final provider = context.read<ProductsDataProvider>();
    await provider.clearAllCache();
    await provider.refreshProducts();
  }

  void _showLanguageBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const LanguageBottomSheet(),
    );
  }

  Widget _buildFilterTabs(BuildContext context, List<Types> types) {
    final provider = context.watch<ProductsDataProvider>();

    return Container(
      decoration: const BoxDecoration(
        color: kAppBarColor,

      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: getProportionateScreenHeight(40),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: types.length + 2,
              itemBuilder: (context, index) {
                // Filter button as the first item
                if (index == 0) {
                  return Padding(
                    padding: EdgeInsets.only(right: getProportionateScreenWidth(10)),
                    child: InkWell(
                      onTap: () => showFilterBottomSheet(context, widget.categoryId),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: kWhiteColor,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.filter_list, size: 18, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text('Filters', style: bodyStyleStyleB3Medium),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                // "All" tab as the second item
                if (index == 1) {
                  return Padding(
                    padding: EdgeInsets.only(right: getProportionateScreenWidth(10)),
                    child: InkWell(
                      onTap: () {
                        provider.updateTypeFilter(null);
                        provider.updateBrandFilter(null);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: provider.selectedType == null ? kPrimaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                              "All",
                              style: bodyStyleStyleB3Medium.copyWith(
                                  color: provider.selectedType == null ? Colors.white : kBlackColor)),
                        ),
                      ),
                    ),
                  );
                }

                final type = types[index - 2];
                return Padding(
                  padding: EdgeInsets.only(right: getProportionateScreenWidth(10)),
                  child: InkWell(
                    onTap: () => provider.updateTypeFilter(type.id.toString()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: provider.selectedType == type.id.toString() ? kPrimaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(type.name,
                            style: bodyStyleStyleB3Medium.copyWith(
                                color: provider.selectedType == type.id.toString() ? kWhiteColor : kBlackColor)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 4), // Add a small gap at the bottom of the shadow
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBarColor,

      appBar: AppBarCommon(title: widget.categoryTitle,cart: true,elevation: 0,),

      body: SafeArea(
        child: Consumer<ProductsDataProvider>(
          builder: (context, provider, child) {
            return provider.productsState.state.when(
              initial: () => const ProductLoader(),
              loading: () => const ProductLoader(),
              success: (productData) {
                return Column(
                  children: [
                    _buildFilterTabs(context, productData.data.types),
                    SizedBox(height: getProportionateScreenHeight(10)),
                    Expanded(
                      child: PaginatedGridView<Product>(
                        items: provider.products,
                        itemBuilder: (context, product) => ProductCard(product: product),
                        onLoadMore: () => provider.loadMoreProducts(),
                        onRefresh: _refreshProducts,
                        hasMore: provider.hasMorePages,
                        isLoadingMore: provider.isLoadingMore,

                        emptyWidget: const NoDataScreen(
                          title: "No Products",
                          subTitle: "No products found in this category",
                          icon: emptyError,
                        ),
                      ),
                    ),
                  ],
                );
              },
              failure: (error) => ErrorScreenNew(
                error: error,
                onRetry: _refreshProducts,
              ),
            );
          },
        ),
      ),
    );
  }
}