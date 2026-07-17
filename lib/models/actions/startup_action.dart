import 'package:bigpay/blocs/process/process_bloc.dart';
import 'package:bigpay/models/actions/action.dart';
import 'package:bigpay/models/walkthrough_data.dart';
import 'package:uuid/uuid.dart';

final class StartupAction extends Action<NoPayload, List<WalkthroughData>> {
  /// The endpoint, reachable without an instance — e.g.
  /// `store.cache.latestForEndpoint(StartupAction.path)`. Named `path` rather
  /// than `endpoint` because a static can't share a name with the inherited
  /// instance `endpoint` field.
  static const path = '/UserAccess/initialization';

  const StartupAction({
    super.payload = const NoPayload(),
  }) : super(
         endpoint: path,
         responseDataFunc: _responseDataFunc,
       );

  /// Maps the initialization payload down to the walkthrough slides.
  ///
  /// The response also carries termsAndConditions, privacyPolicy,
  /// secretQuestions, help, locatorsList, locatorTypes, social, advert and
  /// otherLinks. Nothing reads those yet, so they are dropped here rather than
  /// modelled speculatively — the screens that need them will want an
  /// initialization response type covering the whole envelope.
  static List<WalkthroughData> _responseDataFunc(dynamic response) {
    if (response is! Map<String, dynamic>) return const [];

    final slides = response['walkThrough'];
    if (slides is! List<dynamic>) return const [];

    // `picture` is only a filename; the host and folder live on the enclosing
    // object, which `_decodeResponse` copies in from the envelope.
    final imageBaseUrl = response['imageBaseUrl'] as String?;
    final imageDirectory = response['imageDirectory'] as String?;

    return slides
        .whereType<Map<String, dynamic>>()
        .map(
          (slide) => WalkthroughData.fromMap(
            slide,
            imageBaseUrl: imageBaseUrl,
            imageDirectory: imageDirectory,
          ),
        )
        .toList();
  }
}

final startUpEvent = ExecuteProcessEvent(
  id: Uuid().v4(),
  action: StartupAction(),
  returnSavedResponse: true,
  saveActionResponse: true,
);
