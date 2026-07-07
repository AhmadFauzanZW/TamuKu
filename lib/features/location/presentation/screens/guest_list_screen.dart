import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection_container.dart';
import '../bloc/location_bloc.dart';
import '../bloc/location_event.dart';
import '../bloc/location_state.dart';

/// Layar daftar kunjungan tamu dengan pencarian dan filter status.
///
/// Menggunakan [BlocProvider] untuk menyediakan [LocationBloc] dan
/// [BlocBuilder] untuk merespons perubahan filter secara reaktif.
class GuestListScreen extends StatelessWidget {
  const GuestListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<LocationBloc>()..add(const WatchLocationsStarted()),
      child: const Scaffold(
        appBar: _GuestListAppBar(),
        body: _GuestListBody(),
      ),
    );
  }
}

/// AppBar khusus layar daftar tamu.
class _GuestListAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _GuestListAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        AppConstants.guestListTitle,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: AppColors.primary900,
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}

/// Body berisi search bar, filter chips, dan daftar tamu.
///
/// Semua state diambil dari [LocationBloc] melalui [BlocBuilder].
class _GuestListBody extends StatelessWidget {
  const _GuestListBody();

  static const _filters = [
    AppConstants.filterAll,
    AppConstants.filterCheckedIn,
    AppConstants.filterCompleted,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: AppConstants.guestListSearchHint,
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.primary900),
              border: OutlineInputBorder(
                borderRadius: AppRadius.mdBorder,
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.mdBorder,
                borderSide: const BorderSide(
                  color: AppColors.primary900,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ),

        // 2. Filter Badges — BlocBuilder reads selectedFilter from BLoC
        BlocBuilder<LocationBloc, LocationState>(
          builder: (context, state) {
            final selectedFilter =
                state is LocationsLoaded ? state.selectedFilter : AppConstants.filterAll;
            return SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filterName = _filters[index];
                  final isSelected = selectedFilter == filterName;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: ChoiceChip(
                      label: Text(filterName),
                      selected: isSelected,
                      selectedColor: AppColors.primary900,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      onSelected: (bool selected) {
                        if (selected) {
                          context
                              .read<LocationBloc>()
                              .add(LocationFilterChanged(filterName));
                        }
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),

        const Divider(height: 1),

        // 3. Daftar Utama Tamu
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: 5,
            itemBuilder: (context, index) {
              final bool isCheckIn = index % 2 == 0;

              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.lgBorder,
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.all(AppSpacing.md),
                  leading: const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary900,
                    child: Icon(Icons.person, color: Colors.white, size: 28),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Muhammad Revan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: isCheckIn
                              ? AppColors.warningBg
                              : AppColors.successBg,
                          borderRadius: AppRadius.smBorder,
                        ),
                        child: Text(
                          isCheckIn
                              ? AppConstants.filterCheckedIn
                              : AppConstants.filterCompleted,
                          style: TextStyle(
                            color: isCheckIn
                                ? AppColors.warning
                                : AppColors.success,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Keperluan: Interview Kerja',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            isCheckIn
                                ? 'Masuk: 13:15 WIB'
                                : 'Masuk: 09:00 - Keluar: 11:30 WIB',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
