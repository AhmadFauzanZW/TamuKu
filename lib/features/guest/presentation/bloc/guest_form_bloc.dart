import 'package:flutter_bloc/flutter_bloc.dart';

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
  }

  void _onPhotoSelected(PhotoSelected e, Emitter<GuestFormState> emit) {
    emit(state.copyWith(photo: e.photo));
  }

  void _onPhotoRemoved(PhotoRemoved e, Emitter<GuestFormState> emit) {
    emit(state.copyWith(clearPhoto: true));
  }

  void _onKeperluanChanged(KeperluanChanged e, Emitter<GuestFormState> emit) {
    emit(state.copyWith(keperluan: e.keperluan));
  }
}
