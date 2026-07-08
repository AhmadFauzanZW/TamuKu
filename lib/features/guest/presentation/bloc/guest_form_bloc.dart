import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/guest_entity.dart';
import 'guest_form_event.dart';
import 'guest_form_state.dart';

/// Manages UI-only form state: photo selection and keperluan dropdown.
///
/// The actual check-in submission is dispatched to [GuestBloc] directly;
/// this BLoC only tracks form field values that are not backed by
/// [TextEditingController]s.
class GuestFormBloc extends Bloc<GuestFormEvent, GuestFormState> {
  GuestFormBloc() : super(const GuestFormState()) {
    on<PhotoSelected>(_onPhotoSelected);
    on<PhotoRemoved>(_onPhotoRemoved);
    on<KeperluanChanged>(_onKeperluanChanged);
    on<KeperluanLainnyaChanged>(_onKeperluanLainnyaChanged);
  }

  void _onPhotoSelected(PhotoSelected e, Emitter<GuestFormState> emit) {
    emit(state.copyWith(photo: e.photo));
  }

  void _onPhotoRemoved(PhotoRemoved e, Emitter<GuestFormState> emit) {
    emit(state.copyWith(clearPhoto: true));
  }

  void _onKeperluanChanged(KeperluanChanged e, Emitter<GuestFormState> emit) {
    emit(state.copyWith(
      keperluan: e.keperluan,
      keperluanLainnya:
          e.keperluan == Keperluan.lainnya ? state.keperluanLainnya : null,
    ));
  }

  void _onKeperluanLainnyaChanged(
    KeperluanLainnyaChanged e,
    Emitter<GuestFormState> emit,
  ) {
    emit(state.copyWith(keperluanLainnya: e.text));
  }
}
