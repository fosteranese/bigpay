part of 'response.md.dart';

final class DataResponse<T> extends Response<T> {
  const DataResponse({
    required super.code,
    required super.status,
    required super.message,
    super.timeStamp,
    super.imageBaseUrl,
    super.imageDirectory,
    super.data,
  });

  DataResponse<T> copyWith({
    String? code,
    String? status,
    String? message,
    String? timeStamp,
    String? imageBaseUrl,
    String? imageDirectory,
    T? data,
  }) => DataResponse(
    code: code ?? super.code,
    status: status ?? super.status,
    message: message ?? super.message,
    timeStamp: timeStamp ?? super.timeStamp,
    imageBaseUrl: imageBaseUrl ?? super.imageBaseUrl,
    imageDirectory: imageDirectory ?? super.imageDirectory,
    data: data ?? super.data,
  );

  @override
  List<Object?> get props => [
    code,
    status,
    message,
    timeStamp,
    imageBaseUrl,
    imageDirectory,
    data,
  ];
}
