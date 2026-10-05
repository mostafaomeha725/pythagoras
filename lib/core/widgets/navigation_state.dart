import 'package:flutter/material.dart';

class NavigationState {
  int selectedIndex;
  final List<int> navigationStack;

  NavigationState({int initialIndex = 0})
      : selectedIndex = initialIndex,
        navigationStack = [initialIndex];

  void onItemTapped(int index, VoidCallback onStateChanged) {
    if (index == selectedIndex) return;
    selectedIndex = index;
    navigationStack.add(index);
    onStateChanged();
  }

  void goBack(VoidCallback onStateChanged) {
    if (navigationStack.length > 1) {
      navigationStack.removeLast();
      selectedIndex = navigationStack.last;
    } else {
      selectedIndex = 0;
    }
    onStateChanged();
  }

  void handleBackPress(VoidCallback onStateChanged) {
    if (navigationStack.length > 1) {
      navigationStack.removeLast();
      selectedIndex = navigationStack.last;
      onStateChanged();
    }
  }
}
