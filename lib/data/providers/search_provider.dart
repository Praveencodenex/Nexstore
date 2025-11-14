import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../services/shared_pref_service.dart';
import '../models/home_model.dart';
import '../models/search_model.dart';
import '../repository/search_repository.dart';
import 'api_state_provider.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

class SearchDataProvider extends ChangeNotifier {
  final SearchRepository _repository = SearchRepository();
  final ApiStateProvider<SearchResponse> searchState = ApiStateProvider<SearchResponse>();
  String _lastSearchQuery = '';

  // Speech Recognition
  final SpeechToText _speech = SpeechToText();
  bool _isListening = false;
  bool get isListening => _isListening;

  // Timeout variables
  Timer? _speechTimeout;
  static const int _speechTimeoutDuration = 20; // seconds
  bool _speechInitialized = false;

  // Search Query with debouncing
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  Timer? _debounceTimer;
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  // Recent Searches
  List<String> _recentSearches = [];
  List<String> get recentSearches => _recentSearches;
  static const int _maxRecentSearches = 10;

  // Language Settings
  String _selectedLanguage = 'en';
  String get selectedLanguage => _selectedLanguage;

  // Language mapping for speech recognition
  final Map<String, String> _speechLocaleMapping = {
    'en': 'en-IN',
    'ml': 'ml-IN',
    'ta': 'ta-IN'
  };

  // Initialize provider
  Future<void> initialize() async {
    try {
      // Don't wait for initialization to complete - do it in steps
      // to avoid blocking UI
      _loadRecentSearches();
      _loadLanguage();
      // Initialize speech last to ensure UI is responsive
      _initializeSpeech();
    } catch (e) {
      debugPrint('Initialization error: $e');
    }
  }

  Future<void> _loadLanguage() async {
    try {
      _selectedLanguage = await SharedService.getLanguage();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading language: $e');
      _selectedLanguage = 'en';
    }
  }

  // Initialize speech recognition
  Future<void> _initializeSpeech() async {
    try {
      for (int attempt = 0; attempt < 2; attempt++) {
        try {
          final available = await _speech.initialize(
            onStatus: _onSpeechStatus,
            onError: _onSpeechError,
            debugLogging: kDebugMode, // Enable logging in debug mode
          );

          _speechInitialized = available; // Handle potential null
          if (_speechInitialized) {
            break; // Success, exit retry loop
          } else {
            if (attempt < 1) await Future.delayed(const Duration(milliseconds: 500));
          }
        } catch (innerError) {
          if (attempt < 1) await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    } catch (e) {
      _speechInitialized = false;
    }
  }

  // Use the ORIGINAL status handling that worked before
  void _onSpeechStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      _isListening = false;
      notifyListeners();
    }
  }

  // Use the ORIGINAL error handling that worked before
  void _onSpeechError(SpeechRecognitionError errorNotification) {
    _isListening = false;
    notifyListeners();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    _searchQuery = result.recognizedWords;
    if (result.finalResult) {
      fetchSearchResults(forceRefresh: true); // Force refresh for voice search
      _saveSearch(_searchQuery);
      _isListening = false;
    }
    notifyListeners();
  }

  void _resetSpeechTimeout() {
    _cancelSpeechTimeout();

    // Set new timeout
    _speechTimeout = Timer(Duration(seconds: _speechTimeoutDuration), () {
      // If we're still listening after timeout, stop listening
      if (_isListening) {
        _stopListening();
      }
    });
  }

  void _cancelSpeechTimeout() {
    _speechTimeout?.cancel();
    _speechTimeout = null;
  }

  Future<void> _stopListening() async {
    _cancelSpeechTimeout();
    _isListening = false;
    try {
      await _speech.stop();
    } catch (e) {
      // Ignore errors
    }
    notifyListeners();
  }

  Future<void> toggleListening() async {
    if (!_isListening) {
      try {
        // If not initialized, try to initialize again
        if (!_speechInitialized) {
          await _initializeSpeech();
        }

        if (!_speechInitialized) {
          return;
        }

        final localeId = _speechLocaleMapping[_selectedLanguage] ?? 'en-IN';

        // Set flag before attempting to listen
        _isListening = true;
        notifyListeners();

        // Start timeout immediately
        _resetSpeechTimeout();

        // The simplest approach to avoid the null error issue
        try {
          await _speech.listen(
            onResult: _onSpeechResult,
            localeId: localeId,
            listenOptions: SpeechListenOptions(
              partialResults: true,
              listenMode: ListenMode.search,
              cancelOnError: false,
            ),
          );
        } catch (e) {
          // Just continue regardless of error - the animation will show
          // and the timeout will handle if nothing happens
        }
      } catch (e) {
        _cancelSpeechTimeout();
        _isListening = false;
        notifyListeners();
      }
    } else {
      await _stopListening();
    }
  }

  Future<void> updateLanguage(String languageCode) async {
    if (_selectedLanguage == languageCode) return;

    _selectedLanguage = languageCode;
    await SharedService.saveLanguage(languageCode);

    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }

    // Clear cache and refresh results when language changes
    await clearSearchCache();
    if (_searchQuery.isNotEmpty) {
      await fetchSearchResults(forceRefresh: true);
    }

    notifyListeners();
  }

  Future<void> _loadRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading recent searches: $e');
    }
  }

  Future<void> _saveSearch(String query) async {
    if (query.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _recentSearches = _recentSearches.where((item) => item != query).toList();
      _recentSearches.insert(0, query);

      if (_recentSearches.length > _maxRecentSearches) {
        _recentSearches = _recentSearches.sublist(0, _maxRecentSearches);
      }

      await prefs.setStringList('recent_searches', _recentSearches);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving recent search: $e');
    }
  }

  Future<void> clearRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('recent_searches');
      _recentSearches.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing recent searches: $e');
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();

    // Cancel previous debounce timer
    _debounceTimer?.cancel();

    // If query is empty, reset to initial state immediately
    if (query.trim().isEmpty) {
      searchState.setInitial();
      return;
    }

    // Set up new debounce timer
    _debounceTimer = Timer(_debounceDuration, () {
      fetchSearchResults(forceRefresh: true);
    });
  }

  Future<void> fetchSearchResults({bool forceRefresh = false}) async {
    try {
      if (_searchQuery.trim().isEmpty) {
        searchState.setInitial();
        return;
      }

      // Force refresh if query has changed
      final shouldForceRefresh = forceRefresh || _lastSearchQuery != _searchQuery;

      if (shouldForceRefresh) {
        await clearSearchCache();
      }

      await _repository.searchProducts(
        query: _searchQuery,
        language: _selectedLanguage,
        stateProvider: searchState,
        cachePolicy: shouldForceRefresh ? CachePolicy.refresh : CachePolicy.refreshForceCache,
      );

      if (searchState.state.when(
        initial: () => false,
        loading: () => false,
        success: (_) => true,
        failure: (_) => false,
      )) {
        await _saveSearch(_searchQuery);
      }

      _lastSearchQuery = _searchQuery; // Update last search query
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> clearSearchCache() async {
    try {
      await _repository.clearSearchCache();
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _cancelSpeechTimeout();
    _speech.stop();
    super.dispose();
  }

  void updateProductWishlistState(int productId, bool isWishlisted) {
    // Update the state if we have current data
    final currentData = searchState.data;
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
            inWishlist: isWishlisted,
            inCart: product.inCart,
          );
        }
        return product;
      }).toList();

      final updatedResponse = SearchResponse(
        status: currentData.status,
        message: currentData.message,
        data: updatedProducts,
        meta: currentData.meta,
      );

      searchState.setData(updatedResponse);
      notifyListeners();
    }
  }
}