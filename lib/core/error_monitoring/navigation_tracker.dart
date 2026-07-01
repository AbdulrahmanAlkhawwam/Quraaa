import 'package:flutter/widgets.dart';

class NavigationTracker {
  final List<String> _routeStack = <String>[];
  final List<String> _history = <String>[];
  void Function()? _onChanged;

  void setOnChanged(void Function()? callback) {
    _onChanged = callback;
  }

  NavigationSnapshot get snapshot {
    return NavigationSnapshot(
      currentRoute: _routeStack.isEmpty ? null : _routeStack.last,
      previousRoute: _routeStack.length > 1 ? _routeStack[_routeStack.length - 2] : null,
      history: List<String>.unmodifiable(_history),
    );
  }

  NavigatorObserver get observer => NavigationTrackerObserver(this);

  void setInitialRoute(String routeName) {
    if (_routeStack.isEmpty) {
      _routeStack.add(routeName);
      _pushHistory(routeName);
      _onChanged?.call();
    }
  }

  void setRouteContext({
    String? currentRoute,
    String? previousRoute,
    List<String>? navigationHistory,
  }) {
    _routeStack
      ..clear()
      ..addAll(<String>[
        if (navigationHistory != null) ...navigationHistory.where((String value) => value.trim().isNotEmpty),
        if (navigationHistory == null && previousRoute != null && previousRoute.trim().isNotEmpty) previousRoute,
        if (currentRoute != null && currentRoute.trim().isNotEmpty) currentRoute,
      ]);

    _history
      ..clear()
      ..addAll(
        navigationHistory?.where((String value) => value.trim().isNotEmpty) ??
            <String>[
              if (previousRoute != null && previousRoute.trim().isNotEmpty) previousRoute,
              if (currentRoute != null && currentRoute.trim().isNotEmpty) currentRoute,
            ],
      );

    _onChanged?.call();
  }

  void didPush(String? routeName, String? previousRouteName) {
    if (routeName == null || routeName.isEmpty) {
      return;
    }

    if (_routeStack.isNotEmpty && _routeStack.last == routeName) {
      return;
    }

    if (_routeStack.isEmpty && previousRouteName != null && previousRouteName.isNotEmpty) {
      _routeStack.add(previousRouteName);
    }

    _routeStack.add(routeName);
    _pushHistory(routeName);
    _onChanged?.call();
  }

  void didPop(String? routeName, String? previousRouteName) {
    if (routeName != null && _routeStack.isNotEmpty && _routeStack.last == routeName) {
      _routeStack.removeLast();
    } else if (routeName != null) {
      _removeRouteFromStack(routeName);
    }

    _onChanged?.call();
  }

  void didReplace(String? newRouteName, String? oldRouteName) {
    bool changed = false;
    if (oldRouteName != null &&
        _routeStack.isNotEmpty &&
        _routeStack.last == oldRouteName) {
      _routeStack.removeLast();
      changed = true;
    }

    if (newRouteName != null && newRouteName.isNotEmpty) {
      if (_routeStack.isNotEmpty && _routeStack.last == newRouteName) {
        if (changed) {
          _onChanged?.call();
        }
        return;
      }
      _routeStack.add(newRouteName);
      _pushHistory(newRouteName);
      changed = true;
    }

    if (changed) {
      _onChanged?.call();
    }
  }

  void didRemove(String? routeName) {
    if (routeName == null) {
      return;
    }

    _removeRouteFromStack(routeName);
    _onChanged?.call();
  }

  void _pushHistory(String routeName) {
    if (_history.isEmpty || _history.last != routeName) {
      _history.add(routeName);
    }
  }

  void _removeRouteFromStack(String routeName) {
    _routeStack.removeWhere((String value) => value == routeName);
  }
}

class NavigationSnapshot {
  const NavigationSnapshot({
    required this.currentRoute,
    required this.previousRoute,
    required this.history,
  });

  final String? currentRoute;
  final String? previousRoute;
  final List<String> history;
}

class NavigationTrackerObserver extends NavigatorObserver {
  NavigationTrackerObserver(this._tracker);

  final NavigationTracker _tracker;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _tracker.didPush(_routeName(route), _routeName(previousRoute));
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _tracker.didPop(_routeName(route), _routeName(previousRoute));
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _tracker.didReplace(_routeName(newRoute), _routeName(oldRoute));
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _tracker.didRemove(_routeName(route));
    super.didRemove(route, previousRoute);
  }

  String? _routeName(Route<dynamic>? route) {
    return route?.settings.name ?? route?.settings.arguments?.toString();
  }
}
