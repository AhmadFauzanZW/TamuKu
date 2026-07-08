import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../domain/entities/guest_entity.dart';

/// UI state for the guest registration form.
///
/// Tracks only the fields managed by [GuestFormBloc] (photo + keperluan).
/// Text-editing controllers stay in the view's [State] for lifecycle.
class GuestFormState extends Equatable {
  /// Selected photo file (nullable).
  final File? photo;

  /// Selected visit purpose (nullable until user picks one).
  final Keperluan? keperluan;

  /// Custom description for "Lainnya" keperluan.
  final String? keperluanLainnya;

  const GuestFormState({this.photo, this.keperluan, this.keperluanLainnya});

  /// Returns a copy with updated fields.
  GuestFormState copyWith({
    File? photo,
    bool clearPhoto = false,
    Keperluan? keperluan,
    String? keperluanLainnya,
  }) {
    return GuestFormState(
      photo: clearPhoto ? null : (photo ?? this.photo),
      keperluan: keperluan ?? this.keperluan,
      keperluanLainnya: keperluanLainnya ?? this.keperluanLainnya,
    );
  }

  @override
  List<Object?> get props => [photo, keperluan, keperluanLainnya];
}
