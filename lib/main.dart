import 'dart:math';
import 'package:flutter/material.dart';
import 'page1.dart';
import 'page2.dart';
import 'page3.dart';
import 'shop/shop_scroll_coordinator.dart';

import 'shop/shop_scroll_controller.dart';

void main() => runApp(MyApp());
MediaQueryData mediaQuery;
double statusBarHeight;
double screenHeight;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShopScroll',
      home: ShopPage(),
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}

class ShopPage extends StatefulWidget {
  ShopPage({Key key}) : super(key: key);

  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage>
    with SingleTickerProviderStateMixin {
  ///页面滑动协调器
  ShopScrollCoordinator _shopCoordinator;
  ShopScrollController _pageScrollController;

  TabController _tabController;

  final double _sliverAppBarInitHeight = 200;
  final double _tabBarHeight = 56;
  double _sliverAppBarMaxHeight;

  @override
  void initState() {
    super.initState();
    _shopCoordinator = ShopScrollCoordinator();
    _tabController = TabController(vsync: this, length: 3);
  }

  @override
  Widget build(BuildContext context) {
    mediaQuery ??= MediaQuery.of(context);
    screenHeight ??= mediaQuery.size.height;
    statusBarHeight ??= mediaQuery.padding.top;

    _sliverAppBarMaxHeight ??= screenHeight;
    _pageScrollController ??= _shopCoordinator
        .pageScrollController(_sliverAppBarMaxHeight - _sliverAppBarInitHeight);

    _shopCoordinator.pinnedHeaderSliverHeightBuilder ??= () {
      return statusBarHeight + kToolbarHeight + _tabBarHeight;
    };
    return Scaffold(
      body: Listener(
        onPointerUp: _shopCoordinator.onPointerUp,
        child: CustomScrollView(
          controller: _pageScrollController,
          physics: ClampingScrollPhysics(),
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              title: Text("店铺首页", style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.blue,
              expandedHeight: _sliverAppBarMaxHeight,
            ),
            SliverPersistentHeader(
              pinned: true,
              floating: false,
              delegate: _SliverAppBarDelegate(
                maxHeight: _tabBarHeight,
                minHeight: _tabBarHeight,
                tabController: _tabController,
              ),
            ),
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  Page1(shopCoordinator: _shopCoordinator),
                  Page2(shopCoordinator: _shopCoordinator),
                  Page3(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _pageScrollController?.dispose();
    super.dispose();
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    this.tabController,
  });

  final double minHeight;
  final double maxHeight;
  TabController tabController;

  @override
  double get minExtent => this.minHeight;

  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    print('shrinkOffset: $shrinkOffset');
    print('overlapsContent: $overlapsContent');
    return Container(
      height: this.minExtent,
      color: Colors.white,
      child: _CustomTabBar(
        height: this.maxExtent,
        overlapsContent: overlapsContent,
        tabController: tabController,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return true;
  }
}

class _CustomTabBar extends StatefulWidget {

  _CustomTabBar({
    Key key,
    this.height,
    this.overlapsContent,
    this.tabController,
  });

  final double height;
  final bool overlapsContent;
  final TabController tabController;

  @override
  State<StatefulWidget> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<_CustomTabBar> {

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      color: widget.overlapsContent ? Colors.white : Colors.transparent,
      child: TabBar(
        controller: widget.tabController,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            width: widget.overlapsContent ? 3.5 : 0.0,
            color: widget.overlapsContent ? Colors.indigoAccent : Colors.transparent,
          )
        ),
        isScrollable: false,
        tabs: [
          {"title": "商品", "subtitle": "subtitle1"},
          {"title": "评价", "subtitle": "subtitle2"},
          {"title": "商家", "subtitle": "subtitle3"},
        ].map((item) => Tab(
          child: Container(
            height: widget.height,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Center(
                    child: Text(item["title"], style: TextStyle(fontSize: 18.0, color: Colors.red),),
                  ),
                ),
                Offstage(
                  offstage: widget.overlapsContent,
                  child: SizedBox(
                    height: 18,
                    child: Center(
                      child: Text(item["subtitle"], style: TextStyle(fontSize: 10.0, color: Colors.orange),),
                    ),
                  ),
                )
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }
}


