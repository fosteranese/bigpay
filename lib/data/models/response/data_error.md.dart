part of 'response.md.dart';

final class DataError extends Response {
  const DataError({
    required super.code,
    required super.status,
    required super.message,
  });

  DataError copyWith({
    String? code,
    String? status,
    String? message,
  }) => DataError(
    code: code ?? super.code,
    status: status ?? super.status,
    message: message ?? super.message,
  );

  @override
  List<Object?> get props => [
    code,
    status,
    message,
  ];
}
