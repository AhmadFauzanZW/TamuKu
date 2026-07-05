import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure([this.message = 'Terjadi kesalahan']);
  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Gagal terhubung ke server']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Gagal mengakses data lokal']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Autentikasi gagal']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Tidak ada koneksi internet']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Data tidak valid']);
}
