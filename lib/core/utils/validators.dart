abstract final class Validators {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nama wajib diisi';
    if (value.trim().length < 2) return 'Nama minimal 2 karakter';
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'No. WhatsApp wajib diisi';
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-]'), '');
    if (!RegExp(r'^(\+62|62|0)8[1-9][0-9]{6,10}$').hasMatch(cleaned)) {
      return 'Format nomor tidak valid';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? validateKeperluan(String? value) {
    if (value == null || value.isEmpty) return 'Pilih keperluan kunjungan';
    return null;
  }
}
