import 'package:flutter/widgets.dart';

/// Centralized responsive breakpoint helper for the Pythagoras application.
/// Ensures consistent screen-type detection across Mobile, Small Tablet, and Large Tablet.
class ResponsiveHelper {
  ResponsiveHelper._();

  /// Standard threshold used across Pythagoras to distinguish a tablet from a mobile device.
  static const double tabletMinShortestSide = 600.0;

  /// Returns true if the device is a mobile phone (both portrait & landscape).
  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).shortestSide < tabletMinShortestSide;
  }

  /// Returns true if the device is a tablet (shortestSide >= 600).
  static bool isTablet(BuildContext context) {
    return MediaQuery.sizeOf(context).shortestSide >= tabletMinShortestSide;
  }

  /// Returns true if the orientation is landscape.
  static bool isLandscape(BuildContext context, [BoxConstraints? constraints]) {
    if (constraints != null &&
        constraints.hasBoundedWidth &&
        constraints.hasBoundedHeight) {
      return constraints.maxWidth > constraints.maxHeight;
    }
    final size = MediaQuery.sizeOf(context);
    return size.width > size.height;
  }

  /// Returns true if the orientation is portrait.
  static bool isPortrait(BuildContext context, [BoxConstraints? constraints]) {
    return !isLandscape(context, constraints);
  }

  /// Returns true if the current view should render the tablet landscape layout.
  /// Handles both standalone screens and nested screens (e.g., inside the tablet navigation sidebar).
  static bool isTabletLandscape(
    BuildContext context, [
    BoxConstraints? constraints,
  ]) {
    if (constraints != null &&
        constraints.hasBoundedWidth &&
        constraints.hasBoundedHeight) {
      // Direct constraint check for standalone or large layouts
      if (constraints.maxWidth >= 900 &&
          constraints.maxWidth > constraints.maxHeight) {
        return true;
      }
      // For tablets in landscape where available content width is adjusted (e.g. sidebar)
      if (isTablet(context) && constraints.maxWidth > constraints.maxHeight) {
        return true;
      }
    }
    return isTablet(context) && isLandscape(context, constraints);
  }

  /// Returns true if the current view is on a tablet in portrait mode.
  static bool isTabletPortrait(
    BuildContext context, [
    BoxConstraints? constraints,
  ]) {
    return isTablet(context) && isPortrait(context, constraints);
  }
}
