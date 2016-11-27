part of rendering.realtime.sorting;

typedef SummarySortCode SummarySortCodeResolver();

/// A sort code that summarizes the values of a set of sort codes into a single
/// values.
abstract class SummarySortCode extends ObservableValue<num> {
  /// The sort codes summarized by this [SummarySortCode].
  Iterable<ObservableValue<num>> get summarizedSortCodes;

  /// Adds the [sortCode] to the [summarizedSortCodes].
  void add(ObservableValue<num> sortCode);

  /// Removes the [sortCode] from the [summarizedSortCodes].
  ///
  /// Returns `true` when the [summarizedSortCodes] contained the [sortCode],
  /// return `false` otherwise.
  bool remove(ObservableValue<num> sortCode);

  /// Returns a new copy of the current instance that does not yet contain
  /// any sort codes.
  SummarySortCode asEmpty();
}

abstract class _SummarySortCodeBase extends ObservableValue<num>
    implements SummarySortCode {
  final Set<ObservableValue<num>> _summarizedSortCodes = new Set();

  Iterable<ObservableValue<num>> get summarizedSortCodes =>
      _summarizedSortCodes;

  bool remove(ObservableValue<num> sortCode) {
    final wasMember = _summarizedSortCodes.remove(sortCode);

    if (wasMember) {
      sortCode.unsubscribe(this);
    }

    return wasMember;
  }
}

/// A static [SummarySortCode] whose value is not connected to the values of
/// the sort codes it summarizes.
class StaticSortCode extends _SummarySortCodeBase {
  StaticSortCode(num initialValue) {
    value = initialValue;
  }

  void add(ObservableValue<num> sortCode) {
    _summarizedSortCodes.add(sortCode);
  }

  bool remove(ObservableValue<num> sortCode) =>
      _summarizedSortCodes.remove(sortCode);

  StaticSortCode asEmpty() => new StaticSortCode(value);
}

/// A [SummarySortCode] that summarized a set of sort codes as their minimum
/// value.
class MinSortCode extends _SummarySortCodeBase {
  void add(ObservableValue<num> sortCode) {
    if (value == null) {
      value = sortCode.value;
    } else if (sortCode.value < value) {
      value = sortCode.value;
    }

    _summarizedSortCodes.add(sortCode);

    sortCode.subscribe(this, (newValue, oldValue) {
      if (newValue < value) {
        value = newValue;
      }
    });
  }

  MinSortCode asEmpty() => new MinSortCode();
}

/// A [SummarySortCode] that summarized a set of sort codes as their maximum
/// value.
class MaxSortCode extends _SummarySortCodeBase {
  void add(ObservableValue<num> sortCode) {
    if (value == null) {
      value = sortCode.value;
    } else if (sortCode.value > value) {
      value = sortCode.value;
    }

    _summarizedSortCodes.add(sortCode);

    sortCode.subscribe(this, (newValue, oldValue) {
      if (newValue > value) {
        value = newValue;
      }
    });
  }

  MaxSortCode asEmpty() => new MaxSortCode();
}
