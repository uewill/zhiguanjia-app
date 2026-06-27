import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 性能优化工具类
class PerformanceUtils {
  
  /// 防抖动处理
  static Function debounce(Function func, Duration duration) {
    Timer? timer;
    return () {
      timer?.cancel();
      timer = Timer(duration, () => func());
    };
  }

  /// 节流处理
  static Function throttle(Function func, Duration duration) {
    bool canRun = true;
    return () {
      if (canRun) {
        canRun = false;
        func();
        Future.delayed(duration, () => canRun = true);
      }
    };
  }
}

/// 列表项缓存控件 - 避免重复构建
class CachedListItem extends StatefulWidget {
  final String id;
  final Widget child;
  final bool shouldUpdate;

  const CachedListItem({
    Key? key,
    required this.id,
    required this.child,
    this.shouldUpdate = false,
  }) : super(key: key);

  @override
  State<CachedListItem> createState() => _CachedListItemState();
}

class _CachedListItemState extends State<CachedListItem> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  bool shouldRebuild(covariant CachedListItem oldWidget) {
    return widget.shouldUpdate || oldWidget.id != widget.id;
  }
}

/// 图片慢加载缓存
class LazyImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;

  const LazyImage({
    Key? key,
    this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return placeholder ?? Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Icon(Icons.image, color: Colors.grey),
      );
    }

    return Image.network(
      url!,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: width != null ? (width! * 2).toInt() : null,
      cacheHeight: height != null ? (height! * 2).toInt() : null,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return placeholder ?? Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      },
    );
  }
}

/// 游标停止管理器 - 管理列表滚动状态
class ScrollStateController extends GetxController {
  final RxBool _isScrolling = false.obs;
  Timer? _scrollStopTimer;

  bool get isScrolling => _isScrolling.value;

  void onScrollStart() {
    _isScrolling.value = true;
    _scrollStopTimer?.cancel();
  }
  
  void onScrollEnd() {
    _scrollStopTimer?.cancel();
    _scrollStopTimer = Timer(const Duration(milliseconds: 150), () {
      _isScrolling.value = false;
    });
  }

  @override
  void onClose() {
    _scrollStopTimer?.cancel();
    super.onClose();
  }
}
