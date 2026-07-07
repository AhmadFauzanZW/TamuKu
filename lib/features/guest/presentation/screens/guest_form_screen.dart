import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../../injection_container.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/services/api_client.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/guest_submit_button.dart';
import '../../../../shared/widgets/photo_picker_section.dart';
import '../../domain/entities/guest_entity.dart';
import '../bloc/guest_bloc.dart';
import '../bloc/guest_event.dart';
import '../bloc/guest_form_bloc.dart';
import '../bloc/guest_form_event.dart';
import '../bloc/guest_form_state.dart';
import '../bloc/guest_state.dart';

/// Guest registration form screen.
///
/// Provides [GuestFormBloc] (photo + keperluan) and [GuestBloc]
/// (check-in submission). Route arguments: [locationId], [hostPhone].
class GuestFormScreen extends StatelessWidget {
  const GuestFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<GuestFormBloc>()),
        BlocProvider(create: (_) => getIt<GuestBloc>()),
      ],
      child: const GuestFormView(),
    );
  }
}

/// Holds [TextEditingController]s for lifecycle; all UI state via BLoCs.
class GuestFormView extends StatefulWidget {
  const GuestFormView({super.key});
  @override
  State<GuestFormView> createState() => _GuestFormViewState();
}

class _GuestFormViewState extends State<GuestFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _instansiCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _instansiCtrl.dispose();
    super.dispose();
  }

  // ── Submit ─────────────────────────────────────────────────────

  bool _submitting = false;

  Future<void> _onSubmit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    final fs = context.read<GuestFormBloc>().state;
    if (fs.keperluan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppConstants.keperluanRequired)),
      );
      return;
    }
    final args = ModalRoute.of(context)?.settings.arguments;
    String locationId = '';
    String? hostPhone;
    if (args is Map<String, dynamic>) {
      locationId = args['locationId'] as String? ?? '';
      hostPhone = args['hostPhone'] as String?;
    }

    // Upload photo to S3 via presigned URL (non-blocking on failure)
    String? photoUrl;
    if (fs.photo != null) {
      try {
        final apiClient = getIt<ApiClient>();
        final ext = fs.photo!.path.split('.').last.toLowerCase();
        final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
        final uploadData = await apiClient.getUploadUrl(mime);
        final bytes = await fs.photo!.readAsBytes();
        final putRes = await http.put(
          Uri.parse(uploadData['uploadUrl']!),
          body: bytes,
          headers: {'Content-Type': mime},
        );
        if (putRes.statusCode == 200) {
          photoUrl = uploadData['fileUrl'];
        }
      } catch (_) {
        // Photo upload failed — continue without photo
      }
    }

    _submitting = true;
    if (!mounted) return;
    context.read<GuestBloc>().add(
      CheckInRequested(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        keperluan: fs.keperluan!,
        instansi: _instansiCtrl.text.trim().isEmpty
            ? null
            : _instansiCtrl.text.trim(),
        photoUrl: photoUrl,
        locationId: locationId,
        hostPhone: hostPhone,
      ),
    );
  }

  // ── Image Picker ───────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (picked != null && mounted) {
      context.read<GuestFormBloc>().add(PhotoSelected(File(picked.path)));
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil Foto'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulir Tamu'),
        backgroundColor: AppColors.primary900,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocListener<GuestBloc, GuestState>(
        listener: _onStateChanged,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Silakan isi data kunjungan Anda',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondaryOf(context),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _field(
                    context: context,
                    ctrl: _nameCtrl,
                    label: AppConstants.nameLabel,
                    validator: Validators.validateName,
                    capitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  _field(
                    context: context,
                    ctrl: _phoneCtrl,
                    label: AppConstants.phoneLabel,
                    keyboard: TextInputType.phone,
                    validator: Validators.validatePhone,
                  ),
                  const SizedBox(height: 16),
                  _field(
                    context: context,
                    ctrl: _emailCtrl,
                    label: 'Email (opsional)',
                    keyboard: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 16),
                  _buildKeperluanDropdown(),
                  const SizedBox(height: 16),
                  _field(
                    context: context,
                    ctrl: _instansiCtrl,
                    label: AppConstants.instansiLabel,
                    capitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  PhotoPickerSection(onPickImage: _showImageSourceSheet),
                  const SizedBox(height: 32),
                  GuestSubmitButton(onPressed: _onSubmit),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── State Handler ──────────────────────────────────────────────

  void _onStateChanged(BuildContext context, GuestState state) {
    if (state is GuestOperationSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.confirmation);
    } else if (state is GuestError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  // ── Keperluan Dropdown ─────────────────────────────────────────

  Widget _buildKeperluanDropdown() {
    return BlocBuilder<GuestFormBloc, GuestFormState>(
      buildWhen: (p, c) => p.keperluan != c.keperluan,
      builder: (context, state) {
        return DropdownButtonFormField<Keperluan>(
          initialValue: state.keperluan,
          decoration: _dec(context, AppConstants.keperluanLabel),
          items: Keperluan.values
              .map((k) => DropdownMenuItem(value: k, child: Text(k.toValue())))
              .toList(),
          onChanged: (v) {
            if (v != null) {
              context.read<GuestFormBloc>().add(KeperluanChanged(v));
            }
          },
          validator: (_) =>
              state.keperluan == null ? AppConstants.keperluanRequired : null,
        );
      },
    );
  }

  // ── Helpers ────────────────────────────────────────────────────

  Widget _field({
    required BuildContext context,
    required TextEditingController ctrl,
    required String label,
    TextInputType? keyboard,
    String? Function(String?)? validator,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      textCapitalization: capitalization,
      decoration: _dec(context, label),
      validator: validator,
    );
  }

  InputDecoration _dec(BuildContext context, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.body.copyWith(
        color: AppColors.textSecondaryOf(context),
      ),
      filled: true,
      fillColor: AppColors.surfaceOf(context),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.borderOf(context)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.borderOf(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary700, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );
  }
}
