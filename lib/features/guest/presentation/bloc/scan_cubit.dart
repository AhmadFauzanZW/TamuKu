import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Manages the scan screen's local UI state (scanned flag).
class ScanState extends Equatable {
  /// Whether a QR code has already been scanned in this session.
  final bool hasScanned;

  const ScanState({this.hasScanned = false});

  /// Returns a copy with [hasScanned] overridden.
  ScanState copyWith({bool? hasScanned}) {
    return ScanState(hasScanned: hasScanned ?? this.hasScanned);
  }

  @override
  List<Object> get props => [hasScanned];
}

/// Cubit managing the scan screen's duplicate-scan guard.
class ScanCubit extends Cubit<ScanState> {
  /// Creates a [ScanCubit].
  ScanCubit() : super(const ScanState());

  /// Marks the scan as consumed to prevent duplicate navigation.
  void markScanned() => emit(state.copyWith(hasScanned: true));

  /// Resets the scan state (e.g. after error dialog).
  void reset() => emit(const ScanState());
}
