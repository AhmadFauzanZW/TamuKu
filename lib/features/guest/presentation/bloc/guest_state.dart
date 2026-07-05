import 'package:equatable/equatable.dart';
import '../../domain/entities/guest_entity.dart';

abstract class GuestState extends Equatable {
  const GuestState();
  @override
  List<Object> get props => [];
}

class GuestInitial extends GuestState {}
class GuestLoading extends GuestState {}

class GuestLoaded extends GuestState {
  final List<GuestEntity> guests;
  const GuestLoaded(this.guests);
  @override
  List<Object> get props => [guests];
}

class GuestError extends GuestState {
  final String message;
  const GuestError(this.message);
  @override
  List<Object> get props => [message];
}

class GuestCheckInSuccess extends GuestState {
  final GuestEntity guest;
  const GuestCheckInSuccess(this.guest);
  @override
  List<Object> get props => [guest];
}

class GuestCheckOutSuccess extends GuestState {
  final String guestId;
  const GuestCheckOutSuccess(this.guestId);
  @override
  List<Object> get props => [guestId];
}
