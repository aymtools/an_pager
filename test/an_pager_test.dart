import 'package:an_pager/an_pager.dart';
import 'package:test/test.dart';

void main() {
  group('Pager (Total-page based pagination)', () {
    test('Pager.first initialization', () {
      // 初始化 Pager 首页
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

    test('Pager.fromPageKey initialization', () {
      // 通过 PageKey 构造函数初始化
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

    test('generateNextPage creates next Pager', () {
      // 验证 generateNextPage 生成下一页数据和索引
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

    test('hasData checks whether data list is not empty', () {
      // 检查 hasData 状态判断
      final emptyPager = Pager<int>.first(data: [], size: 10, totalPage: 0);
      expect(emptyPager.hasData, isFalse);

      final nonEmptyPager = Pager<int>.first(data: [1], size: 10, totalPage: 1);
      expect(nonEmptyPager.hasData, isTrue);
    });

    test('assertion throws AssertionError on invalid constructor parameters',
        () {
      // 验证参数校验和断言触发
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

  group('Page (Total-count based pagination)', () {
    test('Page.first and hasNext calculation', () {
      // 验证 Page.first 及 hasNext 逻辑计算
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

    test('last page hasNext calculation', () {
      // 验证到达最后一页时 hasNext 为 false
      final page = Page<String>(
        data: ['item5'],
        index: 3,
        size: 2,
        totalCount: 5,
      );

      expect(page.hasPrevious, isTrue);
      expect(page.hasNext, isFalse); // 3 * 2 >= 5
    });

    test('Page.fromPageKey and generateNextPage', () {
      // 验证 Page.fromPageKey 及 generateNextPage
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

  group('KPage (Cursor/Key based pagination)', () {
    test('KPage.first initialization', () {
      // 验证 KPage.first 游标/Key 分页器初始化
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
      // 验证 KPage.generateNextPage 更新游标和数据
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

    test('KPage with Record as custom Key', () {
      // 验证使用 Record 复杂对象作为自定义 Key 的 KPage
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
