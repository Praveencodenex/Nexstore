import 'package:flutter/foundation.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import '../services/shared_pref_service.dart';
import '../models/home_model.dart';
import '../models/hot_pick_model.dart';
import '../models/product_model.dart';
import '../models/filter_model.dart';
import '../repository/product_repository.dart';
import 'api_state_provider.dart';

class ProductsDataProvider extends ChangeNotifier {
  final ProductRepository _repository = ProductRepository();
  final ApiStateProvider<ProductResponse> productsState = ApiStateProvider<ProductResponse>();
  final ApiStateProvider<CombinedResponse> filterState = ApiStateProvider<CombinedResponse>();
  final ApiStateProvider<HotPickResponse> hotPickState = ApiStateProvider<HotPickResponse>();

  int? _lastToggledWishlistId;
  bool? _lastWishlistState;

  int? get lastToggledWishlistId => _lastToggledWishlistId;
  bool? get lastWishlistState => _lastWishlistState;



  void setLastToggledWishlist(int productId, bool isWishlisted) {
    _lastToggledWishlistId = productId;
    _lastWishlistState = isWishlisted;
    notifyListeners();
  }

  void resetLastToggledWishlist() {
    _lastToggledWishlistId = null;
    _lastWishlistState = null;
    notifyListeners();
  }

  Product? getProductById(int productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (_) {}

    if (hotPickState.data != null) {
      try {
        return hotPickState.data!.data.firstWhere((p) => p.id == productId);
      } catch (_) {}
    }
    return null;
  }

  int _selectedCategoryId = 0;
  int get selectedCategoryId => _selectedCategoryId;

  String? _selectedType;
  String? get selectedType => _selectedType;

  String _selectedLanguage = 'en';
  String get selectedLanguage => _selectedLanguage;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  bool _showFilterOptions = false;
  bool get showFilterOptions => _showFilterOptions;

  int _currentPage = 1;
  bool _hasMorePages = true;
  bool _hotDataCleared = false;
  bool get hasMorePages => _hasMorePages;

  final List<Product> _products = [];
  List<Product> get products => _products;

  // Hot picks pagination fields
  int _hotPickCurrentPage = 1;
  bool _hotPickHasMorePages = true;
  bool _hotPickIsLoadingMore = false;
  final List<Product> _hotPickProducts = [];
  List<Product> get hotPickProducts => _hotPickProducts;

  bool get hotDataCleared => _hotDataCleared;
  bool get hotPickHasMorePages => _hotPickHasMorePages;
  bool get hotPickIsLoadingMore => _hotPickIsLoadingMore;

  // New filter state management
  String _selectedFilterType = 'brand';
  String get selectedFilterType => _selectedFilterType;

  String? _selectedBrandId;
  String? get selectedBrandId => _selectedBrandId;

  String _filterSearchQuery = '';
  String get filterSearchQuery => _filterSearchQuery;

  List<Brand> _brands = [];
  List<Brand> get brands => _brands;

  List<ProductType> _types = [];
  List<ProductType> get types => _types;

  ProductsDataProvider() {
    _initLanguage();
  }

  // Existing methods
  void toggleFilterOptions() {
    _showFilterOptions = !_showFilterOptions;
    notifyListeners();
  }

  Future<void> _initLanguage() async {
    _selectedLanguage = await SharedService.getLanguage();
    notifyListeners();
  }

  Future<void> initialize(int categoryId) async {
    if (_selectedCategoryId == categoryId) return;

    productsState.setInitial();
    filterState.setInitial();
    _products.clear();
    notifyListeners();

    _selectedCategoryId = categoryId;
    _currentPage = 1;
    _hasMorePages = true;
    _selectedType = null;
    _selectedBrandId = null;

    _selectedLanguage = await SharedService.getLanguage();

    await _repository.clearCategoryCache(
      categoryId: categoryId,
      language: _selectedLanguage,
      typeId: _selectedType,
      brandId: _selectedBrandId,
    );

    await fetchProducts();
  }

  // Existing product methods
  Future<void> updateTypeFilter(String? typeId) async {
    if (_selectedType == typeId) return;

    productsState.setInitial();
    _products.clear();
    _currentPage = 1;
    _hasMorePages = true;

    await _repository.clearCategoryCache(
      categoryId: _selectedCategoryId,
      language: _selectedLanguage,
      typeId: _selectedType,
      brandId: _selectedBrandId,
    );

    _selectedType = typeId;
    notifyListeners();

    await fetchProducts();
  }

  Future<void> updateLanguage(String newLanguage) async {
    if (_selectedLanguage == newLanguage) return;

    productsState.setInitial();
    filterState.setInitial();
    _products.clear();
    _currentPage = 1;
    _hasMorePages = true;
    _isLoadingMore = false;

    await _repository.clearCategoryCache(
      categoryId: _selectedCategoryId,
      language: _selectedLanguage,
      typeId: _selectedType,
      brandId: _selectedBrandId,
    );

    _selectedLanguage = newLanguage;
    notifyListeners();

    if (_selectedCategoryId != 0) {
      await fetchProducts();
    }
  }

  Future<void> refreshProducts() async {
    if (_selectedCategoryId == 0) return;

    try {
      _currentPage = 1;
      _hasMorePages = true;

      await _repository.clearCategoryCache(
        categoryId: _selectedCategoryId,
        language: _selectedLanguage,
        typeId: _selectedType,
        brandId: _selectedBrandId,
      );

      await _repository.getProductsByCategory(
        id: _selectedCategoryId,
        language: _selectedLanguage,
        page: _currentPage,
        typeId: _selectedType,
        brandId: _selectedBrandId,
        stateProvider: productsState,
        cachePolicy: CachePolicy.refreshForceCache,
      );

      productsState.state.whenOrNull(
        success: (response) {
          _products.clear();
          _products.addAll(response.data.products);
          _hasMorePages = response.meta.currentPage < response.meta.lastPage;
          _currentPage = response.meta.currentPage;
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('Error refreshing products: $e');
      rethrow;
    }
  }

  Future<void> fetchProducts() async {
    if (_selectedCategoryId == 0) return;

    try {
      await _repository.getProductsByCategory(
        id: _selectedCategoryId,
        language: _selectedLanguage,
        page: _currentPage,
        typeId: _selectedType,
        brandId: _selectedBrandId,
        stateProvider: productsState,
      );

      productsState.state.whenOrNull(
        success: (response) {
          if (_currentPage == 1) {
            _products.clear();
          }
          _products.addAll(response.data.products);
          _hasMorePages = response.meta.currentPage < response.meta.lastPage;
          _currentPage = response.meta.currentPage;
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('Error fetching products: $e');
      rethrow;
    }
  }

  Future<void> loadMoreProducts() async {
    if (!_hasMorePages || _isLoadingMore || _selectedCategoryId == 0) return;

    try {
      _isLoadingMore = true;
      notifyListeners();

      final nextPage = _currentPage + 1;

      final tempProvider = ApiStateProvider<ProductResponse>();
      await _repository.getProductsByCategory(
        id: _selectedCategoryId,
        language: _selectedLanguage,
        page: nextPage,
        typeId: _selectedType,
        brandId: _selectedBrandId,
        stateProvider: tempProvider,
        cachePolicy: CachePolicy.refreshForceCache,
      );

      tempProvider.state.whenOrNull(
        success: (response) {
          _products.addAll(response.data.products);
          _hasMorePages = response.meta.currentPage < response.meta.lastPage;
          _currentPage = response.meta.currentPage;
        },
      );
    } catch (e) {
      debugPrint('Error loading more products: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Hot picks pagination methods
  Future<void> fetchHotPickData({bool forceRefresh = false}) async {
    try {

        hotPickState.setLoading();
        await clearCache();
      _hotPickCurrentPage = 1;
      _hotPickHasMorePages = true;
      _hotPickProducts.clear();
      _hotDataCleared=true;
      notifyListeners();

      await _repository.getHotPickList(
        stateProvider: hotPickState,
        page: _hotPickCurrentPage,
        cachePolicy: forceRefresh ? CachePolicy.refresh : CachePolicy.refreshForceCache,
      );

      hotPickState.state.whenOrNull(
        success: (response) {
          // Add all products from response (list is already cleared above)
          _hotPickProducts.addAll(response.data);
          _hotPickHasMorePages = response.meta.currentPage < response.meta.lastPage;
          _hotPickCurrentPage = response.meta.currentPage;
        },
      );
    } catch (e) {
      debugPrint('Error fetching hot picks: $e');
    } finally {
      _hotDataCleared=false;
      notifyListeners();
    }
  }

  Future<void> loadMoreHotPickData() async {
    if (!_hotPickHasMorePages || _hotPickIsLoadingMore) return;

    try {
      _hotPickIsLoadingMore = true;
      notifyListeners();

      final nextPage = _hotPickCurrentPage + 1;
      final tempProvider = ApiStateProvider<HotPickResponse>();
      await _repository.getHotPickList(
        stateProvider: tempProvider,
        page: nextPage,
        cachePolicy: CachePolicy.refreshForceCache,
      );

      tempProvider.state.whenOrNull(
        success: (response) {
          // Only add products that don't already exist
          for (var product in response.data) {
            if (!_hotPickProducts.any((p) => p.id == product.id)) {
              _hotPickProducts.add(product);
            }
          }
          _hotPickHasMorePages = response.meta.currentPage < response.meta.lastPage;
          _hotPickCurrentPage = response.meta.currentPage;
        },
      );
    } catch (e) {
      debugPrint('Error loading more hot picks: $e');
    } finally {
      _hotPickIsLoadingMore = false;
      notifyListeners();
    }
  }

  // New filter methods
  Future<void> setFilterType(String filterType, int catId) async {
    if (_selectedFilterType == filterType) return;
    _selectedFilterType = filterType;
    _filterSearchQuery = '';
    await fetchFilters(catId);
    notifyListeners();
  }

  Future<void> setFilterSearchQuery(String query, int catId) async {
    if (_filterSearchQuery == query) return;
    _filterSearchQuery = query;
    await fetchFilters(catId);
    notifyListeners();
  }

  Future<void> updateBrandFilter(String? brandId) async {
    if (_selectedBrandId == brandId) return;

    productsState.setInitial();
    _products.clear();
    _currentPage = 1;
    _hasMorePages = true;

    await _repository.clearCategoryCache(
      categoryId: _selectedCategoryId,
      language: _selectedLanguage,
      typeId: _selectedType,
      brandId: _selectedBrandId,
    );

    _selectedBrandId = brandId;
    notifyListeners();

    await fetchProducts();
  }

  Future<void> fetchFilters(int catId) async {
    try {
      await _repository.getFilters(
        filterType: _selectedFilterType,
        search: _filterSearchQuery,
        stateProvider: filterState,
        catId: catId,
      );

      filterState.state.whenOrNull(
        success: (response) {
          if (_selectedFilterType == 'brand') {
            _brands = response.brands ?? [];
          } else {
            _types = response.types ?? [];
          }
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('Error fetching filters: $e');
    }
  }

  // Cache and reset methods
  Future<void> clearAllCache() async {
    try {
      await _repository.clearCategoryCache(
        categoryId: _selectedCategoryId,
        language: _selectedLanguage,
        typeId: _selectedType,
        brandId: _selectedBrandId,
      );

      await _repository.clearFilterCache(
        filterType: _selectedFilterType,
        search: _filterSearchQuery,
      );

      _products.clear();
      _currentPage = 1;
      _hasMorePages = true;
      _isLoadingMore = false;
      productsState.setInitial();
      filterState.setInitial();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  Future<void> clearCache() async {
    try {
      await _repository.clearHotPickCache();
      notifyListeners();
    } catch (e) {
      debugPrint('Clear cache error: $e');
    }
  }

  void updateProductWishlistState(int productId, bool isWishListed) {
    for (int i = 0; i < _products.length; i++) {
      if (_products[i].id == productId) {
        final updatedProduct = Product(
          id: _products[i].id,
          name: _products[i].name,
          description: _products[i].description,
          price: _products[i].price,
          sellingPrice: _products[i].sellingPrice,
          discountType: _products[i].discountType,
          discount: _products[i].discount,
          totalStock: _products[i].totalStock,
          maximumOrderQuantity: _products[i].maximumOrderQuantity,
          weight: _products[i].weight,
          viewCount: _products[i].viewCount,
          brand: _products[i].brand,
          type: _products[i].type,
          featuredImage: _products[i].featuredImage,
          productImages: _products[i].productImages,
          inWishlist: isWishListed,
          inCart: _products[i].inCart,
        );
        _products[i] = updatedProduct;
      }
    }

    final currentData = productsState.data;
    if (currentData != null) {
      final updatedProducts = currentData.data.products.map((product) {
        if (product.id == productId) {
          return Product(
            id: product.id,
            name: product.name,
            description: product.description,
            price: product.price,
            sellingPrice: product.sellingPrice,
            discountType: product.discountType,
            discount: product.discount,
            totalStock: product.totalStock,
            maximumOrderQuantity: product.maximumOrderQuantity,
            weight: product.weight,
            viewCount: product.viewCount,
            brand: product.brand,
            type: product.type,
            featuredImage: product.featuredImage,
            productImages: product.productImages,
            inWishlist: isWishListed,
            inCart: product.inCart,
          );
        }
        return product;
      }).toList();

      final updatedResponse = ProductResponse(
        status: currentData.status,
        message: currentData.message,
        data: ProductData(
          products: updatedProducts,
          types: currentData.data.types,
        ),
        meta: currentData.meta,
      );

      productsState.setData(updatedResponse);
    }

    notifyListeners();
  }

  void updateHotPickWishlistState(int productId, bool isWishListed) {
    // Update _hotPickProducts
    for (int i = 0; i < _hotPickProducts.length; i++) {
      if (_hotPickProducts[i].id == productId) {
        _hotPickProducts[i] = Product(
          id: _hotPickProducts[i].id,
          name: _hotPickProducts[i].name,
          description: _hotPickProducts[i].description,
          price: _hotPickProducts[i].price,
          sellingPrice: _hotPickProducts[i].sellingPrice,
          discountType: _hotPickProducts[i].discountType,
          discount: _hotPickProducts[i].discount,
          totalStock: _hotPickProducts[i].totalStock,
          maximumOrderQuantity: _hotPickProducts[i].maximumOrderQuantity,
          weight: _hotPickProducts[i].weight,
          viewCount: _hotPickProducts[i].viewCount,
          brand: _hotPickProducts[i].brand,
          type: _hotPickProducts[i].type,
          featuredImage: _hotPickProducts[i].featuredImage,
          productImages: _hotPickProducts[i].productImages,
          inWishlist: isWishListed,
          inCart: _hotPickProducts[i].inCart,
        );
        break; // Exit loop after updating
      }
    }

    // Optionally update hotPickState.data (if used elsewhere)
    final currentData = hotPickState.data;
    if (currentData != null) {
      final updatedProducts = currentData.data.map((product) {
        if (product.id == productId) {
          return Product(
            id: product.id,
            name: product.name,
            description: product.description,
            price: product.price,
            sellingPrice: product.sellingPrice,
            discountType: product.discountType,
            discount: product.discount,
            totalStock: product.totalStock,
            maximumOrderQuantity: product.maximumOrderQuantity,
            weight: product.weight,
            viewCount: product.viewCount,
            brand: product.brand,
            type: product.type,
            featuredImage: product.featuredImage,
            productImages: product.productImages,
            inWishlist: isWishListed,
            inCart: product.inCart,
          );
        }
        return product;
      }).toList();

      final updatedResponse = HotPickResponse(
        status: currentData.status,
        message: currentData.message,
        data: updatedProducts,
        meta: currentData.meta,
      );

      hotPickState.setData(updatedResponse);
    }

    notifyListeners();
  }

  int _currentImageIndex = 0;
  int get currentImageIndex => _currentImageIndex;

  void updateCurrentImageIndex(int index) {
    _currentImageIndex = index;
    notifyListeners();
  }

  void resetImageIndex() {
    _currentImageIndex = 0;
    notifyListeners();
  }

  void reset() {

    _hotPickProducts.clear();
    _hotPickCurrentPage = 1;
    _hotPickHasMorePages = true;
    _hotPickIsLoadingMore = false;
    hotPickState.setInitial();

    _products.clear();
    _selectedCategoryId = 0;
    _selectedType = null;
    _selectedBrandId = null;
    _currentPage = 1;
    _hasMorePages = true;
    _isLoadingMore = false;
    _showFilterOptions = false;
    _filterSearchQuery = '';
    productsState.setInitial();
    filterState.setInitial();
    notifyListeners();
  }
}