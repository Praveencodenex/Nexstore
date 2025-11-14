import 'package:flutter/foundation.dart';

import '../helper/api_result.dart';
import '../helper/network_exception.dart';



class ApiStateProvider<T> extends ChangeNotifier {
  ApiResult<T> _state = ApiResult<T>.initial();
  ApiResult<T> get state => _state;

  // Add isLoading getter
  bool get isLoading => _state.maybeWhen(
    loading: () => true,
    orElse: () => false,
  );

  // Add data getter to access current data
  T? get data {
    return state.when(
      initial: () => null,
      loading: () => _lastData,
      success: (data) {
        _lastData = data;
        return data;
      },
      failure: (_) => _lastData,
    );
  }

  // Keep track of last successful data
  T? _lastData;

  void setInitial() {
    _state = ApiResult<T>.initial();
    notifyListeners();
  }

  void setLoading() {
    _state = ApiResult<T>.loading();
    notifyListeners();
  }

  void setData(T data) {
    _lastData = data;
    _state = ApiResult<T>.success(data);
    notifyListeners();
  }

  void setError(NetworkException error) {
    _state = ApiResult<T>.failure(error);
    notifyListeners();
  }
}