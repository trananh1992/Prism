import 'package:Prism/data/wallhaven/provider/wallhavenWithoutProvider.dart'
    as WData;
import 'package:Prism/global/categoryProvider.dart';
import 'package:Prism/routes/routing_constants.dart';
import 'package:Prism/theme/themeModel.dart';
import 'package:Prism/ui/widgets/animated/loader.dart';
import 'package:Prism/ui/widgets/focussedMenu/focusedMenu.dart';
import 'package:Prism/ui/widgets/home/core/inheritedScrollControllerProvider.dart';
import 'package:Prism/data/share/createDynamicLink.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:Prism/global/globals.dart' as globals;

class WallHavenGrid extends StatefulWidget {
  final String provider;
  WallHavenGrid({@required this.provider});
  @override
  _WallHavenGridState createState() => _WallHavenGridState();
}

class _WallHavenGridState extends State<WallHavenGrid>
    with TickerProviderStateMixin {
  AnimationController _controller;
  AnimationController shakeController;
  Animation<Color> animation;
  int longTapIndex;
  int _current = 0;
  var refreshHomeKey = GlobalKey<RefreshIndicatorState>();

  bool seeMoreLoader = false;
  @override
  void initState() {
    super.initState();
    shakeController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    animation = Provider.of<ThemeModel>(context, listen: false).returnTheme() ==
            ThemeType.Dark
        ? TweenSequence<Color>(
            [
              TweenSequenceItem(
                weight: 1.0,
                tween: ColorTween(
                  begin: Colors.white10,
                  end: Color(0x22FFFFFF),
                ),
              ),
              TweenSequenceItem(
                weight: 1.0,
                tween: ColorTween(
                  begin: Color(0x22FFFFFF),
                  end: Colors.white10,
                ),
              ),
            ],
          ).animate(_controller)
        : TweenSequence<Color>(
            [
              TweenSequenceItem(
                weight: 1.0,
                tween: ColorTween(
                  begin: Colors.black.withOpacity(.1),
                  end: Colors.black.withOpacity(.14),
                ),
              ),
              TweenSequenceItem(
                weight: 1.0,
                tween: ColorTween(
                  begin: Colors.black.withOpacity(.14),
                  end: Colors.black.withOpacity(.1),
                ),
              ),
            ],
          ).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
    _controller.repeat();
  }

  @override
  dispose() {
    _controller?.dispose();
    shakeController.dispose();
    super.dispose();
  }

  Future<Null> refreshList() async {
    refreshHomeKey.currentState?.show(atTop: true);
    await Future.delayed(Duration(milliseconds: 500));
    WData.walls = [];
    Provider.of<CategorySupplier>(context, listen: false).changeWallpaperFuture(
        Provider.of<CategorySupplier>(context, listen: false).selectedChoice,
        "r");
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final Animation<double> offsetAnimation = Tween(begin: 0.0, end: 8.0)
        .chain(CurveTween(curve: Curves.easeOutCubic))
        .animate(shakeController)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              shakeController.reverse();
            }
          });
    final ScrollController controller =
        InheritedDataProvider.of(context).scrollController;
    final CarouselController carouselController = CarouselController();
    return NestedScrollView(
      controller: controller,
      headerSliverBuilder: (context, innerBoxIsScrolled) => <Widget>[
        SliverAppBar(
          backgroundColor: Theme.of(context).primaryColor,
          automaticallyImplyLeading: false,
          pinned: false,
          titleSpacing: 0,
          expandedHeight: 200,
          flexibleSpace: SizedBox(
            child: Stack(
              alignment: AlignmentDirectional.bottomEnd,
              children: <Widget>[
                CarouselSlider.builder(
                  carouselController: carouselController,
                  itemCount: 5,
                  options: CarouselOptions(
                      pauseAutoPlayOnTouch: true,
                      height: 200,
                      viewportFraction: 0.8,
                      initialPage: 0,
                      enableInfiniteScroll: true,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 3),
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      scrollDirection: Axis.horizontal,
                      onPageChanged: (index, reason) {
                        if (mounted)
                          setState(() {
                            _current = index;
                          });
                      }),
                  itemBuilder: (BuildContext context, int i) => i == 4
                      ? Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.fromLTRB(5, 1, 5, 7),
                          child: GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: animation.value,
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                      image: CachedNetworkImageProvider(
                                          "https://unblast.com/wp-content/uploads/2018/08/Gradient-Mesh-21.jpg"),
                                      fit: BoxFit.cover)),
                              child: Center(
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.black.withOpacity(0.4),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      "FOLLOW US ON TWITTER",
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline2
                                          .copyWith(
                                              fontSize: 20,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            onTap: () {
                              launch("https://twitter.com/PrismWallpapers");
                            },
                          ),
                        )
                      : Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.fromLTRB(5, 1, 5, 7),
                          child: GestureDetector(
                            child: Padding(
                              padding: i == longTapIndex
                                  ? EdgeInsets.symmetric(
                                      vertical: offsetAnimation.value / 2,
                                      horizontal: offsetAnimation.value)
                                  : EdgeInsets.all(0),
                              child: WData.walls.length == 0
                                  ? Container(
                                      decoration: BoxDecoration(
                                        color: animation.value,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                          color: animation.value,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          image: DecorationImage(
                                              image: CachedNetworkImageProvider(
                                                  WData.walls[i]
                                                      .thumbs["original"]),
                                              fit: BoxFit.cover)),
                                      child: Center(
                                        child: Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          color: Colors.black.withOpacity(0.4),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              globals.topTitleText[i],
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline2
                                                  .copyWith(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                            onTap: () {
                              if (WData.walls == []) {
                              } else {
                                Navigator.pushNamed(context, WallpaperRoute,
                                    arguments: [
                                      widget.provider,
                                      i,
                                      WData.walls[i].thumbs["small"],
                                    ]);
                              }
                            },
                            onLongPress: () {
                              setState(() {
                                longTapIndex = i;
                              });
                              shakeController.forward(from: 0.0);
                              if (WData.walls == []) {
                              } else {
                                HapticFeedback.vibrate();
                                createDynamicLink(
                                    WData.walls[i].id,
                                    widget.provider,
                                    WData.walls[i].path,
                                    WData.walls[i].thumbs["original"]);
                              }
                            },
                          ),
                        ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [0, 1, 2, 3, 4].map((i) {
                        return Container(
                          width: 8.0,
                          height: 8.0,
                          margin: EdgeInsets.symmetric(
                              vertical: 14.0, horizontal: 2.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _current == i
                                ? Color(0xFFFFFFFF)
                                : Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.4),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      body: RefreshIndicator(
        backgroundColor: Theme.of(context).primaryColor,
        key: refreshHomeKey,
        onRefresh: refreshList,
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels ==
                scrollInfo.metrics.maxScrollExtent) {
              if (!seeMoreLoader) {
                Provider.of<CategorySupplier>(context, listen: false)
                    .changeWallpaperFuture(
                        Provider.of<CategorySupplier>(context, listen: false)
                            .selectedChoice,
                        "s");

                setState(() {
                  seeMoreLoader = true;
                  Future.delayed(Duration(seconds: 4))
                      .then((value) => seeMoreLoader = false);
                });
              }
            }
            return false;
          },
          child: GridView.builder(
            padding: EdgeInsets.fromLTRB(5, 0, 5, 4),
            itemCount: WData.walls.length == 0 ? 20 : WData.walls.length - 4,
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? 300
                        : 250,
                childAspectRatio: 0.6625,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8),
            itemBuilder: (context, index) {
              index = index + 4;
              if (index == WData.walls.length - 1) {
                return FlatButton(
                    color: Provider.of<ThemeModel>(context, listen: false)
                                .returnTheme() ==
                            ThemeType.Dark
                        ? Colors.white10
                        : Colors.black.withOpacity(.1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    onPressed: () {
                      if (!seeMoreLoader) {
                        Provider.of<CategorySupplier>(context, listen: false)
                            .changeWallpaperFuture(
                                Provider.of<CategorySupplier>(context,
                                        listen: false)
                                    .selectedChoice,
                                "s");

                        setState(() {
                          seeMoreLoader = true;
                          Future.delayed(Duration(seconds: 4))
                              .then((value) => seeMoreLoader = false);
                        });
                      }
                    },
                    child: !seeMoreLoader ? Text("See more") : Loader());
              }
              return FocusedMenuHolder(
                  provider: widget.provider,
                  index: index,
                  child: AnimatedBuilder(
                      animation: offsetAnimation,
                      builder: (buildContext, child) {
                        if (offsetAnimation.value < 0.0)
                          print('${offsetAnimation.value + 8.0}');
                        return GestureDetector(
                          child: Padding(
                            padding: index == longTapIndex
                                ? EdgeInsets.symmetric(
                                    vertical: offsetAnimation.value / 2,
                                    horizontal: offsetAnimation.value)
                                : EdgeInsets.all(0),
                            child: Container(
                              decoration: WData.walls.length == 0
                                  ? BoxDecoration(
                                      color: animation.value,
                                      borderRadius: BorderRadius.circular(20),
                                    )
                                  : BoxDecoration(
                                      color: animation.value,
                                      borderRadius: BorderRadius.circular(20),
                                      image: DecorationImage(
                                          image: CachedNetworkImageProvider(
                                              WData.walls[index]
                                                  .thumbs["original"]),
                                          fit: BoxFit.cover)),
                            ),
                          ),
                          onTap: () {
                            if (WData.walls == []) {
                            } else {
                              Navigator.pushNamed(context, WallpaperRoute,
                                  arguments: [
                                    widget.provider,
                                    index,
                                    WData.walls[index].thumbs["small"],
                                  ]);
                            }
                          },
                          onLongPress: () {
                            setState(() {
                              longTapIndex = index;
                            });
                            shakeController.forward(from: 0.0);
                            if (WData.walls == []) {
                            } else {
                              HapticFeedback.vibrate();
                              createDynamicLink(
                                  WData.walls[index].id,
                                  widget.provider,
                                  WData.walls[index].path,
                                  WData.walls[index].thumbs["original"]);
                            }
                          },
                        );
                      }));
            },
          ),
        ),
      ),
    );
  }
}
