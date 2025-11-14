import 'package:freezed_annotation/freezed_annotation.dart';
import 'network_exception.dart';

part 'api_result.freezed.dart';

@freezed
class ApiResult<T> with _$ApiResult<T> {
  const factory ApiResult.initial() = _Initial;
  const factory ApiResult.loading() = _Loading;
  const factory ApiResult.success(T data) = _Success;
  const factory ApiResult.failure(NetworkException error) = _Failure;
}