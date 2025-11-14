import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/screens/components/app_bar_common.dart';
import 'package:thenexstore/utils/size_config.dart';
import '../../data/models/home_model.dart';
import '../../data/providers/cart_provider.dart';
import '../../data/providers/product_provider.dart';
import '../../data/providers/wishlist_provider.dart';
import '../../data/providers/home_provider.dart';
import '../../utils/assets.dart';
import '../../utils/constants.dart';
import '../../utils/snack_bar.dart';
import '../../routes/navigator_services.dart';
import '../../routes/routes_names.dart';
import '../cart/components/cart_summary_card.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final PageController _pageController;
  late List<String> _images;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeImages();
    _setupPostFrame();
  }

  void _initializeImages() {
    _images = [widget.product.featuredImage];
    if (widget.product.productImages != null) {
      _images.addAll(widget.product.productImages!);
    }
  }

  void _setupPostFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsDataProvider>().resetImageIndex();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }


  Future<void> _handleWishlistToggle(
      Product product, WishListProvider wishlistProvider) async {
    if (product.inWishlist) {
      await wishlistProvider.removeFromWishlist(product.id, context);
    } else {
      await wishlistProvider.addToWishlist(product.id, context);
    }
  }

  Widget _buildProductImage(Product currentProduct) {
    return Container(
      height: getProportionateScreenHeight(280),
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,

      child: Consumer<ProductsDataProvider>(
        builder: (context, productsProvider, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: productsProvider.updateCurrentImageIndex,
                itemCount: _images.length,
                itemBuilder: (context, index) =>
                    _buildImageItem(_images[index], currentProduct),
              ),
              if (_images.length > 1)
                _buildPageIndicator(productsProvider.currentImageIndex),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageItem(String imageUrl, Product product) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CachedNetworkImage(
          imageUrl: imageUrl,
          height: getProportionateScreenHeight(300),
          width: getProportionateScreenWidth(300),
          fit: BoxFit.contain,
          errorWidget: (context, url, error) => Icon(
            Icons.broken_image,
            size: getProportionateScreenHeight(150),
            color: kGreyColorLightMed,
          ),
        ),
        if (product.totalStock <= 0) ...[
          Container(
            height: getProportionateScreenHeight(300),
            width: getProportionateScreenWidth(300),
            color: Colors.black.withOpacity(0.3),
          ),
          Positioned(
            top: getProportionateScreenHeight(135),
            left: 0,
            right: 0,
            child: Container(
              color: kWhiteColor.withOpacity(0.8),
              padding: EdgeInsets.symmetric(
                vertical: getProportionateScreenHeight(8),
              ),
              child: Center(
                child: Text(
                  'Out Of Stock',
                  style: bodyStyleStyleB2.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPageIndicator(int currentIndex) {
    return Positioned(
      bottom: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _images.length,
              (index) => Container(
            width: currentIndex == index
                ? getProportionateScreenWidth(20)
                : getProportionateScreenWidth(6),
            height: currentIndex == index
                ? getProportionateScreenHeight(4)
                : getProportionateScreenHeight(6),
            margin: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(2),
            ),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              shape: BoxShape.rectangle,
              color: currentIndex == index ? kPrimaryColor : Colors.grey[300],
            ),
          ),
        ),
      ),
    );
  }

  // NEW: Product Info Widget similar to Cart Item Widget
  Widget _buildProductInfoCard(Product product) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        final quantityNotifier =
        cartProvider.getQuantityNotifier(product.id, product.inCart);

        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(16),
            vertical: getProportionateScreenWidth(8),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(16),
            vertical: getProportionateScreenWidth(12),
          ),
          decoration: BoxDecoration(
            color: kWhiteColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // Product Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: bodyStyleStyleB1Bold.copyWith(
                        color: kPrimaryColor,
                        fontSize: getProportionateScreenHeight(18),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: getProportionateScreenWidth(3)),

                    // Weight
                    Text(
                      product.weight,
                      style: bodyStyleStyleB3SemiBold.copyWith(
                        color: Colors.grey[600],
                        fontSize: getProportionateScreenFont(14),
                      ),
                    ),
                    SizedBox(height: getProportionateScreenWidth(8)),

                    // Price and Quantity Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price
                        Row(
                          children: [
                            Text(
                              '₹${product.sellingPrice}',
                              style: bodyStyleStyleB1Bold.copyWith(
                                color: kAccentTextAccentOrange,
                                fontSize: getProportionateScreenFont(25),
                              ),
                            ),
                            if (product.discount > 0) ...[
                              const SizedBox(width: 4),
                              Text(
                                '₹${product.price.toInt()}',
                                style: bodyStyleStyleB3Medium.copyWith(
                                  color: Colors.grey[500],
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: getProportionateScreenFont(16),
                                ),
                              ),
                            ]
                          ],
                        ),

                        // Quantity Controls
                        ValueListenableBuilder<int>(
                          valueListenable: quantityNotifier,
                          builder: (context, quantity, _) {
                            if (quantity > 0) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: getProportionateScreenWidth(4),
                                  vertical: getProportionateScreenWidth(4),
                                ),
                                decoration: BoxDecoration(
                                  color: kAppBarColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    // Minus Button
                                    InkWell(
                                      onTap: cartProvider.isProductLoading(product.id)
                                          ? null
                                          : () async {
                                        if (quantity > 1) {
                                          await cartProvider.updateToCart(
                                              product.id, quantity - 1);
                                          if (context.mounted) {
                                            cartProvider.updateState.state.maybeWhen(
                                              success: (response) {
                                                SnackBarUtils.showSuccess(
                                                    response.message);
                                              },
                                              failure: (error) {
                                                SnackBarUtils.showError(
                                                    error.message);
                                              },
                                              orElse: () {},
                                            );
                                          }
                                        } else {
                                          await cartProvider.removeFromCart(product.id);
                                          if (context.mounted) {
                                            cartProvider.deleteState.state.maybeWhen(
                                              success: (response) {
                                                SnackBarUtils.showSuccess(
                                                    response.message);
                                              },
                                              failure: (error) {
                                                SnackBarUtils.showError(
                                                    error.message);
                                              },
                                              orElse: () {},
                                            );
                                          }
                                        }
                                      },
                                      child: Container(
                                        width: getProportionateScreenWidth(36),
                                        height: getProportionateScreenWidth(36),
                                        decoration: const BoxDecoration(
                                          color: kWhiteColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.remove,
                                          size: getProportionateScreenFont(20),
                                          color: kBlackColor,
                                        ),
                                      ),
                                    ),

                                    // Quantity
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: getProportionateScreenWidth(12),
                                      ),
                                      child: Text(
                                        quantity.toString(),
                                        style: TextStyle(
                                          fontSize: getProportionateScreenFont(14),
                                          fontWeight: FontWeight.w600,
                                          color: kBlackColor,
                                        ),
                                      ),
                                    ),

                                    // Plus Button
                                    InkWell(
                                      onTap: cartProvider.isProductLoading(product.id) ||
                                          product.totalStock <= 0
                                          ? null
                                          : () async {
                                        if (quantity < product.maximumOrderQuantity) {
                                          await cartProvider.updateToCart(
                                              product.id, quantity + 1);
                                          if (context.mounted) {
                                            cartProvider.updateState.state.maybeWhen(
                                              success: (response) {
                                                SnackBarUtils.showSuccess(
                                                    response.message);
                                              },
                                              failure: (error) {
                                                SnackBarUtils.showError(
                                                    error.message);
                                              },
                                              orElse: () {},
                                            );
                                          }
                                        } else {
                                          SnackBarUtils.showInfo(
                                              'Maximum order quantity reached');
                                        }
                                      },
                                      child: Container(
                                        width: getProportionateScreenWidth(36),
                                        height: getProportionateScreenWidth(36),
                                        decoration: const BoxDecoration(
                                          color: kPrimaryColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          size: getProportionateScreenFont(20),
                                          color: kWhiteColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              // Add to Cart Button
                              return GestureDetector(
                                onTap: cartProvider.isProductLoading(product.id) ||
                                    product.totalStock <= 0
                                    ? null
                                    : () async {
                                  await cartProvider.addToCart(product.id, 1);
                                  if (context.mounted) {
                                    cartProvider.addState.state.maybeWhen(
                                      success: (response) {
                                        SnackBarUtils.showSuccess(response.message);
                                      },
                                      failure: (error) {
                                        SnackBarUtils.showError(error.message);
                                      },
                                      orElse: () {},
                                    );
                                  }
                                },
                                child: Container(
                                  width: getProportionateScreenWidth(36),
                                  height: getProportionateScreenWidth(36),
                                  decoration: const BoxDecoration(
                                    color: kPrimaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    size: getProportionateScreenFont(20),
                                    color: kWhiteColor,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDescription(String? description) {
    if (description == null || description.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.all(getProportionateScreenWidth(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Description', style: bodyStyleStyleB0.copyWith(color: kPrimaryColor,fontSize: getProportionateScreenHeight(24))),
                Html(
                  data: description,
                  style: {
                    "body": Style(
                      fontSize: FontSize(getProportionateScreenWidth(15)),
                      color: kDescription,
                      fontFamily: 'manrope',
                    ),
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarProduct() {

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(16),vertical: getProportionateScreenHeight(0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Similar Products', style: bodyStyleStyleB0.copyWith(color: kPrimaryColor,fontSize: getProportionateScreenHeight(24))),

              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: kGreyColorLight,
      statusBarIconBrightness: Brightness.light,
    ));

    return Consumer2<ProductsDataProvider, WishListProvider>(
      builder: (context, productsProvider, wishlistProvider, _) {
        Product getCurrentProduct() {
          try {
            final product = productsProvider.products
                .firstWhere((p) => p.id == widget.product.id);
            return product;
          } catch (_) {}

          if (productsProvider.hotPickState.data != null) {
            try {
              final product = productsProvider.hotPickState.data!.data
                  .firstWhere((p) => p.id == widget.product.id);
              return product;
            } catch (_) {}
          }

          if (wishlistProvider.wishState.data != null) {
            try {
              final product = wishlistProvider.wishState.data!.data
                  .firstWhere((p) => p.id == widget.product.id);
              return product;
            } catch (_) {}
          }

          try {
            final homeProvider =
            Provider.of<HomeDataProvider>(context, listen: false);
            if (homeProvider.homeState.data != null) {
              final product = homeProvider.homeState.data!.data.topProducts
                  .firstWhere((p) => p.id == widget.product.id);
              return product;
            }
          } catch (_) {}

          return widget.product;
        }

        final currentProduct = getCurrentProduct();

        return Scaffold(
          backgroundColor: kAppBarColor,
          appBar: const AppBarCommon(
            title: "Product Details",
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Column(
                      children: [
                        _buildProductImage(currentProduct),
                        SizedBox(height: getProportionateScreenHeight(20)),
                      ],
                    ),
                  ],
                ),
                // REPLACED: Product Info Card (similar to Cart Item Widget)
                _buildProductInfoCard(currentProduct),

                _buildDescription(currentProduct.description),
                _buildSimilarProduct(),
              ],
            ),
          ),
          bottomNavigationBar: const CartSummaryCard(),
        );
      },
    );
  }
}