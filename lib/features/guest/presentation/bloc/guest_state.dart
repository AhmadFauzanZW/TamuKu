import 'package:equatable/equatable.dart';

import '../../domain/entities/guest_entity.dart';

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

  const GuestLoaded(this.guests);
  @override
  List<Object> get props => [guests];
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
