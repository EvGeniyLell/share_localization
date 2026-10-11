import 'package:share_localization/code_generation/exceptions/duplicate_resource_name_exception.dart';
import 'package:share_localization/code_generation/exceptions/invalid_resource_name_exception.dart';
import 'package:share_localization/code_generation/use_cases/resource_name_validation.dart';
import 'package:share_localization/common/common.dart';
import 'package:test/test.dart';

void main() {
  group('validateResourceNames', () {
    const bundleName = 'test_feature_A.json';

    ResourceNameEntry entry(String key, [String? name]) =>
        ResourceNameEntry(key: key, name: name ?? key, baseName: name ?? key);

    test('passes for valid names on flutter', () {
      expect(
        () => validateResourceNames(
          platform: ResourcePlatform.flutter,
          bundleName: bundleName,
          entries: [entry('login_title'), entry('login_message')],
        ),
        returnsNormally,
      );
    });

    test('throws an invalid name error naming the platform', () {
      expect(
        () => validateResourceNames(
          platform: ResourcePlatform.flutter,
          bundleName: bundleName,
          entries: [entry('1stKey', '1st_key')],
        ),
        throwsA(
          const InvalidResourceNameException(
            platform: ResourcePlatform.flutter,
            key: '1stKey',
            name: '1st_key',
            bundleName: bundleName,
          ),
        ),
      );
    });

    test('an empty base name with a valid name is an emptyKeyBase error', () {
      expect(
        () => validateResourceNames(
          platform: ResourcePlatform.flutter,
          bundleName: bundleName,
          entries: [
            const ResourceNameEntry(
              key: '---',
              name: 'test_feature_a',
              baseName: '',
            ),
          ],
        ),
        throwsA(
          const InvalidResourceNameException(
            platform: ResourcePlatform.flutter,
            key: '---',
            name: 'test_feature_a',
            bundleName: bundleName,
            reason: InvalidResourceNameReason.emptyKeyBase,
          ),
        ),
      );
    });

    test('entries with equal names but different identities pass', () {
      expect(
        () => validateResourceNames(
          platform: ResourcePlatform.ios,
          bundleName: bundleName,
          entries: const [
            ResourceNameEntry(
              key: 'foo',
              name: 'foo',
              baseName: 'foo',
              identity: 'foo%@',
            ),
            ResourceNameEntry(
              key: 'foo_b',
              name: 'foo',
              baseName: 'foo',
              identity: 'foo%lld',
            ),
          ],
        ),
        returnsNormally,
      );
    });

    test('entries with equal identities are duplicates', () {
      expect(
        () => validateResourceNames(
          platform: ResourcePlatform.ios,
          bundleName: bundleName,
          entries: const [
            ResourceNameEntry(
              key: 'foo_a',
              name: 'foo',
              baseName: 'foo',
              identity: 'foo%@',
            ),
            ResourceNameEntry(
              key: 'foo_b',
              name: 'foo',
              baseName: 'foo',
              identity: 'foo%@',
            ),
          ],
        ),
        throwsA(
          const DuplicateResourceNameException(
            platform: ResourcePlatform.ios,
            key: 'foo_b',
            otherKey: 'foo_a',
            name: 'foo',
            bundleName: bundleName,
          ),
        ),
      );
    });

    test('duplicate names report both keys', () {
      expect(
        () => validateResourceNames(
          platform: ResourcePlatform.flutter,
          bundleName: bundleName,
          entries: [
            const ResourceNameEntry(
              key: 'my-key',
              name: 'my_key',
              baseName: 'my_key',
            ),
            const ResourceNameEntry(
              key: 'my_key',
              name: 'my_key',
              baseName: 'my_key',
            ),
          ],
        ),
        throwsA(
          const DuplicateResourceNameException(
            platform: ResourcePlatform.flutter,
            key: 'my_key',
            otherKey: 'my-key',
            name: 'my_key',
            bundleName: bundleName,
          ),
        ),
      );
    });

    test('several errors are thrown as a composite in key order', () {
      expect(
        () => validateResourceNames(
          platform: ResourcePlatform.flutter,
          bundleName: bundleName,
          entries: [
            entry('1stKey', '1st_key'),
            entry('ok_key'),
            entry('ключ', ''),
          ],
        ),
        throwsA(
          isA<CompositeException>().having((e) => e.exceptions, 'exceptions', [
            const InvalidResourceNameException(
              platform: ResourcePlatform.flutter,
              key: '1stKey',
              name: '1st_key',
              bundleName: bundleName,
            ),
            const InvalidResourceNameException(
              platform: ResourcePlatform.flutter,
              key: 'ключ',
              name: '',
              bundleName: bundleName,
            ),
          ]),
        ),
      );
    });
  });
}
