// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$favoriteNotifierHash() => r'6eec1ee851ad2e416dec960228d05e9f702eea28';

/// Manages the set of song IDs that are in the user's favorites playlist.
///
/// UI widgets watch this provider to render the heart icon state.
/// Call [loadFavoriteStatus] after loading a page's song list,
/// then [toggleFavorite] when the user taps the heart button.
///
/// Copied from [FavoriteNotifier].
@ProviderFor(FavoriteNotifier)
final favoriteNotifierProvider =
    AutoDisposeAsyncNotifierProvider<FavoriteNotifier, Set<int>>.internal(
  FavoriteNotifier.new,
  name: r'favoriteNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$favoriteNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FavoriteNotifier = AutoDisposeAsyncNotifier<Set<int>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
