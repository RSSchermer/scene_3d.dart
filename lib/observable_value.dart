/// Synchronously observable values.
library observable_value;

typedef void ChangeHandler<T>(T newValue, T oldValue);

/// Synchronously observable value.
class ObservableValue<T> {
  T _value;

  Map<Object, ChangeHandler<T>> _observerHandlers = {};

  /// Creates a new [ObservableValue].
  ///
  /// An optional [initialValue] may be specified. If not specified, the initial
  /// value defaults to `null`.
  ObservableValue([T initialValue]) : _value = initialValue;

  /// Returns this [ObservableValue]'s current value.
  T get value => _value;

  /// Sets this [ObservableValue]'s value to the [newValue] and notifies
  /// subscribers.
  ///
  /// Subscribers are only notified if the [newValue] differs from the old
  /// value.
  void set value(T newValue) {
    if (newValue != _value) {
      final oldValue = _value;

      _value = newValue;

      _observerHandlers.forEach((observer, handler) {
        handler(newValue, oldValue);
      });
    }
  }

  /// Adds a subscription for the [observer], calling the [changeHandler] when
  /// the [value] changes.
  void subscribe(Object observer, ChangeHandler<T> changeHandler) {
    _observerHandlers[observer] = changeHandler;
  }

  /// Unsubscribes the [observer] from any changes to the value.
  void unsubscribe(Object observer) {
    _observerHandlers.remove(observer);
  }
}
