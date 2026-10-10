// Checks that every translatable key in lib/l10n/app_en.arb (the template)
// exists in every other locale's .arb file, and flags any key an other
// locale has that the template doesn't (a sign it was renamed/removed in
// English but not everywhere else).
//
// Run: dart run tool/check_arb_parity.dart
// Exits non-zero (and lists the gaps) if anything is out of sync — wire this
// into CI so a string added/renamed in app_en.arb without updating the other
// three files fails the build instead of quietly falling back to English at
// runtime. See lib/l10n/README.md for the day-to-day workflow this backstops.

import 'dart:convert';
import 'dart:io';

void main() {
  final l10nDir = Directory('lib/l10n');
  final templateFile = File('${l10nDir.path}/app_en.arb');
  if (!templateFile.existsSync()) {
    stderr.writeln('Template file not found: ${templateFile.path}');
    exit(2);
  }

  final templateKeys = _translatableKeys(templateFile);

  final otherFiles = l10nDir
      .listSync()
      .whereType<File>()
      .where(
        (f) =>
            f.path.endsWith('.arb') &&
            f.path != templateFile.path,
      )
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  var hasIssues = false;

  for (final file in otherFiles) {
    final keys = _translatableKeys(file);
    final missing = templateKeys.difference(keys);
    final extra = keys.difference(templateKeys);

    if (missing.isEmpty && extra.isEmpty) continue;
    hasIssues = true;

    print('${file.path}:');
    if (missing.isNotEmpty) {
      print('  missing (in app_en.arb, not here):');
      for (final key in missing.toList()..sort()) {
        print('    - $key');
      }
    }
    if (extra.isNotEmpty) {
      print('  extra (here, not in app_en.arb — stale?):');
      for (final key in extra.toList()..sort()) {
        print('    - $key');
      }
    }
    print('');
  }

  if (hasIssues) {
    stderr.writeln('ARB key parity check failed — see gaps listed above.');
    exit(1);
  }

  print('All ${otherFiles.length} translated ARB file(s) match app_en.arb '
      '(${templateKeys.length} keys).');
}

/// Every key that holds an actual translatable string — i.e. not the
/// `@@locale` marker and not an `@key` ICU metadata block.
Set<String> _translatableKeys(File file) {
  final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  return json.keys
      .where((key) => key != '@@locale' && !key.startsWith('@'))
      .toSet();
}
