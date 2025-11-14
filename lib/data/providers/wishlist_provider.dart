import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thenexstore/data/providers/product_provider.dart';
import 'package:thenexstore/data/providers/search_provider.dart';
import 'package:thenexstore/data/repository/wishlist_repository.dart';
import 'package:thenexstore/utils/snack_bar.dart';
import '../models/common_response.dart';
import '../models/wishlist_model.dart';
import 'api_state_provider.dart';
import 'home_provider.dart';

class WishListProvider with ChangeNotifier {
  final WishListRepository _repository = WishListRepository();
  final ApiStateProvider<WishlistResponse> wishState = ApiStateProvider<WishlistResponse>();
  final ApiStateProvider<CommonResponse> deleteState = ApiStateProvider<CommonResponse>();
  final ApiStateProvider<CommonResponse> addState = ApiStateProvider<CommonResponse>();

  final Map<int, bool> _loadingStates = {};
  bool isProductLoading(int productId) => _loadingStates[productId] ?? false;

  Future<void> fetchWishlistData({bool forceRefresh = false}) async {
    try {
      if(forceRefresh) {
        await clearCache();
      }

      await _repository.getWishlist(
        stateProvider: wishState,
        forceRefresh: forceRefresh,
      );
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

// Modify the addToWishlist and removeFromWishlist methods in WishListProvider

  Future<void> removeFromWishlist(int productId, context) async {
    if (isProductLoading(productId)) return;

    try {
      _loadingStates[productId] = true;
      notifyListeners();

      // Track the wishlist change in ProductsDataProvider
      try {
        final productsProvider = Provider.of<ProductsDataProvider>(context, listen: false);
        productsProvider.setLastToggledWishlist(productId, false);
      } catch (e) {
        debugPrint('Could not set last toggled wishlist: $e');
      }

      await _repository.removeFromWishlist(
        productId: productId,
        stateProvider: deleteState,
      );

      // Check delete state
      deleteState.state.maybeWhen(
        success: (_) async {
          SnackBarUtils.showSuccess("Product Successfully removed from Wishlist");
          _updateProvidersWishlistState(context, productId, false);
          await fetchWishlistData(forceRefresh: true);
        },
        failure: (error){
          SnackBarUtils.showSuccess(error.message);
        },
        orElse: () {},
      );

    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _loadingStates[productId] = false;
      notifyListeners();

      // Reset tracking after operation is complete
      try {
        final productsProvider = Provider.of<ProductsDataProvider>(context, listen: false);
        productsProvider.resetLastToggledWishlist();
      } catch (e) {
        // Ignore if not available
      }
    }
  }

  Future<void> addToWishlist(int productId, context) async {
    if (isProductLoading(productId)) return;

    try {
      _loadingStates[productId] = true;
      notifyListeners();

      // Track the wishlist change in ProductsDataProvider
      try {
        final productsProvider = Provider.of<ProductsDataProvider>(context, listen: false);
        productsProvider.setLastToggledWishlist(productId, true);
      } catch (e) {
        debugPrint('Could not set last toggled wishlist: $e');
      }

      await _repository.addToWishlist(
        productId: productId,
        stateProvider: addState,
      );

      addState.state.maybeWhen(
        success: (_) async {
          SnackBarUtils.showSuccess("Product Successfully added to Wishlist");
          _updateProvidersWishlistState(context, productId, true);
          await fetchWishlistData(forceRefresh: true);
        },
        failure: (error){
          SnackBarUtils.showSuccess(error.message);
        },
        orElse: () {},
      );

    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _loadingStates[productId] = false;
      notifyListeners();

      // Reset tracking after operation is complete
      try {
        final productsProvider = Provider.of<ProductsDataProvider>(context, listen: false);
        productsProvider.resetLastToggledWishlist();
      } catch (e) {
        // Ignore if not available
      }
    }
  }
  void _updateProvidersWishlistState(BuildContext context, int productId, bool isWishListed) {
    try {
      final homeProvider = Provider.of<HomeDataProvider>(context, listen: false);
      homeProvider.updateProductWishlistState(productId, isWishListed);
    } catch (e) {
      debugPrint('HomeProvider not found or error updating: $e');
    }

    try {
      final productsProvider = Provider.of<ProductsDataProvider>(context, listen: false);
      productsProvider.updateProductWishlistState(productId, isWishListed);
      productsProvider.updateHotPickWishlistState(productId, isWishListed);
    } catch (e) {
      debugPrint('ProductsProvider not found or error updating: $e');
    }

    try {
      final searchProvider = Provider.of<SearchDataProvider>(context, listen: false);
      searchProvider.updateProductWishlistState(productId, isWishListed);
    } catch (e) {
      debugPrint('SearchProvider not found or error updating: $e');
    }

    Future.microtask(() {
      notifyListeners();
    });
  }



  Future<void> clearCache() async {
    await _repository.clearWishlistCache();
    notifyListeners();
  }
}