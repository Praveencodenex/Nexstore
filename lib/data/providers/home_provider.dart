import 'dart:async';
import 'package:flutter/material.dart';
import '../models/home_model.dart';
import '../repository/home_repository.dart';
import 'api_state_provider.dart';

class HomeDataProvider extends ChangeNotifier {
  final HomeRepository _repository = HomeRepository();
  final ApiStateProvider<HomeResponse> homeState = ApiStateProvider<HomeResponse>();
  final PageController bannerController = PageController();
  final ValueNotifier<Duration> timeRemainingNotifier = ValueNotifier(Duration.zero);

  int currentBannerIndex = 0;
  Timer? bannerTimer;
  StreamController<Duration>? _countdownStreamController;

  Zeromins? get zeromins {
    final currentData = homeState.data;
    return currentData?.data.zeromins;
  }

  List<String> get marquees {
    final currentData = homeState.data;
    return currentData?.data.marquees ?? [];
  }

  List<Banners> get banners {
    final currentData = homeState.data;
    return currentData?.data.banners ?? [];
  }

  Future<void> fetchHomeData({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        await clearCache();
        homeState.setLoading();
        notifyListeners();
      }

      await _repository.getHome(stateProvider: homeState);

      if (homeState.data != null && homeState.data!.data.banners.isNotEmpty) {
        // startBannerTimer(); // Uncomment if needed
      }

      if (homeState.data != null && homeState.data!.data.zeromins?.upcoming != null) {
        startCountdownTimer(homeState.data!.data.zeromins!.upcoming!);
      }

      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void updateProductWishlistState(int productId, bool isWishListed) {
    final currentData = homeState.data;
    if (currentData != null) {
      final updatedTopProducts = currentData.data.topProducts.map((product) {
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
            inCart: product.inCart,
            viewCount: product.viewCount,
            brand: product.brand,
            type: product.type,
            featuredImage: product.featuredImage,
            productImages: product.productImages,
            inWishlist: isWishListed,
          );
        }
        return product;
      }).toList();

      final updatedData = HomeData(
        zeromins: currentData.data.zeromins,
        banners: currentData.data.banners,
        categories: currentData.data.categories,
        topProducts: updatedTopProducts,
        marquees: currentData.data.marquees,
      );

      final updatedResponse = HomeResponse(
        status: currentData.status,
        message: currentData.message,
        data: updatedData,
      );

      homeState.setData(updatedResponse);
      notifyListeners();
    }
  }

  void startBannerTimer() {
    stopBannerTimer();
    if (banners.isEmpty) return;

    bannerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (banners.isNotEmpty) {
        currentBannerIndex = (currentBannerIndex + 1) % banners.length;
        if (bannerController.hasClients) {
          bannerController.animateToPage(
            currentBannerIndex,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          );
        }
        notifyListeners();
      }
    });
  }

  void stopBannerTimer() {
    bannerTimer?.cancel();
    bannerTimer = null;
  }

  void changeBannerPage(int index) {
    currentBannerIndex = index;
    notifyListeners();
  }

  Future<void> clearCache() async {
    await _repository.clearHomeCache();
    notifyListeners();
  }

  void startCountdownTimer(ZerominsEvent upcomingEvent) {
    _countdownStreamController?.close();
    _countdownStreamController = StreamController<Duration>();

    final DateTime? startTime = _parseDateTime(upcomingEvent.startDateTime);
    if (startTime == null) {
      timeRemainingNotifier.value = Duration.zero;
      return;
    }

    _countdownStreamController!.stream.listen((_) {
      final now = DateTime.now();
      final difference = startTime.difference(now);

      if (difference.isNegative) {
        timeRemainingNotifier.value = Duration.zero;
        _countdownStreamController?.close();
        fetchHomeData(forceRefresh: false);
      } else {
        timeRemainingNotifier.value = difference;
      }
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownStreamController?.isClosed ?? true) {
        timer.cancel();
        return;
      }
      _countdownStreamController!.add(Duration.zero);
    });
  }

  DateTime? _parseDateTime(String dateTimeString) {
    try {
      if (dateTimeString.contains('AM') || dateTimeString.contains('PM')) {
        final parts = dateTimeString.split(' ');
        if (parts.length >= 3) {
          final datePart = parts[0];
          final timePart = parts[1];
          final amPm = parts[2];
          final timeComponents = timePart.split(':');
          if (timeComponents.length >= 2) {
            int hour = int.parse(timeComponents[0]);
            final int minute = int.parse(timeComponents[1]);
            if (amPm.toUpperCase() == 'PM' && hour != 12) {
              hour += 12;
            } else if (amPm.toUpperCase() == 'AM' && hour == 12) {
              hour = 0;
            }
            final dateComponents = datePart.split('-');
            if (dateComponents.length == 3) {
              final int year = int.parse(dateComponents[0]);
              final int month = int.parse(dateComponents[1]);
              final int day = int.parse(dateComponents[2]);
              return DateTime(year, month, day, hour, minute);
            }
          }
        }
      } else {
        return DateTime.parse(dateTimeString.replaceAll(' ', 'T'));
      }
    } catch (e) {
      debugPrint('Error parsing datetime: $dateTimeString - $e');
    }
    return null;
  }

  @override
  void dispose() {
    stopBannerTimer();
    _countdownStreamController?.close();
    bannerController.dispose();
    timeRemainingNotifier.dispose();
    super.dispose();
  }
}