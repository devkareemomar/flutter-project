import 'package:admob_flutter/admob_flutter.dart';
import 'package:fluttermultistoreflutter/config/ps_colors.dart';
import 'package:fluttermultistoreflutter/config/ps_config.dart';
import 'package:fluttermultistoreflutter/constant/ps_constants.dart';
import 'package:fluttermultistoreflutter/provider/category/trending_category_provider.dart';
import 'package:fluttermultistoreflutter/provider/product/discount_product_provider.dart';
import 'package:fluttermultistoreflutter/provider/product/feature_product_provider.dart';
import 'package:fluttermultistoreflutter/provider/product/search_product_provider.dart';
import 'package:fluttermultistoreflutter/provider/product/trending_product_provider.dart';
import 'package:fluttermultistoreflutter/provider/productcollection/product_collection_provider.dart';
import 'package:fluttermultistoreflutter/provider/shop_info/shop_info_provider.dart';
import 'package:fluttermultistoreflutter/repository/product_collection_repository.dart';
import 'package:fluttermultistoreflutter/repository/shop_info_repository.dart';
import 'package:fluttermultistoreflutter/ui/category/item/category_horizontal_list_item.dart';
import 'package:fluttermultistoreflutter/ui/category/item/category_horizontal_trending_list_item.dart';
import 'package:fluttermultistoreflutter/ui/common/ps_admob_banner_widget.dart';
import 'package:fluttermultistoreflutter/ui/common/ps_frame_loading_widget.dart';
import 'package:fluttermultistoreflutter/ui/product/collection_product/product_list_by_collection_id_view.dart';
import 'package:fluttermultistoreflutter/ui/product/item/product_horizontal_list_item.dart';
import 'package:fluttermultistoreflutter/ui/product_dashboard/product_home/collection_product_slider.dart';
import 'package:fluttermultistoreflutter/utils/utils.dart';
import 'package:fluttermultistoreflutter/viewobject/common/ps_value_holder.dart';
import 'package:fluttermultistoreflutter/viewobject/holder/intent_holder/product_detail_intent_holder.dart';
import 'package:fluttermultistoreflutter/viewobject/holder/intent_holder/product_list_intent_holder.dart';
import 'package:fluttermultistoreflutter/viewobject/holder/product_parameter_holder.dart';
import 'package:fluttermultistoreflutter/viewobject/holder/touch_count_parameter_holder.dart';
import 'package:fluttermultistoreflutter/viewobject/product.dart';
import 'package:fluttermultistoreflutter/viewobject/product_collection_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fluttermultistoreflutter/api/common/ps_status.dart';
import 'package:fluttermultistoreflutter/constant/ps_dimens.dart';
import 'package:fluttermultistoreflutter/constant/route_paths.dart';
import 'package:fluttermultistoreflutter/provider/category/category_provider.dart';
import 'package:fluttermultistoreflutter/repository/category_repository.dart';
import 'package:fluttermultistoreflutter/repository/product_repository.dart';

class ProductHomeDashboardViewWidget extends StatefulWidget {
  const ProductHomeDashboardViewWidget(
    this._scrollController,
    this.animationController,
    this.context,
    this.shopId,
  );
  final ScrollController _scrollController;
  final AnimationController animationController;
  final BuildContext context;
  final String shopId;

  @override
  _ProductHomeDashboardViewWidgetState createState() =>
      _ProductHomeDashboardViewWidgetState();
}

class _ProductHomeDashboardViewWidgetState
    extends State<ProductHomeDashboardViewWidget> {
  PsValueHolder valueHolder;
  CategoryRepository repo1;
  ProductRepository repo2;
  ProductCollectionRepository repo3;
  ShopInfoRepository shopInfoRepository;

  CategoryProvider _categoryProvider;
  final int count = 8;

  @override
  void initState() {
    super.initState();
    if (_categoryProvider != null) {
      _categoryProvider
          .loadCategoryList(_categoryProvider.latestCategoryParameterHolder);
    }

    widget._scrollController.addListener(() {
      if (widget._scrollController.position.pixels ==
          widget._scrollController.position.maxScrollExtent) {
        _categoryProvider
            .nextCategoryList(_categoryProvider.latestCategoryParameterHolder);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    repo1 = Provider.of<CategoryRepository>(context);
    repo2 = Provider.of<ProductRepository>(context);
    repo3 = Provider.of<ProductCollectionRepository>(context);
    shopInfoRepository = Provider.of<ShopInfoRepository>(context);

    valueHolder = Provider.of<PsValueHolder>(context);

    return MultiProvider(
        providers: <SingleChildWidget>[
          ChangeNotifierProvider<ShopInfoProvider>(
              lazy: false,
              create: (BuildContext context) {
                final ShopInfoProvider provider = ShopInfoProvider(
                    repo: shopInfoRepository,
                    psValueHolder: valueHolder,
                    ownerCode: 'ProductHomeDashboardViewWidget');
                provider.loadShopInfo(widget.shopId);
                return provider;
              }),
          ChangeNotifierProvider<CategoryProvider>(
              lazy: false,
              create: (BuildContext context) {
                _categoryProvider ??= CategoryProvider(
                    repo: repo1,
                    psValueHolder: valueHolder,
                    limit: PsConfig.CATEGORY_LOADING_LIMIT);
                _categoryProvider.latestCategoryParameterHolder.shopId =
                    widget.shopId;
                _categoryProvider.loadCategoryList(
                    _categoryProvider.latestCategoryParameterHolder);
                return _categoryProvider;
              }),
          ChangeNotifierProvider<TrendingCategoryProvider>(
              lazy: false,
              create: (BuildContext context) {
                final TrendingCategoryProvider provider =
                    TrendingCategoryProvider(
                        repo: repo1,
                        psValueHolder: valueHolder,
                        limit: PsConfig.TRENDING_PRODUCT_LOADING_LIMIT);
                provider.trendingCategoryParameterHolder.shopId = widget.shopId;
                provider.loadTrendingCategoryList(
                    provider.trendingCategoryParameterHolder);
                return provider;
              }),
          ChangeNotifierProvider<SearchProductProvider>(
              lazy: false,
              create: (BuildContext context) {
                final SearchProductProvider provider = SearchProductProvider(
                    repo: repo2, limit: PsConfig.LATEST_PRODUCT_LOADING_LIMIT);
                provider.latestProductParameterHolder.shopId = widget.shopId;
                provider.loadProductListByKey(
                    provider.latestProductParameterHolder);
                return provider;
              }),
          ChangeNotifierProvider<DiscountProductProvider>(
              lazy: false,
              create: (BuildContext context) {
                final DiscountProductProvider provider =
                    DiscountProductProvider(
                        repo: repo2,
                        limit: PsConfig.DISCOUNT_PRODUCT_LOADING_LIMIT);
                provider.discountProductParameterHolder.shopId = widget.shopId;
                provider
                    .loadProductList(provider.discountProductParameterHolder);
                return provider;
              }),
          ChangeNotifierProvider<TrendingProductProvider>(
              lazy: false,
              create: (BuildContext context) {
                final TrendingProductProvider provider =
                    TrendingProductProvider(
                        repo: repo2,
                        limit: PsConfig.TRENDING_PRODUCT_LOADING_LIMIT);
                provider.trendingProductParameterHolder.shopId = widget.shopId;
                provider
                    .loadProductList(provider.trendingProductParameterHolder);
                return provider;
              }),
          ChangeNotifierProvider<FeaturedProductProvider>(
              lazy: false,
              create: (BuildContext context) {
                final FeaturedProductProvider provider =
                    FeaturedProductProvider(
                        repo: repo2,
                        limit: PsConfig.FEATURE_PRODUCT_LOADING_LIMIT);
                provider.featuredProductParameterHolder.shopId = widget.shopId;
                provider
                    .loadProductList(provider.featuredProductParameterHolder);
                return provider;
              }),
          ChangeNotifierProvider<ProductCollectionProvider>(
              lazy: false,
              create: (BuildContext context) {
                final ProductCollectionProvider provider =
                    ProductCollectionProvider(
                        repo: repo3,
                        psValueHolder: valueHolder,
                        limit: PsConfig.COLLECTION_PRODUCT_LOADING_LIMIT);
                provider.loadProductCollectionList(widget.shopId);
                return provider;
              }),
        ],
        child: Container(
          color: PsColors.coreBackgroundColor,
          child: CustomScrollView(
            scrollDirection: Axis.vertical,
            slivers: <Widget>[
              _HomeCollectionProductSliderListWidget(
                animationController:
                    widget.animationController, //animationController,
                animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                        parent: widget.animationController,
                        curve: Interval((1 / count) * 1, 1.0,
                            curve: Curves.fastOutSlowIn))), //animation
              ),

              ///
              /// category List Widget
              ///
              _HomeCategoryHorizontalListWidget(
                psValueHolder: valueHolder,
                animationController:
                    widget.animationController, //animationController,
                animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                        parent: widget.animationController,
                        curve: Interval((1 / count) * 2, 1.0,
                            curve: Curves.fastOutSlowIn))), //animation
              ),

              _DiscountProductHorizontalListWidget(
                animationController:
                    widget.animationController, //animationController,
                animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                        parent: widget.animationController,
                        curve: Interval((1 / count) * 3, 1.0,
                            curve: Curves.fastOutSlowIn))), //animation
              ),

              _HomeFeaturedProductHorizontalListWidget(
                animationController:
                    widget.animationController, //animationController,
                animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                        parent: widget.animationController,
                        curve: Interval((1 / count) * 4, 1.0,
                            curve: Curves.fastOutSlowIn))), //animation
              ),
              _HomeSelectingProductTypeWidget(
                animationController:
                    widget.animationController, //animationController,
                animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                        parent: widget.animationController,
                        curve: Interval((1 / count) * 5, 1.0,
                            curve: Curves.fastOutSlowIn))),
              ),
              _HomeTrendingCategoryHorizontalListWidget(
                psValueHolder: valueHolder,
                animationController:
                    widget.animationController, //animationController,
                animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                        parent: widget.animationController,
                        curve: Interval((1 / count) * 6, 1.0,
                            curve: Curves.fastOutSlowIn))), //animation
              ),

              _HomeLatestProductHorizontalListWidget(
                animationController:
                    widget.animationController, //animationController,
                animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                        parent: widget.animationController,
                        curve: Interval((1 / count) * 7, 1.0,
                            curve: Curves.fastOutSlowIn))), //animation
              ),

              _HomeTrendingProductHorizontalListWidget(
                animationController:
                    widget.animationController, //animationController,
                animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                        parent: widget.animationController,
                        curve: Interval((1 / count) * 4, 1.0,
                            curve: Curves.fastOutSlowIn))), //animation
              ),
            ],
          ),
        ));
  }
}

class _HomeLatestProductHorizontalListWidget extends StatelessWidget {
  const _HomeLatestProductHorizontalListWidget({
    Key key,
    @required this.animationController,
    @required this.animation,
  }) : super(key: key);

  final AnimationController animationController;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Consumer<SearchProductProvider>(
        builder: (BuildContext context, SearchProductProvider productProvider,
            Widget child) {
          return AnimatedBuilder(
              animation: animationController,
              builder: (BuildContext context, Widget child) {
                return FadeTransition(
                  opacity: animation,
                  child: Transform(
                    transform: Matrix4.translationValues(
                        0.0, 100 * (1.0 - animation.value), 0.0),
                    child: (productProvider.productList.data != null &&
                            productProvider.productList.data.isNotEmpty)
                        ? Column(children: <Widget>[
                            _MyHeaderWidget(
                              headerName: Utils.getString(
                                  context, 'dashboard__latest_product'),
                              viewAllClicked: () {
                                Navigator.pushNamed(
                                    context, RoutePaths.filterProductList,
                                    arguments: ProductListIntentHolder(
                                      appBarTitle: Utils.getString(
                                          context, 'dashboard__latest_product'),
                                      productParameterHolder:
                                          ProductParameterHolder()
                                              .getLatestParameterHolder(),
                                    ));
                              },
                            ),
                            Container(
                                height: PsDimens.space300,
                                width: MediaQuery.of(context).size.width,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.only(
                                        left: PsDimens.space16),
                                    itemCount:
                                        productProvider.productList.data.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      if (productProvider.productList.status ==
                                          PsStatus.BLOCK_LOADING) {
                                        return Shimmer.fromColors(
                                            baseColor: PsColors.grey,
                                            highlightColor: PsColors.white,
                                            child: Row(children: const <Widget>[
                                              PsFrameUIForLoading(),
                                            ]));
                                      } else {
                                        final Product product = productProvider
                                            .productList.data[index];
                                        return ProductHorizontalListItem(
                                          coreTagKey: productProvider.hashCode
                                                  .toString() +
                                              product.id,
                                          product: productProvider
                                              .productList.data[index],
                                          onTap: () async {
                                            print(product.defaultPhoto.imgPath);

                                            final ProductDetailIntentHolder
                                                holder =
                                                ProductDetailIntentHolder(
                                              product: product,
                                              heroTagImage: productProvider
                                                      .hashCode
                                                      .toString() +
                                                  product.id +
                                                  PsConst.HERO_TAG__IMAGE,
                                              heroTagTitle: productProvider
                                                      .hashCode
                                                      .toString() +
                                                  product.id +
                                                  PsConst.HERO_TAG__TITLE,
                                              heroTagOriginalPrice: productProvider
                                                      .hashCode
                                                      .toString() +
                                                  product.id +
                                                  PsConst
                                                      .HERO_TAG__ORIGINAL_PRICE,
                                              heroTagUnitPrice: productProvider
                                                      .hashCode
                                                      .toString() +
                                                  product.id +
                                                  PsConst.HERO_TAG__UNIT_PRICE,
                                            );

                                            final dynamic result =
                                                await Navigator.pushNamed(
                                                    context,
                                                    RoutePaths.productDetail,
                                                    arguments: holder);
                                            if (result == null) {
                                              productProvider.loadProductListByKey(
                                                  ProductParameterHolder()
                                                      .getLatestParameterHolder());
                                            }
                                          },
                                        );
                                      }
                                    }))
                          ])
                        : Container(),
                  ),
                );
              });
        },
      ),
    );
  }
}

class _HomeFeaturedProductHorizontalListWidget extends StatelessWidget {
  const _HomeFeaturedProductHorizontalListWidget({
    Key key,
    @required this.animationController,
    @required this.animation,
  }) : super(key: key);

  final AnimationController animationController;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Consumer<FeaturedProductProvider>(
        builder: (BuildContext context, FeaturedProductProvider productProvider,
            Widget child) {
          return AnimatedBuilder(
            animation: animationController,
            builder: (BuildContext context, Widget child) {
              return FadeTransition(
                opacity: animation,
                child: Transform(
                  transform: Matrix4.translationValues(
                      0.0, 100 * (1.0 - animation.value), 0.0),
                  child: (productProvider.productList.data != null &&
                          productProvider.productList.data.isNotEmpty)
                      ? Column(
                          children: <Widget>[
                            _MyHeaderWidget(
                              headerName: Utils.getString(
                                  context, 'dashboard__feature_product'),
                              viewAllClicked: () {
                                Navigator.pushNamed(
                                    context, RoutePaths.filterProductList,
                                    arguments: ProductListIntentHolder(
                                        appBarTitle: Utils.getString(context,
                                            'dashboard__feature_product'),
                                        productParameterHolder:
                                            ProductParameterHolder()
                                                .getFeaturedParameterHolder()));
                              },
                            ),
                            Container(
                                height: PsDimens.space300,
                                width: MediaQuery.of(context).size.width,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.only(
                                        left: PsDimens.space16),
                                    itemCount:
                                        productProvider.productList.data.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      if (productProvider.productList.status ==
                                          PsStatus.BLOCK_LOADING) {
                                        return Shimmer.fromColors(
                                            baseColor: PsColors.grey,
                                            highlightColor: PsColors.white,
                                            child: Row(children: const <Widget>[
                                              PsFrameUIForLoading(),
                                            ]));
                                      } else {
                                        final Product product = productProvider
                                            .productList.data[index];
                                        return ProductHorizontalListItem(
                                          coreTagKey: productProvider.hashCode
                                                  .toString() +
                                              product.id,
                                          product: productProvider
                                              .productList.data[index],
                                          onTap: () async {
                                            print(productProvider
                                                .productList
                                                .data[index]
                                                .defaultPhoto
                                                .imgPath);
                                            final ProductDetailIntentHolder
                                                holder =
                                                ProductDetailIntentHolder(
                                              product: productProvider
                                                  .productList.data[index],
                                              heroTagImage: productProvider
                                                      .hashCode
                                                      .toString() +
                                                  product.id +
                                                  PsConst.HERO_TAG__IMAGE,
                                              heroTagTitle: productProvider
                                                      .hashCode
                                                      .toString() +
                                                  product.id +
                                                  PsConst.HERO_TAG__TITLE,
                                              heroTagOriginalPrice: productProvider
                                                      .hashCode
                                                      .toString() +
                                                  product.id +
                                                  PsConst
                                                      .HERO_TAG__ORIGINAL_PRICE,
                                              heroTagUnitPrice: productProvider
                                                      .hashCode
                                                      .toString() +
                                                  product.id +
                                                  PsConst.HERO_TAG__UNIT_PRICE,
                                            );

                                            final dynamic result =
                                                await Navigator.pushNamed(
                                                    context,
                                                    RoutePaths.productDetail,
                                                    arguments: holder);
                                            if (result == null) {
                                              productProvider.loadProductList(
                                                  ProductParameterHolder()
                                                      .getFeaturedParameterHolder());
                                            }
                                          },
                                        );
                                      }
                                    }))
                          ],
                        )
                      : Container(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _HomeTrendingProductHorizontalListWidget extends StatelessWidget {
  const _HomeTrendingProductHorizontalListWidget({
    Key key,
    @required this.animationController,
    @required this.animation,
  }) : super(key: key);

  final AnimationController animationController;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Consumer<TrendingProductProvider>(
        builder: (BuildContext context, TrendingProductProvider productProvider,
            Widget child) {
          return AnimatedBuilder(
            animation: animationController,
            builder: (BuildContext context, Widget child) {
              return FadeTransition(
                opacity: animation,
                child: Transform(
                  transform: Matrix4.translationValues(
                      0.0, 100 * (1.0 - animation.value), 0.0),
                  child: (productProvider.productList.data != null &&
                          productProvider.productList.data.isNotEmpty)
                      ? Column(
                          children: <Widget>[
                            _MyHeaderWidget(
                              headerName: Utils.getString(
                                  context, 'dashboard__trending_product'),
                              viewAllClicked: () {
                                Navigator.pushNamed(
                                    context, RoutePaths.filterProductList,
                                    arguments: ProductListIntentHolder(
                                        appBarTitle: Utils.getString(context,
                                            'dashboard__trending_product'),
                                        productParameterHolder:
                                            ProductParameterHolder()
                                                .getTrendingParameterHolder()));
                              },
                            ),
                            Container(
                                height: PsDimens.space300,
                                width: MediaQuery.of(context).size.width,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        productProvider.productList.data.length,
                                    padding: const EdgeInsets.only(
                                        left: PsDimens.space16),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      if (productProvider.productList.status ==
                                          PsStatus.BLOCK_LOADING) {
                                        return Shimmer.fromColors(
                                            baseColor: PsColors.grey,
                                            highlightColor: PsColors.white,
                                            child: Row(children: const <Widget>[
                                              PsFrameUIForLoading(),
                                            ]));
                                      } else {
                                        final Product product = productProvider
                                            .productList.data[index];
                                        return ProductHorizontalListItem(
                                          coreTagKey: productProvider.hashCode
                                                  .toString() +
                                              product.id,
                                          product: productProvider
                                              .productList.data[index],
                                          onTap: () async {
                                            print(productProvider
                                                .productList
                                                .data[index]
                                                .defaultPhoto
                                                .imgPath);
                                            final ProductDetailIntentHolder
                                                holder =
                                                ProductDetailIntentHolder(
                                              product: productProvider
                                                  .productList.data[index],
                                              heroTagImage: productProvider
                                                      .hashCode
                                                      .toString() +
                                                  product.id +
                                                  PsConst.HERO_TAG__IMAGE,
                                              heroTagTitle: productProvider
                                                      .hashCode
                                                      .toString() +
                                                  product.id +
                                                  PsConst.HERO_TAG__TITLE,
                                              heroTagOriginalPrice: productProvider
                                                      .hashCode
                                                      .toString() +
                                                  product.id +
                                                  PsConst
                                                      .HERO_TAG__ORIGINAL_PRICE,
                                              heroTagUnitPrice: productProvider
                                                      .hashCode
                                                      .toString() +
                                                  product.id +
                                                  PsConst.HERO_TAG__UNIT_PRICE,
                                            );
                                            final dynamic result =
                                                await Navigator.pushNamed(
                                                    context,
                                                    RoutePaths.productDetail,
                                                    arguments: holder);
                                            if (result == null) {
                                              productProvider.loadProductList(
                                                  ProductParameterHolder()
                                                      .getTrendingParameterHolder());
                                            }
                                          },
                                        );
                                      }
                                    }))
                          ],
                        )
                      : Container(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _HomeSelectingProductTypeWidget extends StatelessWidget {
  const _HomeSelectingProductTypeWidget({
    Key key,
    @required this.animationController,
    @required this.animation,
  }) : super(key: key);

  final AnimationController animationController;
  final Animation<double> animation;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
          animation: animationController,
          builder: (BuildContext context, Widget child) {
            return FadeTransition(
              opacity: animation,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 100 * (1.0 - animation.value), 0.0),
                child: Container(
                    color: PsColors.backgroundColor,
                    margin: const EdgeInsets.only(top: PsDimens.space20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(
                          height: PsDimens.space28,
                        ),
                        Text(
                            Utils.getString(context, 'dashboard__welcome_text'),
                            style: Theme.of(context).textTheme.bodyText2),
                        const SizedBox(
                          height: PsDimens.space12,
                        ),
                        Text(Utils.getString(context, 'app_name'),
                            style: Theme.of(context)
                                .textTheme
                                .subtitle1
                                .copyWith(color: PsColors.mainColor)),
                        const SizedBox(
                          height: PsDimens.space12,
                        ),
                        Container(
                          color: PsColors.backgroundColor,
                          padding: const EdgeInsets.only(top: PsDimens.space8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: _SelectingImageAndTextWidget(
                                    imagePath: 'assets/images/trending.png',
                                    title: Utils.getString(
                                        context, 'dashboard__popular_product'),
                                    description: Utils.getString(context,
                                        'dashboard__popular_description'),
                                    onTap: () {
                                      print('popular download');
                                      Navigator.pushNamed(
                                          context, RoutePaths.filterProductList,
                                          arguments: ProductListIntentHolder(
                                              appBarTitle: Utils.getString(
                                                  context,
                                                  'dashboard__popular_product'),
                                              productParameterHolder:
                                                  ProductParameterHolder()
                                                      .getTrendingParameterHolder()));
                                    }),
                              ),
                              Expanded(
                                child: _SelectingImageAndTextWidget(
                                    imagePath:
                                        'assets/images/home_icon/easy_payment.png',
                                    title: Utils.getString(
                                        context, 'dashboard__easy_payment'),
                                    description: Utils.getString(context,
                                        'dashboard__easy_payment_description'),
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        RoutePaths.basketList,
                                      );
                                    }),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          color: PsColors.backgroundColor,
                          padding: const EdgeInsets.only(
                              top: PsDimens.space8, bottom: PsDimens.space8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: _SelectingImageAndTextWidget(
                                    imagePath:
                                        'assets/images/home_icon/featured_products.png',
                                    title: Utils.getString(
                                        context, 'dashboard__feature_product'),
                                    description: Utils.getString(context,
                                        'dashboard__feature_product_description'),
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, RoutePaths.filterProductList,
                                          arguments: ProductListIntentHolder(
                                              appBarTitle: Utils.getString(
                                                  context,
                                                  'dashboard__feature_product'),
                                              productParameterHolder:
                                                  ProductParameterHolder()
                                                      .getFeaturedParameterHolder()));
                                    }),
                              ),
                              Expanded(
                                child: _SelectingImageAndTextWidget(
                                    imagePath:
                                        'assets/images/home_icon/discount_products.png',
                                    title: Utils.getString(
                                        context, 'dashboard__discount_product'),
                                    description: Utils.getString(context,
                                        'dashboard__discount_product_description'),
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, RoutePaths.filterProductList,
                                          arguments: ProductListIntentHolder(
                                              appBarTitle: Utils.getString(
                                                  context,
                                                  'dashboard__discount_product'),
                                              productParameterHolder:
                                                  ProductParameterHolder()
                                                      .getDiscountParameterHolder()));
                                    }),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: PsDimens.space12,
                        ),
                      ],
                    )),
              ),
            );
          }),
    );
  }
}

class _SelectingImageAndTextWidget extends StatelessWidget {
  const _SelectingImageAndTextWidget(
      {Key key,
      @required this.imagePath,
      @required this.title,
      @required this.description,
      @required this.onTap})
      : super(key: key);

  final String imagePath;
  final String title;
  final String description;
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(PsDimens.space12),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Image.asset(
                imagePath,
                width: PsDimens.space60,
                height: PsDimens.space60,
              ),
            ),
            const SizedBox(
              height: PsDimens.space12,
            ),
            Text(title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.subtitle1),
            const SizedBox(
              height: PsDimens.space12,
            ),
            Text(description,
                maxLines: 3,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.caption),
          ],
        ),
      ),
    );
  }
}

class _HomeTrendingCategoryHorizontalListWidget extends StatelessWidget {
  const _HomeTrendingCategoryHorizontalListWidget(
      {Key key,
      @required this.animationController,
      @required this.animation,
      @required this.psValueHolder})
      : super(key: key);

  final AnimationController animationController;
  final Animation<double> animation;
  final PsValueHolder psValueHolder;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: Consumer<TrendingCategoryProvider>(builder:
        (BuildContext context,
            TrendingCategoryProvider trendingCategoryProvider, Widget child) {
      return AnimatedBuilder(
        animation: animationController,
        builder: (BuildContext context, Widget child) {
          return FadeTransition(
              opacity: animation,
              child: Transform(
                  transform: Matrix4.translationValues(
                      0.0, 100 * (1.0 - animation.value), 0.0),
                  child: Consumer<TrendingCategoryProvider>(builder:
                      (BuildContext context,
                          TrendingCategoryProvider trendingCategoryProvider,
                          Widget child) {
                    return (trendingCategoryProvider.categoryList.data !=
                                null &&
                            trendingCategoryProvider
                                .categoryList.data.isNotEmpty)
                        ? Column(children: <Widget>[
                            _MyHeaderWidget(
                              headerName: Utils.getString(
                                  context, 'dashboard__trending_category'),
                              viewAllClicked: () {
                                Navigator.pushNamed(
                                    context, RoutePaths.trendingCategoryList,
                                    arguments: Utils.getString(context,
                                        'tranding_category__trending_category_list'));
                              },
                            ),
                            Container(
                              height: PsDimens.space320,
                              margin: const EdgeInsets.only(
                                  top: PsDimens.space12,
                                  bottom: PsDimens.space12,
                                  left: PsDimens.space16),
                              width: MediaQuery.of(context).size.width,
                              child: CustomScrollView(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  slivers: <Widget>[
                                    SliverGrid(
                                      gridDelegate:
                                          const SliverGridDelegateWithMaxCrossAxisExtent(
                                              maxCrossAxisExtent: 200,
                                              childAspectRatio: 0.8),
                                      delegate: SliverChildBuilderDelegate(
                                        (BuildContext context, int index) {
                                          if (trendingCategoryProvider
                                                  .categoryList.status ==
                                              PsStatus.BLOCK_LOADING) {
                                            return Shimmer.fromColors(
                                                baseColor: PsColors.grey,
                                                highlightColor: PsColors.white,
                                                child: Row(
                                                    children: const <Widget>[
                                                      PsFrameUIForLoading(),
                                                    ]));
                                          } else {
                                            if (trendingCategoryProvider
                                                        .categoryList.data !=
                                                    null ||
                                                trendingCategoryProvider
                                                    .categoryList
                                                    .data
                                                    .isNotEmpty) {
                                              return CategoryHorizontalTrendingListItem(
                                                category:
                                                    trendingCategoryProvider
                                                        .categoryList
                                                        .data[index],
                                                animationController:
                                                    animationController,
                                                animation: Tween<double>(
                                                        begin: 0.0, end: 1.0)
                                                    .animate(
                                                  CurvedAnimation(
                                                    parent: animationController,
                                                    curve: Interval(
                                                        (1 /
                                                                trendingCategoryProvider
                                                                    .categoryList
                                                                    .data
                                                                    .length) *
                                                            index,
                                                        1.0,
                                                        curve: Curves
                                                            .fastOutSlowIn),
                                                  ),
                                                ),
                                                onTap: () {
                                                  final String loginUserId =
                                                      Utils.checkUserLoginId(
                                                          psValueHolder);
                                                  final TouchCountParameterHolder
                                                      touchCountParameterHolder =
                                                      TouchCountParameterHolder(
                                                          typeId:
                                                              trendingCategoryProvider
                                                                  .categoryList
                                                                  .data[index]
                                                                  .id,
                                                          typeName: PsConst
                                                              .FILTERING_TYPE_NAME_CATEGORY,
                                                          userId: loginUserId,
                                                          shopId:
                                                              trendingCategoryProvider
                                                                  .categoryList
                                                                  .data[index]
                                                                  .shopId);

                                                  trendingCategoryProvider
                                                      .postTouchCount(
                                                          touchCountParameterHolder
                                                              .toMap());
                                                  print(trendingCategoryProvider
                                                      .categoryList
                                                      .data[index]
                                                      .defaultPhoto
                                                      .imgPath);
                                                  final ProductParameterHolder
                                                      productParameterHolder =
                                                      ProductParameterHolder()
                                                          .getLatestParameterHolder();
                                                  productParameterHolder.catId =
                                                      trendingCategoryProvider
                                                          .categoryList
                                                          .data[index]
                                                          .id;
                                                  Navigator.pushNamed(
                                                      context,
                                                      RoutePaths
                                                          .filterProductList,
                                                      arguments:
                                                          ProductListIntentHolder(
                                                        appBarTitle:
                                                            trendingCategoryProvider
                                                                .categoryList
                                                                .data[index]
                                                                .name,
                                                        productParameterHolder:
                                                            productParameterHolder,
                                                      ));
                                                },
                                              );
                                            } else {
                                              return null;
                                            }
                                          }
                                        },
                                        childCount: trendingCategoryProvider
                                            .categoryList.data.length,
                                      ),
                                    ),
                                  ]),
                            )
                          ])
                        : Container();
                  })));
        },
      );
    }));
  }
}

class _DiscountProductHorizontalListWidget extends StatefulWidget {
  const _DiscountProductHorizontalListWidget({
    Key key,
    @required this.animationController,
    @required this.animation,
  }) : super(key: key);

  final AnimationController animationController;
  final Animation<double> animation;

  @override
  __DiscountProductHorizontalListWidgetState createState() =>
      __DiscountProductHorizontalListWidgetState();
}

class __DiscountProductHorizontalListWidgetState
    extends State<_DiscountProductHorizontalListWidget> {
  bool isConnectedToInternet = false;
  bool isSuccessfullyLoaded = true;

  void checkConnection() {
    Utils.checkInternetConnectivity().then((bool onValue) {
      isConnectedToInternet = onValue;
      if (isConnectedToInternet && PsConst.SHOW_ADMOB) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isConnectedToInternet && PsConst.SHOW_ADMOB) {
      print('loading ads....');
      checkConnection();
    }
    return SliverToBoxAdapter(
        // fdfdf
        child: Consumer<DiscountProductProvider>(builder: (BuildContext context,
            DiscountProductProvider productProvider, Widget child) {
      return AnimatedBuilder(
          animation: widget.animationController,
          builder: (BuildContext context, Widget child) {
            return FadeTransition(
                opacity: widget.animation,
                child: Transform(
                    transform: Matrix4.translationValues(
                        0.0, 100 * (1.0 - widget.animation.value), 0.0),
                    child: (productProvider.productList.data != null &&
                            productProvider.productList.data.isNotEmpty)
                        ? Column(children: <Widget>[
                            _MyHeaderWidget(
                              headerName: Utils.getString(
                                  context, 'dashboard__discount_product'),
                              viewAllClicked: () {
                                Navigator.pushNamed(
                                    context, RoutePaths.filterProductList,
                                    arguments: ProductListIntentHolder(
                                        appBarTitle: Utils.getString(context,
                                            'dashboard__discount_product'),
                                        productParameterHolder:
                                            ProductParameterHolder()
                                                .getDiscountParameterHolder()));
                              },
                            ),
                            Container(
                                height: PsDimens.space320,
                                width: MediaQuery.of(context).size.width,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.only(
                                        left: PsDimens.space16),
                                    itemCount:
                                        productProvider.productList.data.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      if (productProvider.productList.status ==
                                          PsStatus.BLOCK_LOADING) {
                                        return Shimmer.fromColors(
                                            baseColor: PsColors.grey,
                                            highlightColor: PsColors.white,
                                            child: Row(children: const <Widget>[
                                              PsFrameUIForLoading(),
                                            ]));
                                      } else {
                                        final Product product = productProvider
                                            .productList.data[index];
                                        return ProductHorizontalListItem(
                                          coreTagKey: productProvider.hashCode
                                                  .toString() +
                                              product.id,
                                          product: productProvider
                                              .productList.data[index],
                                          onTap: () async {
                                            print(productProvider
                                                .productList
                                                .data[index]
                                                .defaultPhoto
                                                .imgPath);
                                            final ProductDetailIntentHolder
                                                holder =
                                                ProductDetailIntentHolder(
                                              product: productProvider
                                                  .productList.data[index],
                                              heroTagImage: productProvider
                                                      .hashCode
                                                      .toString() +
                                                  product.id +
                                                  PsConst.HERO_TAG__IMAGE,
                                              heroTagTitle: productProvider
                                                      .hashCode
                                                      .toString() +
                                                  product.id +
                                                  PsConst.HERO_TAG__TITLE,
                                              heroTagOriginalPrice: productProvider
                                                      .hashCode
                                                      .toString() +
                                                  product.id +
                                                  PsConst
                                                      .HERO_TAG__ORIGINAL_PRICE,
                                              heroTagUnitPrice: productProvider
                                                      .hashCode
                                                      .toString() +
                                                  product.id +
                                                  PsConst.HERO_TAG__UNIT_PRICE,
                                            );
                                            final dynamic result =
                                                await Navigator.pushNamed(
                                                    context,
                                                    RoutePaths.productDetail,
                                                    arguments: holder);
                                            if (result == null) {
                                              productProvider.loadProductList(
                                                  ProductParameterHolder()
                                                      .getDiscountParameterHolder());
                                            }
                                          },
                                        );
                                      }
                                    })),
                            const PsAdMobBannerWidget(
                              admobBannerSize: AdmobBannerSize.MEDIUM_RECTANGLE,
                            ),
                            // Visibility(
                            //   visible: PsConst.SHOW_ADMOB &&
                            //       isSuccessfullyLoaded &&
                            //       isConnectedToInternet,
                            //   child: AdmobBanner(
                            //     adUnitId: Utils.getBannerAdUnitId(),
                            //     adSize: AdmobBannerSize.MEDIUM_RECTANGLE,
                            //     listener: (AdmobAdEvent event,
                            //         Map<String, dynamic> map) {
                            //       print('BannerAd event is $event');
                            //       if (event == AdmobAdEvent.loaded) {
                            //         isSuccessfullyLoaded = true;
                            //       } else {
                            //         isSuccessfullyLoaded = false;
                            //         setState(() {});
                            //       }
                            //     },
                            //   ),
                            // ),
                          ])
                        : Container()));
          });
    }));
  }
}

class _HomeCollectionProductSliderListWidget extends StatelessWidget {
  const _HomeCollectionProductSliderListWidget({
    Key key,
    @required this.animationController,
    @required this.animation,
  }) : super(key: key);

  final AnimationController animationController;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    const int count = 6;
    final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(
            parent: animationController,
            curve: const Interval((1 / count) * 1, 1.0,
                curve: Curves.fastOutSlowIn)));

    return SliverToBoxAdapter(
      child: Consumer<ProductCollectionProvider>(builder: (BuildContext context,
          ProductCollectionProvider collectionProductProvider, Widget child) {
        return AnimatedBuilder(
            animation: animationController,
            builder: (BuildContext context, Widget child) {
              return FadeTransition(
                  opacity: animation,
                  child: Transform(
                      transform: Matrix4.translationValues(
                          0.0, 100 * (1.0 - animation.value), 0.0),
                      child: (collectionProductProvider
                                      .productCollectionList.data !=
                                  null &&
                              collectionProductProvider
                                  .productCollectionList.data.isNotEmpty)
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                _MyHeaderWidget(
                                  headerName: Utils.getString(
                                      context, 'dashboard__collection_product'),
                                  viewAllClicked: () {
                                    Navigator.pushNamed(
                                      context,
                                      RoutePaths.collectionProductList,
                                    );
                                  },
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                          color: PsColors.mainLightShadowColor,
                                          offset: const Offset(1.1, 1.1),
                                          blurRadius: PsDimens.space8),
                                    ],
                                  ),
                                  margin: const EdgeInsets.only(
                                      top: PsDimens.space8,
                                      bottom: PsDimens.space20),
                                  width: double.infinity,
                                  child: CollectionProductSliderView(
                                    collectionProductList:
                                        collectionProductProvider
                                            .productCollectionList.data,
                                    onTap: (ProductCollectionHeader
                                        collectionProduct) {
                                      Navigator.pushNamed(context,
                                          RoutePaths.productListByCollectionId,
                                          arguments:
                                              ProductListByCollectionIdView(
                                            productCollectionHeader:
                                                collectionProduct,
                                            appBarTitle: collectionProduct.name,
                                          ));
                                    },
                                  ),
                                )
                              ],
                            )
                          : Container()));
            });
      }),
    );
  }
}

class _HomeCategoryHorizontalListWidget extends StatefulWidget {
  const _HomeCategoryHorizontalListWidget(
      {Key key,
      @required this.animationController,
      @required this.animation,
      @required this.psValueHolder})
      : super(key: key);

  final AnimationController animationController;
  final Animation<double> animation;
  final PsValueHolder psValueHolder;

  @override
  __HomeCategoryHorizontalListWidgetState createState() =>
      __HomeCategoryHorizontalListWidgetState();
}

class __HomeCategoryHorizontalListWidgetState
    extends State<_HomeCategoryHorizontalListWidget> {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(child: Consumer<CategoryProvider>(
      builder: (BuildContext context, CategoryProvider categoryProvider,
          Widget child) {
        return AnimatedBuilder(
            animation: widget.animationController,
            builder: (BuildContext context, Widget child) {
              return FadeTransition(
                  opacity: widget.animation,
                  child: Transform(
                      transform: Matrix4.translationValues(
                          0.0, 30 * (1.0 - widget.animation.value), 0.0),
                      child: (categoryProvider.categoryList.data != null &&
                              categoryProvider.categoryList.data.isNotEmpty)
                          ? Column(children: <Widget>[
                              _MyHeaderWidget(
                                headerName: Utils.getString(
                                    context, 'dashboard__categories'),
                                viewAllClicked: () {
                                  Navigator.pushNamed(
                                      context, RoutePaths.categoryList,
                                      arguments: 'Categories');
                                },
                              ),
                              Container(
                                height: PsDimens.space140,
                                width: MediaQuery.of(context).size.width,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    padding: const EdgeInsets.only(
                                        left: PsDimens.space16),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: categoryProvider
                                        .categoryList.data.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      if (categoryProvider
                                              .categoryList.status ==
                                          PsStatus.BLOCK_LOADING) {
                                        return Shimmer.fromColors(
                                            baseColor: PsColors.grey,
                                            highlightColor: PsColors.white,
                                            child: Row(children: const <Widget>[
                                              PsFrameUIForLoading(),
                                            ]));
                                      } else {
                                        return CategoryHorizontalListItem(
                                          category: categoryProvider
                                              .categoryList.data[index],
                                          onTap: () {
                                            final String loginUserId =
                                                Utils.checkUserLoginId(
                                                    widget.psValueHolder);
                                            final TouchCountParameterHolder
                                                touchCountParameterHolder =
                                                TouchCountParameterHolder(
                                                    typeId: categoryProvider
                                                        .categoryList
                                                        .data[index]
                                                        .id,
                                                    typeName: PsConst
                                                        .FILTERING_TYPE_NAME_CATEGORY,
                                                    userId: loginUserId,
                                                    shopId: categoryProvider
                                                        .categoryList
                                                        .data[index]
                                                        .shopId);

                                            categoryProvider.postTouchCount(
                                                touchCountParameterHolder
                                                    .toMap());
                                            print(categoryProvider
                                                .categoryList
                                                .data[index]
                                                .defaultPhoto
                                                .imgPath);
                                            final ProductParameterHolder
                                                productParameterHolder =
                                                ProductParameterHolder()
                                                    .getLatestParameterHolder();
                                            productParameterHolder.catId =
                                                categoryProvider.categoryList
                                                    .data[index].id;
                                            Navigator.pushNamed(context,
                                                RoutePaths.filterProductList,
                                                arguments:
                                                    ProductListIntentHolder(
                                                  appBarTitle: categoryProvider
                                                      .categoryList
                                                      .data[index]
                                                      .name,
                                                  productParameterHolder:
                                                      productParameterHolder,
                                                ));
                                          },
                                          // )
                                        );
                                      }
                                    }),
                              )
                            ])
                          : Container()));
            });
      },
    ));
  }
}

class _MyHeaderWidget extends StatefulWidget {
  const _MyHeaderWidget({
    Key key,
    @required this.headerName,
    this.productCollectionHeader,
    @required this.viewAllClicked,
  }) : super(key: key);

  final String headerName;
  final Function viewAllClicked;
  final ProductCollectionHeader productCollectionHeader;

  @override
  __MyHeaderWidgetState createState() => __MyHeaderWidgetState();
}

class __MyHeaderWidgetState extends State<_MyHeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.viewAllClicked,
      child: Padding(
        padding: const EdgeInsets.only(
            top: PsDimens.space20,
            left: PsDimens.space16,
            right: PsDimens.space16,
            bottom: PsDimens.space10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Text(widget.headerName,
                  style: Theme.of(context).textTheme.headline6.copyWith(
                      fontWeight: FontWeight.bold,
                      color: PsColors.textPrimaryDarkColor)),
            ),
            Text(
              Utils.getString(context, 'dashboard__view_all'),
              textAlign: TextAlign.start,
              style: Theme.of(context)
                  .textTheme
                  .caption
                  .copyWith(color: PsColors.mainColor),
            ),
          ],
        ),
      ),
    );
  }
}
