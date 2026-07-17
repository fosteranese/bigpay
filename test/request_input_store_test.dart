import 'package:flutter_test/flutter_test.dart';

import 'package:bigpay/data/cache/request_input_store.dart';
import 'package:bigpay/models/actions/action.dart';

class _Payload implements ActionPayloadSerializable {
  const _Payload(this.value);
  final String value;
  @override
  Map<String, dynamic> toJson() => {'value': value};
}

/// Minimal concrete Action for the tests.
class _TestAction extends Action<_Payload, dynamic> {
  const _TestAction(String endpoint, {super.payload = const _Payload('')})
    : super(endpoint: endpoint);
}

void main() {
  group('RequestInputStore', () {
    test('read returns the saved action for its endpoint', () {
      final store = RequestInputStore();
      final saved = _TestAction('/a');
      store.write(saved);

      expect(identical(store.read('/a'), saved), isTrue);
    });

    test('read returns null when nothing is saved for the endpoint', () {
      expect(RequestInputStore().read('/unsaved'), isNull);
    });

    test('the latest write for an endpoint wins', () {
      final store = RequestInputStore();
      final first = _TestAction('/a');
      final second = _TestAction('/a');

      store.write(first);
      store.write(second);

      expect(identical(store.read('/a'), second), isTrue);
    });

    test('remove drops the saved action', () {
      final store = RequestInputStore();
      store.write(_TestAction('/a'));

      store.remove('/a');
      expect(store.read('/a'), isNull);
    });

    test('clear forgets everything', () {
      final store = RequestInputStore();
      store.write(_TestAction('/a'));
      store.write(_TestAction('/b'));

      store.clear();
      expect(store.read('/a'), isNull);
      expect(store.read('/b'), isNull);
    });
  });

  group('Action.copyWith', () {
    test('swaps the payload while keeping the endpoint', () {
      const original = _TestAction('/a', payload: _Payload('old'));

      final copy = original.copyWith(payload: const _Payload('new'));

      expect(copy.endpoint, '/a');
      expect(copy.payload.value, 'new');
    });

    test('keeps the original payload when none is given', () {
      const original = _TestAction('/a', payload: _Payload('keep'));

      final copy = original.copyWith(endpoint: '/b');

      expect(copy.endpoint, '/b');
      expect(copy.payload.value, 'keep');
    });
  });
}
