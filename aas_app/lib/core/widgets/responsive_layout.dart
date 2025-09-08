import 'package:flutter/material.dart';
import '../theme/responsive_breakpoints.dart';
import '../theme/index.dart';

/// Responsive layout wrapper that adapts to screen size
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.desktopLarge,
  });
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? desktopLarge;

  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveBreakpoints.getScreenSize(context);

    switch (screenSize) {
      case ScreenSize.mobile:
        return mobile;
      case ScreenSize.tablet:
        return tablet ?? mobile;
      case ScreenSize.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenSize.desktopLarge:
        return desktopLarge ?? desktop ?? tablet ?? mobile;
    }
  }
}

/// Mobile-first scaffold with responsive behavior
class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    super.key,
    this.appBar,
    this.body,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.primary = true,
  });
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body != null ? PatternBackground(
        patternType: PatternType.grid,
        patternOpacity: 0.02,
        child: body!,
      ) : null,
      drawer: ResponsiveBreakpoints.isMobile(context) ? drawer : null,
      endDrawer: endDrawer,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      backgroundColor: backgroundColor ?? AppColors.background,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      primary: primary,
    );
  }
}

/// Responsive container with adaptive padding and margins
class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.color,
    this.decoration,
    this.alignment,
    this.clipBehavior,
  });
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final Color? color;
  final Decoration? decoration;
  final AlignmentGeometry? alignment;
  final Clip? clipBehavior;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? ResponsiveBreakpoints.getResponsivePadding(context),
      margin: margin ?? ResponsiveBreakpoints.getResponsiveMargin(context),
      color: color,
      decoration: decoration,
      alignment: alignment,
      clipBehavior: clipBehavior ?? Clip.none,
      child: child,
    );
  }
}

/// Responsive card with adaptive styling
class ResponsiveCard extends StatelessWidget {
  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.shape,
    this.clipBehavior,
    this.semanticContainer = true,
  });
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final double? elevation;
  final ShapeBorder? shape;
  final Clip? clipBehavior;
  final bool semanticContainer;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ?? ResponsiveBreakpoints.getResponsiveMargin(context),
      color: color ?? AppColors.surface,
      elevation: elevation ?? 2,
      shape: shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveBreakpoints.getCardRadius(context),
            ),
          ),
      clipBehavior: clipBehavior ?? Clip.none,
      semanticContainer: semanticContainer,
      child: Padding(
        padding: padding ?? ResponsiveBreakpoints.getResponsivePadding(context),
        child: child,
      ),
    );
  }
}

/// Responsive grid layout
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing,
    this.runSpacing,
    this.padding,
    this.margin,
    this.crossAxisCount,
    this.childAspectRatio,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
  });
  final List<Widget> children;
  final double? spacing;
  final double? runSpacing;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final int? crossAxisCount;
  final double? childAspectRatio;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;

  @override
  Widget build(BuildContext context) {
    final responsiveCrossAxisCount =
        crossAxisCount ?? ResponsiveBreakpoints.getGridColumns(context);

    final responsiveSpacing =
        spacing ?? ResponsiveBreakpoints.getResponsiveSpacing(context);

    return Padding(
      padding: padding ?? ResponsiveBreakpoints.getResponsivePadding(context),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: responsiveCrossAxisCount,
          childAspectRatio: childAspectRatio ?? 1.0,
          crossAxisSpacing: crossAxisSpacing ?? responsiveSpacing,
          mainAxisSpacing: mainAxisSpacing ?? responsiveSpacing,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) => children[index],
      ),
    );
  }
}

/// Responsive list layout
class ResponsiveList extends StatelessWidget {
  const ResponsiveList({
    super.key,
    required this.children,
    this.padding,
    this.margin,
    this.spacing,
    this.physics,
    this.shrinkWrap = false,
    this.primary = true,
  });
  final List<Widget> children;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? spacing;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final responsiveSpacing =
        spacing ?? ResponsiveBreakpoints.getResponsiveSpacing(context);

    return Padding(
      padding: padding ?? ResponsiveBreakpoints.getResponsivePadding(context),
      child: ListView.separated(
        padding: margin ?? EdgeInsets.zero,
        physics: physics,
        shrinkWrap: shrinkWrap,
        primary: primary,
        itemCount: children.length,
        separatorBuilder: (context, index) =>
            SizedBox(height: responsiveSpacing),
        itemBuilder: (context, index) => children[index],
      ),
    );
  }
}

/// Responsive row layout
class ResponsiveRow extends StatelessWidget {
  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.mainAxisSize,
    this.textDirection,
    this.verticalDirection,
    this.textBaseline,
    this.spacing,
  });
  final List<Widget> children;
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final MainAxisSize? mainAxisSize;
  final TextDirection? textDirection;
  final VerticalDirection? verticalDirection;
  final TextBaseline? textBaseline;
  final double? spacing;

  @override
  Widget build(BuildContext context) {
    final responsiveSpacing =
        spacing ?? ResponsiveBreakpoints.getResponsiveSpacing(context);

    if (spacing != null) {
      return Row(
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
        mainAxisSize: mainAxisSize ?? MainAxisSize.max,
        textDirection: textDirection,
        verticalDirection: verticalDirection ?? VerticalDirection.down,
        textBaseline: textBaseline,
        children: _addSpacing(children, responsiveSpacing),
      );
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
      mainAxisSize: mainAxisSize ?? MainAxisSize.max,
      textDirection: textDirection,
      verticalDirection: verticalDirection ?? VerticalDirection.down,
      textBaseline: textBaseline,
      children: children,
    );
  }

  List<Widget> _addSpacing(List<Widget> widgets, double spacing) {
    if (widgets.isEmpty) return widgets;

    final result = <Widget>[];
    for (var i = 0; i < widgets.length; i++) {
      result.add(widgets[i]);
      if (i < widgets.length - 1) {
        result.add(SizedBox(width: spacing));
      }
    }
    return result;
  }
}

/// Responsive column layout
class ResponsiveColumn extends StatelessWidget {
  const ResponsiveColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.mainAxisSize,
    this.textDirection,
    this.verticalDirection,
    this.textBaseline,
    this.spacing,
  });
  final List<Widget> children;
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final MainAxisSize? mainAxisSize;
  final TextDirection? textDirection;
  final VerticalDirection? verticalDirection;
  final TextBaseline? textBaseline;
  final double? spacing;

  @override
  Widget build(BuildContext context) {
    final responsiveSpacing =
        spacing ?? ResponsiveBreakpoints.getResponsiveSpacing(context);

    if (spacing != null) {
      return Column(
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
        mainAxisSize: mainAxisSize ?? MainAxisSize.max,
        textDirection: textDirection,
        verticalDirection: verticalDirection ?? VerticalDirection.down,
        textBaseline: textBaseline,
        children: _addSpacing(children, responsiveSpacing),
      );
    }

    return Column(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
      mainAxisSize: mainAxisSize ?? MainAxisSize.max,
      textDirection: textDirection,
      verticalDirection: verticalDirection ?? VerticalDirection.down,
      textBaseline: textBaseline,
      children: children,
    );
  }

  List<Widget> _addSpacing(List<Widget> widgets, double spacing) {
    if (widgets.isEmpty) return widgets;

    final result = <Widget>[];
    for (var i = 0; i < widgets.length; i++) {
      result.add(widgets[i]);
      if (i < widgets.length - 1) {
        result.add(SizedBox(height: spacing));
      }
    }
    return result;
  }
}
