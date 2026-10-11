import 'package:an_pager/an_pager.dart';

void main() {
  print('=== 1. 使用 Pager (基于总页数 totalPage 的分页) ===');
  // 假装这是从服务器获取的第 1 页数据
  var pager = Pager<String>.first(
    data: ['文章 1', '文章 2'],
    size: 2,
    totalPage: 3,
  );

  print('当前页码: ${pager.index}'); // 1
  print('当前数据: ${pager.data}'); // ['文章 1', '文章 2']
  print('是否有上一页: ${pager.hasPrevious}'); // false
  print('是否有下一页: ${pager.hasNext}'); // true
  print('下一页请求参数: ${pager.nextPageKey}'); // (index: 2, size: 2)

  if (pager.hasNext) {
    // 模拟请求下一页后，生成新的 Pager 实例
    pager = pager.generateNextPage(['文章 3', '文章 4']);
    print('加载后页码: ${pager.index}'); // 2
    print('加载后数据: ${pager.data}'); // ['文章 3', '文章 4']
  }

  print('\n=== 2. 使用 Page (基于总数据条数 totalCount 的分页) ===');
  // 假装这是从服务器获取的第 1 页数据，总共有 5 条
  var page = Page<String>.first(
    data: ['商品 A', '商品 B'],
    size: 2,
    totalCount: 5,
  );

  print('当前页码: ${page.index}, 总条数: ${page.totalCount}');
  print('是否有下一页: ${page.hasNext}'); // true，因为 1 * 2 < 5

  // 使用 PageKey 直接加载指定页
  final PageKey key = page.nextPageKey; // (index: 2, size: 2)
  page = Page<String>.fromPageKey(
    data: ['商品 C', '商品 D'],
    key: key,
    totalCount: 5,
  );
  print('加载后页码: ${page.index}'); // 2

  print('\n=== 3. 使用 KPage (基于游标/Key 的分页) ===');
  // 假装这是基于 Cursor 游标的分页
  var kpage = KPage<String, String>.first(
    data: ['消息 100', '消息 99'],
    hasNext: true,
    nextPageKey: 'cursor_msg_99',
  );

  print('当前数据: ${kpage.data}');
  print('下一页游标 Key: ${kpage.nextPageKey}'); // cursor_msg_99

  if (kpage.hasNext) {
    kpage = kpage.generateNextPage(
      ['消息 98', '消息 97'],
      hasNext: false, // 最后一页了
      nextPageKey: 'cursor_msg_97',
    );
    print('加载后数据: ${kpage.data}');
    print('是否有下一页: ${kpage.hasNext}'); // false
  }
}
