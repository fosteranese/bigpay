import 'package:equatable/equatable.dart';

part 'data_error.md.dart';
part 'data_response.md.dart';

final class Response<T> extends Equatable {
  const Response({
    required this.code,
    required this.status,
    required this.message,
    this.timeStamp,
    this.imageBaseUrl,
    this.imageDirectory,
    this.data,
  });

  final String code;
  final String status;
  final String message;
  final String? timeStamp;
  final String? imageBaseUrl;
  final String? imageDirectory;
  final T? data;

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
