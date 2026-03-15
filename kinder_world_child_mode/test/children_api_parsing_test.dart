import 'package:flutter_test/flutter_test.dart';
import 'package:kinder_world/core/utils/children_api_parsing.dart';

void main() {
  group('extractChildrenList', () {
    test('returns root list entries when payload is a list', () {
      final result = extractChildrenList([
        {'id': 1, 'name': 'Lina'},
        {'id': 2, 'name': 'Omar'},
      ]);

      expect(result, hasLength(2));
      expect(result.first['name'], 'Lina');
      expect(result.last['id'], 2);
    });

    test('supports common wrapper keys', () {
      final result = extractChildrenList({
        'items': [
          {'child_id': 'kid-1', 'name': 'Mira'},
        ],
      });

      expect(result, hasLength(1));
      expect(result.single['child_id'], 'kid-1');
    });

    test('returns empty list for unsupported payloads', () {
      expect(extractChildrenList('invalid'), isEmpty);
      expect(extractChildrenList({'children': 'invalid'}), isEmpty);
    });
  });

  group('parseChildId', () {
    test('prefers id before fallback aliases', () {
      expect(
        parseChildId({
          'id': 7,
          'child_id': 'legacy-id',
          'childId': 'camel-id',
        }),
        '7',
      );
    });

    test('falls back to child_id and childId', () {
      expect(parseChildId({'child_id': 'legacy-id'}), 'legacy-id');
      expect(parseChildId({'childId': 'camel-id'}), 'camel-id');
      expect(parseChildId({}), isNull);
    });
  });
}
