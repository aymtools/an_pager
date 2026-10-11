import 'package:an_pager/an_pager.dart';
import 'package:test/test.dart';

void main() {
  group('Pager (基于总页数 totalPage 分页)', () {
    test('Pager.first 初始化首页', () {
      final pager = Pager<String>.first(
        data: ['a', 'b'],
        size: 2,
        totalPage: 3,
      );

      expect(pager.index, equals(1));
      expect(pager.size, equals(2));
      expect(pager.totalPage, equals(3));
      expect(pager.hasData, isTrue);
      expect(pager.hasPrevious, isFalse);
      expect(pager.hasNext, isTrue);
      expect(pager.nextPageKey, equals((index: 2, size: 2)));
    });

    test('Pager.fromPageKey 初始化', () {
      final PageKey key = (index: 2, size: 5);
      final pager = Pager<int>.fromPageKey(
        data: [1, 2, 3, 4, 5],
        key: key,
        totalPage: 2,
      );

      expect(pager.index, equals(2));
      expect(pager.size, equals(5));
      expect(pager.hasPrevious, isTrue);
      expect(pager.hasNext, isFalse);
    });

    test('generateNextPage 生成下一页', () {
      final pager = Pager<int>.first(
        data: [1, 2],
        size: 2,
        totalPage: 3,
      );

      final nextPage = pager.generateNextPage([3, 4]);

      expect(nextPage.index, equals(2));
      expect(nextPage.size, equals(2));
      expect(nextPage.data, equals([3, 4]));
      expect(nextPage.totalPage, equals(3));
      expect(nextPage.hasPrevious, isTrue);
      expect(nextPage.hasNext, isTrue);
    });

    test('hasData 判断数据非空状态', () {
      final emptyPager = Pager<int>.first(data: [], size: 10, totalPage: 0);
      expect(emptyPager.hasData, isFalse);

      final nonEmptyPager = Pager<int>.first(data: [1], size: 10, totalPage: 1);
      expect(nonEmptyPager.hasData, isTrue);
    });

    test('参数断言抛出 AssertionError', () {
      expect(
        () => Pager<int>(data: [], index: 0, size: 10, totalPage: 1),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => Pager<int>(data: [], index: 1, size: 0, totalPage: 1),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => Pager<int>(data: [], index: 1, size: 10, totalPage: -1),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('Page (基于总条数 totalCount 分页)', () {
    test('Page.first 及 hasNext 计算', () {
      final page = Page<String>.first(
        data: ['item1', 'item2'],
        size: 2,
        totalCount: 5,
      );

      expect(page.index, equals(1));
      expect(page.size, equals(2));
      expect(page.totalCount, equals(5));
      expect(page.hasPrevious, isFalse);
      expect(page.hasNext, isTrue); // 1 * 2 < 5
    });

    test('最后一页 hasNext 计算', () {
      final page = Page<String>(
        data: ['item5'],
        index: 3,
        size: 2,
        totalCount: 5,
      );

      expect(page.hasPrevious, isTrue);
      expect(page.hasNext, isFalse); // 3 * 2 >= 5
    });

    test('Page.fromPageKey 及 generateNextPage', () {
      final PageKey key = (index: 1, size: 10);
      final page = Page<int>.fromPageKey(
        data: List.generate(10, (i) => i),
        key: key,
        totalCount: 25,
      );

      expect(page.hasNext, isTrue);

      final next = page.generateNextPage(
        List.generate(10, (i) => i + 10),
      );

      expect(next.index, equals(2));
      expect(next.data.first, equals(10));
      expect(next.hasNext, isTrue); // 2 * 10 < 25
    });
  });

  group('KPage (基于自定义 Key/游标/Token 分页)', () {
    test('KPage.first 初始化', () {
      final kpage = KPage<String, String>.first(
        data: ['user1', 'user2'],
        hasNext: true,
        nextPageKey: 'cursor_abc123',
      );

      expect(kpage.data, equals(['user1', 'user2']));
      expect(kpage.hasPrevious, isFalse);
      expect(kpage.hasNext, isTrue);
      expect(kpage.nextPageKey, equals('cursor_abc123'));
      expect(kpage.hasData, isTrue);
    });

    test('KPage.generateNextPage', () {
      final firstPage = KPage<String, String>.first(
        data: ['a', 'b'],
        hasNext: true,
        nextPageKey: 'token_page_2',
      );

      final secondPage = firstPage.generateNextPage(
        ['c', 'd'],
        hasNext: false,
        nextPageKey: 'token_page_3',
      );

      expect(secondPage.data, equals(['c', 'd']));
      expect(secondPage.hasPrevious, isTrue);
      expect(secondPage.hasNext, isFalse);
      expect(secondPage.nextPageKey, equals('token_page_3'));
    });

    test('复杂对象作为 Key 的 KPage', () {
      final kpage = KPage<int, ({int timestamp, String id})>.first(
        data: [100, 200],
        hasNext: true,
        nextPageKey: (timestamp: 1700000000, id: 'last_id_999'),
      );

      expect(kpage.nextPageKey.timestamp, equals(1700000000));
      expect(kpage.nextPageKey.id, equals('last_id_999'));
    });
  });
}
