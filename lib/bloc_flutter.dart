import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract class Bloc {
  void init();
  void dispose();
}

typedef BlocCreator<T extends Bloc> = T Function();

class BlocProvider<T extends Bloc> extends StatefulWidget {
  const BlocProvider({
    Key key,
    @required this.blocCreator,
    @required this.child,
  }) : super(key: key);

  final BlocCreator blocCreator;
  final Widget child;

  @override
  _BlocProviderState createState() => _BlocProviderState<T>();

  static T of<T extends Bloc>(BuildContext context) {
    final type = _typeOf<_BlocProviderScope<T>>();
    final element = context.ancestorInheritedElementForWidgetOfExactType(type);
    return (element?.widget as _BlocProviderScope<T>)?.bloc;
  }

  static Type _typeOf<T>() => T;
}

class _BlocProviderState<T extends Bloc> extends State<BlocProvider<T>> {
  T _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = widget.blocCreator();
    _bloc.init();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BlocProviderScope(
      bloc: _bloc,
      child: widget.child,
    );
  }
}

class _BlocProviderScope<T extends Bloc> extends InheritedWidget {
  const _BlocProviderScope({
    Key key,
    @required this.bloc,
    @required Widget child,
  }) : super(key: key, child: child);

  final T bloc;

  @override
  bool updateShouldNotify(_BlocProviderScope oldWidget) => bloc != oldWidget.bloc;
}

class BehaviorSubject<T> extends ValueListenable<T> {
  ValueNotifier<T> _latest;
  StreamController<T> _controller;

  BehaviorSubject(T value) {
    _latest = ValueNotifier<T>(value);
    _controller = StreamController<T>.broadcast(
      onListen: () => _controller.add(_latest.value),
    );
  }

  Stream<T> get stream => _controller.stream;

  @override
  T get value => _latest.value;

  set value(T newValue) {
    if (_latest.value == newValue) return;
    _latest.value = newValue;
    _controller.add(newValue);
  }

  @override
  void addListener(listener) => _latest.addListener(listener);

  @override
  void removeListener(listener) => _latest.removeListener(listener);
}
