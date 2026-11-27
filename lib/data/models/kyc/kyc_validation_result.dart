import 'package:equatable/equatable.dart';

/// Validated identity returned by `MyAccount/enhanceValidation`. The fields sit
/// under the response's nested `data` prop (name/gender/nationality from the
/// Ghana-card result), previewed on the KYC contact-info page after a
/// successful validation.
class KycValidationResult extends Equatable {
  const KycValidationResult({this.name, this.nationality, this.gender});

  final String? name;
  final String? nationality;
  final String? gender;

  /// Parses from the action's response payload, which carries the identity in
  /// a `data` sub-object. Tolerates the fields sitting at the top level too.
  factory KycValidationResult.fromResponse(dynamic response) {
    final root = response is Map ? response.cast<String, dynamic>() : const {};
    final data = root['data'] is Map
        ? (root['data'] as Map).cast<String, dynamic>()
        : root;
    return KycValidationResult(
      name: data['name'] as String?,
      nationality: data['nationality'] as String?,
      gender: data['gender'] as String?,
    );
  }

  bool get hasAny =>
      (name?.trim().isNotEmpty ?? false) ||
      (nationality?.trim().isNotEmpty ?? false) ||
      (gender?.trim().isNotEmpty ?? false);

  @override
  List<Object?> get props => [name, nationality, gender];
}
