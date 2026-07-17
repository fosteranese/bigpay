import 'package:equatable/equatable.dart';

class WalkthroughData extends Equatable {
  final String title;
  final String subtitle;

  /// Absolute URL of the slide image, or null when the payload carries no
  /// usable one. Callers fall back to a bundled asset.
  final String? imageUrl;

  const WalkthroughData({
    required this.title,
    required this.subtitle,
    this.imageUrl,
  });

  /// Builds a slide from one `walkThrough` entry of the initialization
  /// response.
  ///
  /// `picture` is a bare filename (`Walkthrough_2.jpg`); the host and folder
  /// arrive separately as `imageBaseUrl` and `imageDirectory` on the enclosing
  /// `data` object, so they have to be passed in.
  factory WalkthroughData.fromMap(
    Map<String, dynamic> map, {
    String? imageBaseUrl,
    String? imageDirectory,
  }) {
    return WalkthroughData(
      title: map['title'] as String? ?? '',
      subtitle: map['description'] as String? ?? '',
      imageUrl: _imageUrl(
        picture: map['picture'] as String?,
        baseUrl: imageBaseUrl,
        directory: imageDirectory,
      ),
    );
  }

  static String? _imageUrl({
    required String? picture,
    required String? baseUrl,
    required String? directory,
  }) {
    if (picture == null || picture.isEmpty) return null;
    if (baseUrl == null || baseUrl.isEmpty) return null;

    final segments = [
      baseUrl,
      if (directory != null && directory.isNotEmpty) directory,
      picture,
    ].map((segment) => segment.replaceAll(RegExp(r'^/+|/+$'), ''));

    return segments.join('/');
  }

  @override
  List<Object?> get props => [title, subtitle, imageUrl];
}
