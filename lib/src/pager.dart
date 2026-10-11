/// 分页器抽象基类
///
/// [T] 数据元素类型
/// [K] 请求下一页所需的分页键类型
/// [P] 当前分页器的具体子类类型
abstract class BasePager<T, K, P extends BasePager<T, K, P>> {
  /// 当前页的数据列表
  List<T> get data;

  /// 当前页是否有数据
  bool get hasData => data.isNotEmpty;

  /// 是否有下一页
  bool get hasNext;

  /// 是否有上一页
  bool get hasPrevious;

  /// 根据输入的下一页数据生成下一页的分页器实例
  P generateNextPage(List<T> nextData);

  /// 获取请求下一页所需的分页键
  K get nextPageKey;
}

/// 传统基于页码与页大小的分页参数类型记录 (index: 页码, size: 每页条数)
typedef PageKey = ({int index, int size});

/// 传统基于页码和页大小（[index] & [size]）的分页器抽象基类
abstract class TPager<T, P extends TPager<T, P>> extends BasePager<T, PageKey, P> {
  @override
  final List<T> data;

  /// 当前页码（从 1 开始）
  final int index;

  /// 每页数据条数
  final int size;

  /// 创建传统页码分页器基类实例
  TPager({
    required this.data,
    required this.index,
    required this.size,
  })  : assert(index > 0, 'index must be greater than 0'),
        assert(size > 0, 'size must be greater than 0');

  @override
  bool get hasPrevious => index > 1;

  @override
  PageKey get nextPageKey => (index: index + 1, size: size);
}

/// 基于总页数（[totalPage]）的分页器实现
class Pager<T> extends TPager<T, Pager<T>> {
  /// 总页数
  final int totalPage;

  /// 创建基于总页数的分页器
  Pager({
    required super.data,
    required super.index,
    required super.size,
    required this.totalPage,
  }) : assert(totalPage >= 0, 'totalPage must be greater than or equal to 0');

  /// 创建首页分页器（默认页码 [index] 为 1）
  Pager.first({
    required super.data,
    required super.size,
    required this.totalPage,
  })  : assert(size > 0, 'size must be greater than 0'),
        assert(totalPage >= 0, 'totalPage must be greater than or equal to 0'),
        super(index: 1);

  /// 通过 [PageKey] 创建基于总页数的分页器
  Pager.fromPageKey({
    required super.data,
    required PageKey key,
    required this.totalPage,
  }) : super(index: key.index, size: key.size);

  @override
  bool get hasNext => index < totalPage;

  @override
  Pager<T> generateNextPage(
      List<T> nextData, {
        int? size,
        int? totalPage,
      }) =>
      Pager(data: nextData, index: index + 1, size: size ?? this.size, totalPage: totalPage ?? this.totalPage);
}

/// 基于总条数（[totalCount]）的分页器实现
class Page<T> extends TPager<T, Page<T>> {
  /// 总条数
  final int totalCount;

  /// 创建基于总条数的分页器
  Page({
    required super.data,
    required super.index,
    required super.size,
    required this.totalCount,
  }) : assert(totalCount >= 0, 'totalCount must be greater than or equal to 0');

  /// 创建首页分页器（默认页码 [index] 为 1）
  Page.first({
    required super.data,
    required super.size,
    required this.totalCount,
  })  : assert(totalCount >= 0, 'totalCount must be greater than or equal to 0'),
        super(index: 1);

  /// 通过 [PageKey] 创建基于总条数的分页器
  Page.fromPageKey({
    required super.data,
    required PageKey key,
    required this.totalCount,
  }) : super(index: key.index, size: key.size);

  @override
  bool get hasNext => index * size < totalCount;

  @override
  Page<T> generateNextPage(
      List<T> nextData, {
        int? size,
        int? totalCount,
      }) =>
      Page(data: nextData, index: index + 1, size: size ?? this.size, totalCount: totalCount ?? this.totalCount);
}

/// 基于自定义键/游标（[Key]）的分页器实现
class KPage<T, Key> extends BasePager<T, Key, KPage<T, Key>> {
  @override
  final List<T> data;

  @override
  final bool hasPrevious;

  @override
  final bool hasNext;

  @override
  final Key nextPageKey;

  /// 创建自定义键/游标分页器
  KPage({
    required this.data,
    required this.hasPrevious,
    required this.hasNext,
    required this.nextPageKey,
  });

  /// 创建首页自定义键/游标分页器（默认 [hasPrevious] 为 false）
  KPage.first({
    required this.data,
    required this.hasNext,
    required this.nextPageKey,
  }) : hasPrevious = false;

  @override
  KPage<T, Key> generateNextPage(List<T> nextData, {bool hasNext = true, Key? nextPageKey}) {
    return KPage(data: nextData, hasPrevious: true, hasNext: hasNext, nextPageKey: nextPageKey as Key);
  }
}
