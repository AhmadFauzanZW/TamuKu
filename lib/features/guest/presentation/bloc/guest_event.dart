import 'package:equatable/equatable.dart';

import '../../domain/entities/guest_entity.dart';

/// Abstract base class for all guest-related events.
///
/// Each event triggers a state transition in [GuestBloc].
abstract class GuestEvent extends Equatable {
  const GuestEvent();
  @override
  List<Object> get props => [];
}

/// Loads all guests for a given [locationId] from repository.

class LoadGuests extends GuestEvent {
  /// The location whose guests to load.
  final String locationId;

  const LoadGuests(this.locationId);
  @override
  List<Object> get props => [locationId];
}

/// Requests a new guest check-in with the provided details.

class CheckInRequested extends GuestEvent {
  /// Guest's full name.
  final String name;

  /// Guest's phone number.
  final String phone;

  /// Guest's email address (optional).
  final String? email;

  /// Purpose of the visit.
  final Keperluan keperluan;

  /// Guest's institution or company (optional).
  final String? instansi;

  /// URL to the guest's photo (optional).
  final String? photoUrl;

  /// Foreign key referencing the visited location.
  final String locationId;

  /// Host's phone for notifications (optional).
  final String? hostPhone;

  const CheckInRequested({
    required this.name,
    required this.phone,
    this.email,
    required this.keperluan,
    this.instansi,
    this.photoUrl,
    required this.locationId,
    this.hostPhone,
  });

  @override
  List<Object> get props => [name, phone, keperluan, locationId];
}

/// Requests a guest check-out by [guestId].

class CheckOutRequested extends GuestEvent {
  /// The ID of the guest checking out.
  final String guestId;

  const CheckOutRequested(this.guestId);
  @override
  List<Object> get props => [guestId];
}

/// Requests deletion of a guest record by [guestId].

class DeleteGuest extends GuestEvent {
  /// The ID of the guest to delete.
  final String guestId;

  const DeleteGuest(this.guestId);
  @override
  List<Object> get props => [guestId];
}

/// Starts a real-time stream subscription for guests at [locationId].

class WatchGuestsStarted extends GuestEvent {
  /// The location whose guests to watch in real-time.
  final String locationId;

  const WatchGuestsStarted(this.locationId);
  @override
  List<Object> get props => [locationId];
}

/// Filters the currently loaded guests by [query] (local filter).

class SearchGuests extends GuestEvent {
  /// The search query to filter guests by name.
  final String query;

  const SearchGuests(this.query);
  @override
  List<Object> get props => [query];
}

/// Sort type for guest list.
enum SortType {
  /// Sort by check-in date, newest first.
  byDateDesc,
  /// Sort by check-in date, oldest first.
  byDateAsc,
  /// Sort by guest name alphabetically.
  byNameAsc,
}

/// Filters guests by status (Semua / Check-In / Selesai).

class FilterGuests extends GuestEvent {
  /// The filter value: 'Semua', 'Check-In', or 'Selesai'.
  final String filter;

  const FilterGuests(this.filter);
  @override
  List<Object> get props => [filter];
}

/// Sorts guests by different criteria.

class SortGuests extends GuestEvent {
  /// The sort type to apply.
  final SortType sortType;

  const SortGuests(this.sortType);
  @override
  List<Object> get props => [sortType];
}
