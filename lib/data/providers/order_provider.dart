import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:thenexstore/data/models/common_response.dart';
import 'package:thenexstore/data/models/invoice_model.dart';
import 'package:thenexstore/data/models/order_details_model.dart';
import 'package:thenexstore/routes/navigator_services.dart';
import 'package:thenexstore/routes/routes_names.dart';
import 'package:thenexstore/utils/snack_bar.dart';
import 'package:path/path.dart' as path;

import '../services/permission_service.dart';
import '../models/order_create_model.dart';
import '../models/order_model.dart';
import '../models/order_track_model.dart';
import '../models/reorder_model.dart';
import '../repository/order_repository.dart';
import 'api_state_provider.dart';

class OrderProvider with ChangeNotifier {
  final OrderListRepository _repository = OrderListRepository();
  final ApiStateProvider<OrdersResponse> orderState = ApiStateProvider<OrdersResponse>();
  final ApiStateProvider<OrderStatusResponse> orderTrackState = ApiStateProvider<OrderStatusResponse>();
  final ApiStateProvider<OrderDetailsResponse> orderDetailsState = ApiStateProvider<OrderDetailsResponse>();
  final ApiStateProvider<ReorderResponse> reOrderState = ApiStateProvider<ReorderResponse>();
  final ApiStateProvider<CommonResponse> reviewOrderState = ApiStateProvider<CommonResponse>();
  final ApiStateProvider<CommonResponse> paymentState = ApiStateProvider<CommonResponse>();
  final ApiStateProvider<OrderCreateResponse> createOrderState = ApiStateProvider<OrderCreateResponse>();
  final ApiStateProvider<CommonResponse> reOrderSubmitState = ApiStateProvider<CommonResponse>();
  final ApiStateProvider<InvoiceResponse> downloadState = ApiStateProvider<InvoiceResponse>();

  // Product selection state for reorder screen
  final Map<int, bool> _selectedProducts = {};
  Map<int, bool> get selectedProducts => _selectedProducts;

  // Rating related state
  int _selectedRating = 0;
  int get selectedRating => _selectedRating;

  void setRating(int rating) {
    _selectedRating = rating;
    notifyListeners();
  }

  // Reason selection state
  String? _selectedReason;
  String? get selectedReason => _selectedReason;

  void setSelectedReason(String? reason) {
    _selectedReason = reason;
    notifyListeners();
  }

  void clearSelectedReason() {
    _selectedReason = null;
    notifyListeners();
  }

  // Loading states
  bool _isLoadingRe = false;
  bool _isCancelling = false;
  bool _isReviewing = false;
  bool _isExchanging = false;
  bool _isDownloading = false;

  bool get isLoadingRe => _isLoadingRe;
  bool get isDownloading => _isDownloading;
  bool get isReviewing => _isReviewing;
  bool get isExchanging => _isExchanging;
  bool get isCancelling => _isCancelling;

  // Product selection methods
  void toggleProductSelection(int productId, bool isSelected) {
    _selectedProducts[productId] = isSelected;
    notifyListeners();
  }

  void clearProductSelections() {
    _selectedProducts.clear();
    notifyListeners();
  }

  int getSelectedProductsCount() {
    return _selectedProducts.values.where((selected) => selected).length;
  }

  List<int> getSelectedProductIds() {
    return _selectedProducts.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  final List<OrderListData> _orders = [];
  List<OrderListData> get orders => _orders;

  int _currentPage = 1;
  bool _hasMorePages = true;
  bool _isLoadingMore = false;

  bool get hasMorePages => _hasMorePages;
  bool get isLoadingMore => _isLoadingMore;

  // Reorder items pagination properties
  final List<ReorderProduct> _reorderItems = [];
  List<ReorderProduct> get reorderItems => _reorderItems;

  int _reorderCurrentPage = 1;
  bool _reorderHasMorePages = true;
  bool _reorderIsLoadingMore = false;

  bool get reorderHasMorePages => _reorderHasMorePages;
  bool get reorderIsLoadingMore => _reorderIsLoadingMore;

  Future<void> fetchOrderData({bool forceRefresh = false}) async {
    try {
      // If data already exists and not forcing refresh, return early
      if (!forceRefresh && _orders.isNotEmpty) {
        return;
      }

      // Clear and reset for fresh fetch
      await clearCache();
      orderState.setLoading();
      _currentPage = 1;
      _hasMorePages = true;
      _orders.clear();
      notifyListeners();

      await _repository.getOrderList(
        stateProvider: orderState,
        forceRefresh: forceRefresh,
        page: _currentPage,
      );

      orderState.state.whenOrNull(
        success: (orderData) {
          _orders.addAll(orderData.data);
          _hasMorePages = orderData.meta.currentPage < orderData.meta.lastPage;
          _currentPage = orderData.meta.currentPage;
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchReOrderData({bool forceRefresh = false}) async {
    try {
      // If data already exists and not forcing refresh, return early
      if (!forceRefresh && _reorderItems.isNotEmpty) {
        return;
      }

      // Clear and reset for fresh fetch
      await clearCache();
      reOrderState.setLoading();
      _reorderCurrentPage = 1;
      _reorderHasMorePages = true;
      _reorderItems.clear();
      notifyListeners();

      await _repository.getReorderList(
        stateProvider: reOrderState,
        forceRefresh: forceRefresh,
        page: _reorderCurrentPage,
      );

      reOrderState.state.whenOrNull(
        success: (reorderData) {
          _reorderItems.addAll(reorderData.data);
          _reorderHasMorePages = reorderData.meta.currentPage < reorderData.meta.lastPage;
          _reorderCurrentPage = reorderData.meta.currentPage;
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadMoreOrders() async {
    if (!_hasMorePages || _isLoadingMore) return;

    try {
      _isLoadingMore = true;
      notifyListeners();

      final nextPage = _currentPage + 1;
      final tempProvider = ApiStateProvider<OrdersResponse>();
      await _repository.getOrderList(
        stateProvider: tempProvider,
        forceRefresh: false,
        page: nextPage,
      );

      tempProvider.state.whenOrNull(
        success: (orderData) {
          _orders.addAll(orderData.data);
          _hasMorePages = orderData.meta.currentPage < orderData.meta.lastPage;
          _currentPage = orderData.meta.currentPage;
        },
      );
    } catch (e) {
      debugPrint('Error loading more orders: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> getOrderTrack({bool forceRefresh = false, required int orderId}) async {
    try {
      if (forceRefresh) {
        await clearCache();
        orderTrackState.setLoading();
        notifyListeners();
      }

      await _repository.getOrderTrack(
        stateProvider: orderTrackState,
        forceRefresh: forceRefresh,
        orderId: orderId,
      );
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> submitReorder(dynamic orderIds) async {
    try {
      _isLoadingRe = true;
      notifyListeners();

      await _repository.submitReorder(
        orderIds: orderIds,
        stateProvider: reOrderSubmitState,
      );
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isLoadingRe = false;
      notifyListeners();
    }
  }

  Future<void> cancelOrder(int orderId, String reason) async {
    try {
      _isCancelling = true;
      notifyListeners();

      await _repository.cancelOrder(
        orderId: orderId,
        reason: reason,
        stateProvider: reOrderSubmitState,
      );

      reOrderSubmitState.state.maybeWhen(
        success: (response) {
          fetchOrderData();
        },
        orElse: () {},
      );
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isCancelling = false;
      notifyListeners();
    }
  }

  Future<void> exchangeOrder(int orderId, String reason, int productId) async {
    try {
      _isExchanging = true;
      notifyListeners();

      await _repository.exchangeOrder(
        orderId: orderId,
        reason: reason,
        productId: productId,
        stateProvider: reOrderSubmitState,
      );
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isExchanging = false;
      notifyListeners();
    }
  }

  String _generateUniqueFileName(String baseName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(10000);
    if (baseName.toLowerCase().endsWith('.pdf')) {
      baseName = baseName.substring(0, baseName.length - 4);
    }
    baseName = baseName.replaceAll(RegExp(r'[^\w\s.-]'), '_');
    return '${baseName}_${timestamp}_$random.pdf';
  }

  final ApiStateProvider<String> _downloadState = ApiStateProvider<String>();

  Future<void> downloadInvoice(BuildContext context, String? pdfUrl, String fileName) async {
    if (pdfUrl == null || pdfUrl.isEmpty) {
      SnackBarUtils.showError("Invoice not available");
      return;
    }

    try {
      _isDownloading = true;
      notifyListeners();
      String uniqueFileName = _generateUniqueFileName(fileName);
      Map<Permission, PermissionStatus> statuses =
      await AdvancedPermissionService.requestMediaPermissions(context);
      bool permissionGranted = false;

      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final androidVersion = androidInfo.version.sdkInt;

        if (androidVersion >= 33) {
          permissionGranted = statuses[Permission.photos]?.isGranted ?? false;
        } else if (androidVersion >= 30) {
          permissionGranted = statuses[Permission.manageExternalStorage]?.isGranted ?? false;
        } else {
          permissionGranted = statuses[Permission.storage]?.isGranted ?? false;
        }
      } else if (Platform.isIOS) {
        permissionGranted = true;
      }

      if (!permissionGranted) {
        _isDownloading = false;
        notifyListeners();
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        SnackBarUtils.showError("Storage permission required to download invoice");
        return;
      }

      String storageDir;
      if (Platform.isAndroid) {
        const directoryPath = '/storage/emulated/0/Download/thenexstore';
        final directory = Directory(directoryPath);
        if (!await directory.exists()) {
          try {
            await directory.create(recursive: true);
          } catch (e) {
            debugPrint('Error creating directory: $e');
            final appDir = await getExternalStorageDirectory();
            storageDir = appDir?.path ?? (await getTemporaryDirectory()).path;
          }
        }

        if (await directory.exists()) {
          storageDir = directoryPath;
        } else {
          final appDir = await getExternalStorageDirectory();
          storageDir = appDir?.path ?? (await getTemporaryDirectory()).path;
        }
      } else if (Platform.isIOS) {
        final directory = await getApplicationDocumentsDirectory();
        storageDir = directory.path;
      } else {
        final tempDir = await getTemporaryDirectory();
        storageDir = tempDir.path;
      }

      String savePath = path.join(storageDir, uniqueFileName);

      await _repository.downloadInvoice(
        url: pdfUrl,
        savePath: savePath,
        stateProvider: _downloadState,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            notifyListeners();
          }
        },
      );

      _downloadState.state.maybeWhen(
        success: (path) {
          final file = File(path);
          file.exists().then((exists) {
            if (exists) {
              SnackBarUtils.showSuccess("Invoice downloaded successfully");
            } else {
              SnackBarUtils.showError("Download completed but file not found");
            }
          });
        },
        failure: (error) {
          SnackBarUtils.showError("Download failed: ${error.message}");
        },
        orElse: () {},
      );
    } catch (e) {
      SnackBarUtils.showError("Download failed: ${e.toString()}");
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  Future<void> getInvoice(int orderId, BuildContext context) async {
    try {
      await _repository.getInvoice(
        orderId: orderId,
        stateProvider: downloadState,
      );

      downloadState.state.maybeWhen(
          orElse: () {},
          success: (data) {
            downloadInvoice(context, data.data.invoiceUrl, orderId.toString());
          },
          failure: (error) {
            SnackBarUtils.showError("Failed to download invoice");
          });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchOrderDetails({bool forceRefresh = false, required int orderId}) async {
    try {
      if (forceRefresh) {
        await clearCache();
        orderDetailsState.setLoading();
        notifyListeners();
      }

      await _repository.fetchOrderDetails(
        stateProvider: orderDetailsState,
        forceRefresh: forceRefresh,
        orderId: orderId,
      );
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }


  Future<void> loadMoreReorders() async {
    if (!_reorderHasMorePages || _reorderIsLoadingMore) return;

    try {
      _reorderIsLoadingMore = true;
      notifyListeners();

      final nextPage = _reorderCurrentPage + 1;
      final tempProvider = ApiStateProvider<ReorderResponse>();
      await _repository.getReorderList(
        stateProvider: tempProvider,
        forceRefresh: false,
        page: nextPage,
      );

      tempProvider.state.whenOrNull(
        success: (reorderData) {
          _reorderItems.addAll(reorderData.data);
          _reorderHasMorePages = reorderData.meta.currentPage < reorderData.meta.lastPage;
          _reorderCurrentPage = reorderData.meta.currentPage;
        },
      );
    } catch (e) {
      debugPrint('Error loading more reorders: $e');
    } finally {
      _reorderIsLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> orderReview(int orderId, int rating, String comment) async {
    try {
      _isReviewing = true;
      notifyListeners();

      await _repository.orderReview(
        stateProvider: reviewOrderState,
        orderId: orderId,
        rating: rating,
        comment: comment,
      );
      reviewOrderState.state.maybeWhen(orElse: () {}, success: (data) {
        fetchOrderDetails(orderId: orderId);
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isReviewing = false;
      notifyListeners();
    }
  }

  Future<void> paymentUpdate(int orderId, String status, String paymentId) async {
    try {
      await _repository.confirmPayment(
        stateProvider: paymentState,
        orderId: orderId,
        status: status,
        paymentId: paymentId,
      );
      paymentState.state.maybeWhen(orElse: () {}, success: (data) {
        if (status == "unpaid") {
          NavigationService.instance.navigateTo(RouteNames.failedScreen);
        } else {
          NavigationService.instance.navigateToSuccessFromCheckout();
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _isReviewing = false;
      notifyListeners();
    }
  }

  // Order creation related state
  bool loading = false;
  bool get isLoading => loading;
  String? _currentPaymentType;
  String? razorpayOrderId;
  bool get isOnlinePaymentLoading => loading && _currentPaymentType == 'online';
  bool get isOfflinePaymentLoading => loading && _currentPaymentType == 'offline';

  Future<void> orderCreation({
    String? coupon,
    required int cartId,
    required String paymentType,
    required String paymentStatus,
    required int addressId,
    required BuildContext context,
    required double amount,
  }) async {
    try {
      loading = true;
      _currentPaymentType = paymentType;
      notifyListeners();

      await _repository.createOrder(
        stateProvider: createOrderState,
        cartId: cartId,
        coupon: coupon,
        addressId: addressId,
        paymentType: paymentType, paymentStatus: paymentStatus,
      );

      createOrderState.state.maybeWhen(success: (response) {
        if (paymentType == "offline") {
          NavigationService.instance.navigateToSuccessFromCheckout();
        } else {
          NavigationService.instance.pushNamedAndClearStack(RouteNames.successScreen);

        }
      }, failure: (error) {
        SnackBarUtils.showError("Failed to create order! ${error.message}");
      }, orElse: () {});
    } catch (e) {
      debugPrint('Checkout error: $e');
    } finally {
      loading = false;
      _currentPaymentType = null; // Reset
      notifyListeners();
    }
  }

  Future<void> clearCache() async {
    await _repository.clearOrderCache();
    notifyListeners();
  }
}