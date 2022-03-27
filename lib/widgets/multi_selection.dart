import 'dart:ui';

import 'package:flutter/material.dart';

/* 
  * Categories Screen
  * Category Screen
  * Selected Screen
 */

class MultiSelection extends StatefulWidget {
  const MultiSelection({Key? key}) : super(key: key);

  @override
  State<MultiSelection> createState() => _Multi();
}

class _Multi extends State<MultiSelection> with TickerProviderStateMixin {
  late AnimationController selectController;
  late Animation<double> selectAnim;
  double get selectValue => selectAnim.value;

  late AnimationController incrementController;
  late Animation<double> incrementAnim;
  double get incrementValue => incrementAnim.value;

  late AnimationController detailController;
  late Animation<double> detailAnim;
  double get detailValue => detailAnim.value;
  late AnimationController opacityController;

  int selectedIndex = -1;
  int incrementIndex = 0;
  bool opacity = false;

  Matrix4 identity(int index) {
    final width = MediaQuery.of(context).size.width;

    final identity = Matrix4.identity();

    if (index == 0) {
      identity
        ..translate(0.0)
        ..scale(1.0);
    }
    if (index == 1) {
      identity
        ..translate(lerpDouble(
          -width * 0.08,
          lerpDouble(
            -width * 0.1,
            lerpDouble(-width * 0.22, -width * 0.5, detailValue),
            incrementValue,
          ),
          selectValue,
        ))
        ..scale(1.0);
    }
    if (index == 2) {
      identity
        ..translate(lerpDouble(
          -width * 0.16,
          lerpDouble(-width * 0.85, -width - 20.0, detailValue),
          selectValue,
        ))
        ..scale(1.0);
    }

    return identity;
  }

  @override
  void initState() {
    selectController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..addListener(_update);
    selectAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: selectController,
      curve: Curves.easeIn,
    ));

    incrementController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..addListener(_update);
    incrementAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: incrementController,
      curve: Curves.easeIn,
    ));

    detailController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..addListener(_update);
    detailAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: detailController,
      curve: Curves.easeIn,
    ));

    opacityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 100),
    )..addListener(_update);

    super.initState();
  }

  void _update() {
    if (mounted) {
      setState(() {});
    }
  }

  Widget _getChildren(int index) {
    final width = MediaQuery.of(context).size.width;

    List childs = <Widget>[
      SelectedScreen(
        offset: lerpDouble(
            lerpDouble(
              width * .85,
              width * 0.77,
              incrementController.value,
            ),
            width * 0.5,
            detailController.value)!,
        animation: detailController,
        index: incrementIndex,
        animation1: selectController,
        opacity: selectedIndex != -1,
        onClear: () async {
          incrementIndex = 0;
          setState(() {});
          await detailController.reverse();
        },
      ),
      CategoryScreen(
        animation: detailController,
        startOffset: lerpDouble(
          width * 0.25,
          width * 0.3,
          incrementController.value,
        )!,
        endOffset: width * 0.45,
        onSelect: (value) {
          setState(() => incrementIndex++);
          incrementController.forward();
        },
        opacity: selectedIndex != -1,
        update: opacityController.value,
        onBack: () async => await detailController.reverse(),
      ),
      CategoriesScreen(
        animation: selectAnim,
        startOffset: width * 0.16,
        endOffset: width * 0.85,
        onBack: () {
          detailController.reverse();
          incrementController.reverse();
          selectController.reverse();
          selectedIndex = -1;
          setState(() {});
        },
        onSelect: (index) async {
          if (selectedIndex == index) return;
          setState(() {
            selectedIndex = index;
            opacity = true;
          });
          await opacityController.reverse();
          opacityController.forward();
          selectController.forward();
          if (incrementIndex != 0) {
            incrementController.forward();
          }
        },
        selectedIndex: selectedIndex,
      ),
    ];
    return childs[index];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: List.generate(3, _buildCards),
    );
  }

  Widget _buildCards(int index) {
    return Transform(
      alignment: Alignment.centerRight,
      transform: identity(index),
      child: GestureDetector(
        onTap: () async {
          if (index != 0) return;
          await incrementController.forward();
          detailController.forward();
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.accents[index % Colors.accents.length],
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 2.0,
                offset: Offset(5.0, 0.0),
              )
            ],
          ),
          child: _getChildren(index),
        ),
      ),
    );
  }
}

class CategoriesScreen extends AnimatedWidget {
  const CategoriesScreen({
    Key? key,
    required this.startOffset,
    required this.endOffset,
    required this.animation,
    required this.onSelect,
    required this.selectedIndex,
    required this.onBack,
  }) : super(key: key, listenable: animation);

  final double startOffset;
  final double endOffset;
  final Animation animation;
  final Function(int index) onSelect;
  final Function() onBack;
  final int selectedIndex;

  double get value => animation.value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: lerpDouble(startOffset, endOffset, value)!,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xffff9363),
        appBar: _buildAppBar,
        body: ListView.separated(
          shrinkWrap: true,
          itemCount: 20,
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          physics: const BouncingScrollPhysics(),
          separatorBuilder: (context, index) => const SizedBox(height: 10.0),
          itemBuilder: (context, index) => GestureDetector(
            onTap: () {
              onSelect.call(index);
            },
            child: _buildBody(index),
          ),
        ),
      ),
    );
  }

  AppBar get _buildAppBar {
    return AppBar(
      backgroundColor: const Color(0xffe2605b),
      centerTitle: true,
      title: Opacity(
        opacity: Curves.easeInCirc.transform(1.0 - value),
        child: const Text(
          'CATEGORIES',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      leading: Opacity(
        opacity: Curves.easeInCirc.transform(1.0 - value),
        child: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.person),
          iconSize: 30.0,
          color: Colors.white38,
        ),
      ),
      actions: [
        IconButton(
          onPressed: onBack,
          icon: Stack(
            children: [
              Opacity(
                opacity: Curves.easeInCirc.transform(1.0 - value),
                child: const Icon(Icons.search),
              ),
              Opacity(
                opacity: value,
                child: const Icon(Icons.arrow_back_ios),
              ),
            ],
          ),
          iconSize: 30.0,
          color: Colors.white30,
        ),
      ],
    );
  }

  Widget _buildBody(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      width: double.infinity,
      color:
          selectedIndex != index ? Colors.transparent : const Color(0xffffca78),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 100.0 - value * 45,
            height: 100.0 - value * 45,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              // color: Color(0xffff9e64),
            ),
            child: Image.asset(
              'assets/images/categories_img.png',
              fit: BoxFit.fill,
            ),
          ),
          SizedBox(width: 10.0 - 10 * value),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 200.0 - value * 200,
                height: 30.0 - 30 * value,
                decoration: BoxDecoration(
                  color: const Color(0xffe55e61),
                  borderRadius: BorderRadius.circular(30.0 - 30 * value),
                ),
              ),
              const SizedBox(height: 10.0),
              Container(
                width: 150.0 - value * 150.0,
                height: 15.0 - 15.0 * value,
                decoration: BoxDecoration(
                  color: const Color(0xffff7b52),
                  borderRadius: BorderRadius.circular(15.0 - 15 * value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CategoryScreen extends AnimatedWidget {
  const CategoryScreen({
    Key? key,
    required this.animation,
    required this.startOffset,
    required this.endOffset,
    required this.onSelect,
    required this.onBack,
    required this.opacity,
    required this.update,
  }) : super(key: key, listenable: animation);

  final Animation animation;
  final double startOffset;
  final double endOffset;
  final Function(int index) onSelect;
  final Function() onBack;
  final bool opacity;
  final double update;

  double get value => animation.value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: lerpDouble(startOffset, endOffset, value) ?? 0.0,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xff4573c8),
        appBar: _buildAppBar,
        body: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 300),
          tween: update == 1
              ? Tween<double>(begin: 0.0, end: 1.0)
              : Tween<double>(begin: 1.0, end: 0.0),
          builder: (context, value, child) {
            return Opacity(
              opacity: value as double,
              child: child,
            );
          },
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 300),
            tween: opacity
                ? Tween<double>(begin: 0.0, end: 1.0)
                : Tween<double>(begin: 1.0, end: 0.0),
            builder: (context, value, child) {
              return Opacity(opacity: value as double, child: child);
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              itemCount: 20,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 30.0),
              itemBuilder: (context, index) => _buildBody(index),
            ),
          ),
        ),
      ),
    );
  }

  AppBar get _buildAppBar {
    return AppBar(
      backgroundColor: const Color(0xff3661b3),
      centerTitle: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: Curves.easeInCirc.transform(value),
            child: IgnorePointer(
              ignoring: value == 0,
              child: IconButton(
                visualDensity: VisualDensity.comfortable,
                alignment: Alignment.centerRight,
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: onBack,
                iconSize: 25,
              ),
            ),
          ),
          const Text(
            'CATEGORY',
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        Visibility(
          visible: value <= 0,
          child: IconButton(
            icon: const Icon(Icons.filter),
            iconSize: 30.0,
            color: Colors.white38,
            onPressed: () {},
          ),
        )
      ],
    );
  }

  Widget _buildBody(int index) {
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(
        40.0 - 10 * value,
        5.0,
        20.0 - 10 * value,
        5.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 200.0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xff3763b9),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Image.asset(
              'assets/images/category_img.png',
              fit: BoxFit.fitWidth,
            ),
          ),
          const SizedBox(height: 15.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 30.0,
                      decoration: BoxDecoration(
                        color: const Color(0xff618dec),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      margin: const EdgeInsets.only(right: 10.0),
                    ),
                    const SizedBox(height: 10.0),
                    Container(
                      height: 15.0,
                      decoration: BoxDecoration(
                        color: const Color(0xff3562b4),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      margin: const EdgeInsets.only(right: 40.0),
                    )
                  ],
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xff04bab7),
                ),
                padding: const EdgeInsets.all(4.0),
                child: IconButton(
                  onPressed: () => onSelect.call(index),
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 30.0,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class SelectedScreen extends AnimatedWidget {
  const SelectedScreen({
    Key? key,
    required this.animation,
    required this.animation1,
    required this.offset,
    required this.onClear,
    required this.opacity,
    this.index = 0,
  }) : super(key: key, listenable: animation);

  final int index;
  final double offset;
  final Animation animation;
  final Animation animation1;
  final bool opacity;
  final Function() onClear;

  double get value => animation.value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: offset),
      child: Scaffold(
        backgroundColor: const Color(0xff253659),
        appBar: _buildAppBar,
        body: TweenAnimationBuilder(
          duration: const Duration(milliseconds: 300),
          tween: opacity
              ? Tween<double>(begin: 0.0, end: 1.0)
              : Tween<double>(begin: 1.0, end: 0.0),
          builder: (context, value, child) {
            return Opacity(opacity: value as double, child: child);
          },
          child: Stack(
            children: [
              if (index == 0) ...[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..translate(-40.0 + 35 * animation1.value),
                      child: const Align(
                        alignment: Alignment.centerRight,
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Text(
                            'CART IS EMPTY',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white30,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
              if (index != 0) ...[
                ListView.separated(
                  itemCount: index,
                  shrinkWrap: true,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 0.0),
                  itemBuilder: (context, index) => _buildBody(index),
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                )
              ]
            ],
          ),
        ),
        floatingActionButton: _floatingActionButton,
      ),
    );
  }

  AppBar get _buildAppBar {
    return AppBar(
      backgroundColor: const Color(0xff1c2944),
      centerTitle: true,
      title: Visibility(
        visible: index != 0,
        child: Text(
          value == 1 ? '$index Items' : '$index',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      actions: [
        Visibility(
          visible: value != 0 && index != 0,
          child: Opacity(
            opacity: value,
            child: IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.close),
              color: Colors.red,
              iconSize: 30.0,
            ),
          ),
        ),
        Visibility(
          visible: animation1.value == 1 && index == 0,
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.shop),
          ),
        )
      ],
    );
  }

  Widget _buildBody(int index) {
    return TweenAnimationBuilder(
        duration: const Duration(milliseconds: 400),
        tween: Curves.linearToEaseOut.transform(value) == 1
            ? Tween(begin: 0.0, end: 1.0)
            : Tween(begin: 1.0, end: 0.0),
        builder: (context, snapshot, _) {
          return Column(
            children: [
              Transform(
                alignment: Alignment.topCenter,
                transform: Matrix4.identity()
                  ..scale(snapshot as double)
                  ..translate(0.0, 180.0 * Curves.easeIn.transform(snapshot)),
                child: _buildBottomButton(snapshot),
              ),
              Transform(
                alignment: Alignment.topCenter,
                transform: Matrix4.identity()..translate(0.0, -40 * value),
                child: _buildImageContain(),
              ),
            ],
          );
        });
  }

  Widget _buildImageContain() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      width: double.infinity,
      child: Image.asset('assets/images/selected_img.png'),
    );
  }

  Widget _buildBottomButton(value) {
    return Container(
      height: 40.0 * Curves.easeIn.transform(value),
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: const Color(0xff274584),
        borderRadius: BorderRadius.circular(40.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.remove),
              color: const Color(0xff253659),
              iconSize: 24.0,
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5.0),
              decoration: BoxDecoration(
                color: const Color(0xff253659),
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
          ),
          Expanded(
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.add),
              color: const Color(0xff253659),
              iconSize: 24.0,
            ),
          )
        ],
      ),
    );
  }

  get _floatingActionButton {
    return FloatingActionButton.extended(
      onPressed: () {},
      label: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 1 - value,
            child: const Text(
              '\$',
              style: TextStyle(
                color: Colors.white30,
                fontSize: 30.0,
              ),
            ),
          ),
          Row(
            children: [
              Visibility(
                visible: value != 0,
                child: Opacity(
                  opacity: value,
                  child: Text('BUY for'),
                ),
              ),
              Text('\$${10 * index}'),
            ],
          ),
        ],
      ),
    );
  }
}
