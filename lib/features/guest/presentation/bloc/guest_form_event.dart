import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../domain/entities/guest_entity.dart';

/// Abstract base for guest form–level events.
abstract class GuestFormEvent extends Equatable {
  const GuestFormEvent();
  @override
  List<Object> get props => [];
}

/// User picked a photo from camera or gallery.
class PhotoSelected extends GuestFormEvent {
  /// The picked image file.
  final File photo;
  const PhotoSelected(this.photo);
  @override
  List<Object> get props => [photo];
}

/// User removed the selected photo.
class PhotoRemoved extends GuestFormEvent {
  const PhotoRemoved();
}

/// User changed the keperluan dropdown.
class KeperluanChanged extends GuestFormEvent {
  /// Newly selected [Keperluan].
  final Keperluan keperluan;
  const KeperluanChanged(this.keperluan);
  @override
  List<Object> get props => [keperluan];
}
