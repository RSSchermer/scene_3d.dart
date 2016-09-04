/// Provides an [ObservableSet] data structure.
library observable_set;

import 'dart:async';

import 'package:quiver/collection.dart';

// TODO: this should not live in this package (PR the `observe` package? new
// package?)

/// Record of a change made to the composition of a [Set].
class SetChangeRecord<E> {
  /// The elements that were added to the set as part of this change.
  final Iterable<E> additions;

  /// The elements that were removed from the set as part of this change.
  final Iterable<E> removals;

  /// Instantiates a new [SetChangeRecord].
  SetChangeRecord(this.additions, this.removals);
}

/// A [Set] that broadcasts any additions or removals of elements.
///
/// The [changes] [Stream] can be listened to in order to keep track of any
/// changes to the composition of this set. Each time elements are added or
/// removed, your listener will receive a [SetChangeRecord]:
///
///     var mySet = new ObservableSet();
///
///     mySet.changes.listen((change) {
///       print(change.additions);
///       print(change.removals);
///     });
///
class ObservableSet<E> extends DelegatingSet<E> implements Set<E> {
  final Set<E> delegate;

  final StreamController<SetChangeRecord<E>> _changesController =
      new StreamController<SetChangeRecord<E>>.broadcast();

  ObservableSet() : delegate = new Set();

  ObservableSet.from(Iterable elements) : delegate = new Set.from(elements);

  ObservableSet.identity() : delegate = new Set.identity();

  Stream<SetChangeRecord<E>> get changes => _changesController.stream;

  bool add(E value) {
    final success = delegate.add(value);

    if (success) {
      _changesController.add(new SetChangeRecord<E>([value], []));
    }

    return success;
  }

  void addAll(Iterable<E> values) {
    final additions = <E>[];

    for (var value in values) {
      if (delegate.add(value)) {
        additions.add(value);
      }
    }

    if (additions.isNotEmpty) {
      _changesController.add(new SetChangeRecord<E>(additions, []));
    }
  }

  void clear() {
    final removals = this.toList();

    delegate.clear();

    if (removals.isNotEmpty) {
      _changesController.add(new SetChangeRecord<E>([], removals));
    }
  }

  bool remove(Object value) {
    if (value is E && delegate.remove(value)) {
      _changesController.add(new SetChangeRecord<E>([], [value]));

      return true;
    } else {
      return false;
    }
  }

  void removeAll(Iterable<Object> values) {
    final removals = <E>[];

    for (var value in values) {
      if (value is E && delegate.remove(value)) {
        removals.add(value);
      }
    }

    if (removals.isNotEmpty) {
      _changesController.add(new SetChangeRecord<E>([], removals));
    }
  }

  void removeWhere(bool test(E element)) {
    final toRemove = <E>[];

    for (var value in delegate) {
      if (test(value)) {
        toRemove.add(value);
      }
    }

    removeAll(toRemove);
  }

  void retainAll(Iterable<Object> elements) {
    final toRemove = <E>[];

    for (var value in delegate) {
      if (!elements.contains(value)) {
        toRemove.add(value);
      }
    }

    removeAll(toRemove);
  }

  void retainWhere(bool test(E element)) {
    final toRemove = <E>[];

    for (var value in delegate) {
      if (!test(value)) {
        toRemove.add(value);
      }
    }

    removeAll(toRemove);
  }
}
