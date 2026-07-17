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

  /// Rebuilds a response previously written by [toMap].
  ///
  /// This is the inverse of [toMap] — the shape of the cache, not the shape of
  /// the wire. A raw backend envelope carries an int `status` and no `code` at
  /// all, and is turned into a [Response] by `MainRemote._decodeResponse`;
  /// feeding one of those to this factory will not work.
  factory DataResponse.fromMap(Map<String, dynamic> map) => DataResponse<T>(
    code: map['code'] as String,
    status: map['status'] as String,
    message: map['message'] as String,
    timeStamp: map['timeStamp'] as String?,
    imageBaseUrl: map['imageBaseUrl'] as String?,
    imageDirectory: map['imageDirectory'] as String?,
    data: map['data'] as T?,
  );

  /// The persisted form, for [Database.add].
  ///
  /// `data` is whatever `_decodeResponse` produced — decoded JSON — so it is
  /// already encodable and goes through as-is.
  Map<String, dynamic> toMap() => {
    'code': code,
    'status': status,
    'message': message,
    'timeStamp': timeStamp,
    'imageBaseUrl': imageBaseUrl,
    'imageDirectory': imageDirectory,
    'data': data,
  };

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
