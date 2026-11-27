import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'package:bigpay/data/models/initialization_data/walk_through.dart';

/// Walkthrough slide images kept permanently on the device (app support dir,
/// keyed by the server's file name), so the walkthrough never shows an image
/// still loading.
///
/// [prepare] runs on the splash: with nothing saved yet it waits for every
/// download; once something is saved it returns at once and fetches the
/// missing ones in the background for next time.
class WalkthroughImages {
  WalkthroughImages._();

  static Directory? _dir;

  /// The saved file for [item], or null when it isn't on the device (yet).
  static File? fileFor(WalkThrough item) {
    final dir = _dir;
    final picture = item.picture;
    if (dir == null || picture == null || picture.isEmpty) return null;
    final file = File('${dir.path}/$picture');
    return file.existsSync() ? file : null;
  }

  /// [baseUrl] is the response envelope's imageBaseUrl (ends with '/').
  static Future<void> prepare(
    List<WalkThrough> items, {
    required String baseUrl,
    required String imageDirectory,
  }) async {
    _dir ??= await Directory(
      '${(await getApplicationSupportDirectory()).path}/walkthrough',
    ).create(recursive: true);

    final missing = items.where((item) {
      final picture = item.picture;
      return picture != null && picture.isNotEmpty && fileFor(item) == null;
    }).toList();
    if (missing.isEmpty || baseUrl.isEmpty) return;

    final downloads = Future.wait(
      missing.map((item) => _download(item, baseUrl, imageDirectory)),
    );
    final anySaved = items.any((item) => fileFor(item) != null);
    if (anySaved) {
      unawaited(downloads);
      return;
    }
    // shortcut: caps the splash wait on a dead connection; slides that
    // didn't make it use the bundled image and download on the next launch.
    await downloads.timeout(const Duration(seconds: 20), onTimeout: () => []);
  }

  static Future<void> _download(
    WalkThrough item,
    String baseUrl,
    String imageDirectory,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$imageDirectory/${item.picture}'),
      );
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) return;
      // Write then rename, so a half-written file is never picked up.
      final target = '${_dir!.path}/${item.picture}';
      final temp = File('$target.part');
      await temp.writeAsBytes(response.bodyBytes, flush: true);
      await temp.rename(target);
    } catch (_) {
      // Offline or bad file — that slide keeps the bundled image.
    }
  }
}
