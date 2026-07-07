import 'package:equatable/equatable.dart';

import '../../domain/entities/guest_entity.dart';
import 'guest_event.dart';

/// Abstract base class for all guest-related states.
abstract class GuestState extends Equatable {
  const GuestState();
  @override
  List<Object> get props => [];
}

/// Initial state before any operation.
class GuestInitial extends GuestState {}

/// Loading state while fetching or processing data.
class GuestLoading extends GuestState {}

/// Successfully loaded guest list.

class GuestLoaded extends GuestState {
  /// The list of guests for the current location.
  final List<GuestEntity> guests;

  /// Active status filter ('Semua', 'Check-In', or 'Selesai').
  final String activeFilter;

  /// Current sort type for the guest list.
  final SortType sortType;

  const GuestLoaded(
    this.guests, {
    this.activeFilter = 'Semua',
    this.sortType = SortType.byDateDesc,
  });

  @override
  List<Object> get props => [guests, activeFilter, sortType];
}

/// A guest operation (check-in, check-out, delete) completed successfully.

class GuestOperationSuccess extends GuestState {
  /// Descriptive message about the operation result.
  final String message;

  const GuestOperationSuccess(this.message);
  @override
  List<Object> get props => [message];
}

/// An error occurred during a guest operation.

class GuestError extends GuestState {
  /// Human-readable error message.
  final String message;

  const GuestError(this.message);
  @override
  List<Object> get props => [message];
}
