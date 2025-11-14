import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../models/common_response.dart';
import '../models/home_model.dart';
import '../repository/cart_repository.dart';
import 'api_state_provider.dart';

class CartProvider with ChangeNotifier {
  final CartRepository _repository = CartRepository();
  final ApiStateProvider<CartResponse> cartState = ApiStateProvider<CartResponse>();
  final ApiStateProvider<CommonResponse> deleteState = ApiStateProvider<CommonResponse>();
  final ApiStateProvider<CommonResponse> addState = ApiStateProvider<CommonResponse>();
  final ApiStateProvider<CommonResponse> updateState = ApiStateProvider<CommonResponse>();

  final Map<int, int> _cartQuantities = {};
  final Map<int, bool> _loadingProducts = {};
  final Map<int, ValueNotifier<int>> _quantityNotifiers = {};

  // Out of stock indicator
  final ValueNotifier<bool> _hasOutOfStockItems = ValueNotifier<bool>(false);
  ValueNotifier<bool> get hasOutOfStockItems => _hasOutOfStockItems;

  int getProductQuantity(int productId) {
    return _cartQuantities[productId] ?? 0;
  }

  void updateProductInCart(Product product) {
    product.inCart = getProductQuantity(product.id);
  }

  ValueNotifier<int> getQuantityNotifier(int productId, int inCart) {
    if (!_quantityNotifiers.containsKey(productId)) {
      final currentQty = getProductQuantity(productId);
      _quantityNotifiers[productId] = ValueNotifier<int>(currentQty > 0 ? currentQty : inCart);
    }
    return _quantityNotifiers[productId]!;
  }

  // Check if cart has any out of stock items
  void _checkOutOfStockItems(CartResponse response) {
    bool hasOutOfStock = false;
    for (var item in response.data.cartItems) {
      final stock = item.productStock is int ? item.productStock as int : int.tryParse(item.productStock.toString()) ?? 0;
      final quantity = item.quantity is int ? item.quantity as int : int.tryParse(item.quantity.toString()) ?? 0;

      if (stock < quantity) {
        hasOutOfStock = true;
        break;
      }
    }
    _hasOutOfStockItems.value = hasOutOfStock;
  }

  Future<void> fetchCartData({bool forceRefresh = false,
    int? couponId ,
    int? addressId,}) async {
    try {
      if (forceRefresh) {
        await clearCache();
        cartState.setLoading();
        notifyListeners();
      }

      await _repository.getCartList(
          stateProvider: cartState,
          forceRefresh: forceRefresh,
          couponId: couponId,
          addressId: addressId
      );

      cartState.state.maybeWhen(
        success: (response) {
          _cartQuantities.clear();
          for (var item in response.data.cartItems) {
            _cartQuantities[item.productId] = item.quantity;
          }
          _quantityNotifiers.forEach((productId, notifier) {
            notifier.value = getProductQuantity(productId);
          });
          // Check for out of stock items
          _checkOutOfStockItems(response);
        },
        orElse: () {},
      );
    } catch (e) {
      debugPrint('Error fetching cart data: $e');
    } finally {
      notifyListeners();
    }
  }

  bool isProductLoading(int productId) => _loadingProducts[productId] ?? false;

  void _updateQuantity(int productId, int quantity) {
    final notifier = _quantityNotifiers[productId];
    if (notifier != null) {
      notifier.value = quantity;
    }
  }

  void _setProductLoading(int productId, bool loading) {
    _loadingProducts[productId] = loading;
    notifyListeners();
  }

  Future<void> addToCart(int productId, int quantity) async {
    if (isProductLoading(productId)) return;

    try {
      _setProductLoading(productId, true);
      _cartQuantities[productId] = quantity;
      _updateQuantity(productId, quantity);

      await _repository.addToCart(
        productId: productId,
        quantity: quantity,
        stateProvider: addState,
      );

      addState.state.maybeWhen(
        success: (_) async {
          await fetchCartData(forceRefresh: false);
        },
        failure: (error) async {
          _cartQuantities.remove(productId);
          _updateQuantity(productId, 0);
          await fetchCartData(forceRefresh: false);
          debugPrint('Failed to add to cart: ${error.message}');
        },
        orElse: () {},
      );
    } catch (e) {
      _cartQuantities.remove(productId);
      _updateQuantity(productId, 0);
    } finally {
      _setProductLoading(productId, false);
    }
  }

  // Update cart item quantity
  Future<void> updateToCart(int productId, int quantity) async {
    if (isProductLoading(productId)) return;

    final originalQuantity = _cartQuantities[productId] ?? 0;

    try {
      _setProductLoading(productId, true);

      // Optimistic update
      _cartQuantities[productId] = quantity;
      _updateQuantity(productId, quantity);

      await _repository.updateToCart(
        productId: productId,
        quantity: quantity,
        stateProvider: updateState,
      );

      updateState.state.maybeWhen(
        success: (_) async {
          await fetchCartData(forceRefresh: false);
        },
        failure: (error) {
          // Revert on failure
          _cartQuantities[productId] = originalQuantity;
          _updateQuantity(productId, originalQuantity);
          debugPrint('Failed to update cart: ${error.message}');
        },
        orElse: () {},
      );
    } catch (e) {
      // Revert on error
      _cartQuantities[productId] = originalQuantity;
      _updateQuantity(productId, originalQuantity);
      debugPrint('Error updating cart: $e');
    } finally {
      _setProductLoading(productId, false);
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(int productId) async {
    if (isProductLoading(productId)) return;

    final originalQuantity = _cartQuantities[productId] ?? 0;

    try {
      _setProductLoading(productId, true);
      _cartQuantities.remove(productId);
      _updateQuantity(productId, 0);

      await _repository.removeFromCart(
        productId: productId,
        stateProvider: deleteState,
      );

      deleteState.state.maybeWhen(
        success: (_) async {
          await fetchCartData(forceRefresh: false);
        },
        failure: (error) {
          _cartQuantities[productId] = originalQuantity;
          _updateQuantity(productId, originalQuantity);
          debugPrint('Failed to remove from cart: ${error.message}');
        },
        orElse: () {},
      );
    } catch (e) {
      // Revert on error
      _cartQuantities[productId] = originalQuantity;
      _updateQuantity(productId, originalQuantity);
      debugPrint('Error removing from cart: $e');
    } finally {
      _setProductLoading(productId, false);
    }
  }

  // Clear cart cache
  Future<void> clearCache() async {
    try {
      await _repository.clearCartCache();
    } catch (e) {
      debugPrint('Clear cache error: $e');
    }
  }

  @override
  void dispose() {
    for (var notifier in _quantityNotifiers.values) {
      notifier.dispose();
    }
    _quantityNotifiers.clear();
    _loadingProducts.clear();
    _hasOutOfStockItems.dispose();
    super.dispose();
  }
}