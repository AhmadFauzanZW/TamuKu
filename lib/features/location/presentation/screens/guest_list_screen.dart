import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../injection_container.dart';
import '../../../guest/presentation/bloc/guest_bloc.dart';
import '../../../guest/presentation/bloc/guest_event.dart';
import '../../../guest/presentation/bloc/guest_state.dart';
import '../../../../shared/widgets/guest_tile.dart';

// NOTE: Located in location/ feature for historical reasons —
// manages the guest list scoped to a specific location.
// Logically belongs to guest/ but moving would break imports.

/// Layar daftar tamu dengan pencarian, filter, dan sort real-time.
class GuestListScreen extends StatelessWidget {
  const GuestListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locId =
        getIt<SharedPreferences>().getString(AppConstants.keyLocationId) ?? '';
    if (locId.isEmpty) {
      return const Scaffold(
        appBar: _AppBar(),
        body: Center(child: Text('Tidak ada lokasi yang dipilih')),
      );
    }
    return BlocProvider(
      create: (_) => getIt<GuestBloc>()..add(WatchGuestsStarted(locId)),
      child: const Scaffold(appBar: _AppBar(), body: _Body()),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar();
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

class _Body extends StatefulWidget {
  const _Body();
  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  static const _filters = [
    AppConstants.filterAll,
    AppConstants.filterCheckedIn,
    AppConstants.filterCompleted,
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => context.read<GuestBloc>().add(SearchGuests(q)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: TextField(
            controller: _searchCtrl,
            onChanged: _onSearch,
            decoration: InputDecoration(
              hintText: AppConstants.guestListSearchHint,
              prefixIcon: const Icon(Icons.search, color: AppColors.primary900),
              border: OutlineInputBorder(
                borderRadius: AppRadius.mdBorder,
                borderSide: BorderSide(color: AppColors.textSecondaryOf(context)),
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
        // Filter + Sort
        BlocBuilder<GuestBloc, GuestState>(
          builder: (context, state) {
            final af = state is GuestLoaded
                ? state.activeFilter
                : AppConstants.filterAll;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _filters.length,
                        itemBuilder: (_, i) {
                          final f = _filters[i];
                          final s = af == f;
                          return Padding(
                            padding: const EdgeInsets.only(
                              right: AppSpacing.sm,
                            ),
                            child: ChoiceChip(
                              label: Text(f),
                              selected: s,
                              selectedColor: AppColors.primary900,
                              labelStyle: TextStyle(
                                color: s ? Colors.white : AppColors.textPrimaryOf(context),
                                fontWeight: s
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              onSelected: (sel) {
                                if (sel) {
                                  context.read<GuestBloc>().add(
                                    FilterGuests(f),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  PopupMenuButton<SortType>(
                    icon: const Icon(Icons.sort, color: AppColors.primary900),
                    onSelected: (t) =>
                        context.read<GuestBloc>().add(SortGuests(t)),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: SortType.byDateDesc,
                        child: Text(AppConstants.sortNewest),
                      ),
                      PopupMenuItem(
                        value: SortType.byDateAsc,
                        child: Text(AppConstants.sortOldest),
                      ),
                      PopupMenuItem(
                        value: SortType.byNameAsc,
                        child: Text(AppConstants.sortByName),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        const Divider(height: 1),
        // List
        Expanded(
          child: BlocConsumer<GuestBloc, GuestState>(
            listener: (ctx, s) {
              if (s is GuestError) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                    content: Text(s.message),
                    backgroundColor: AppColors.accentRed,
                  ),
                );
              }
            },
            builder: (ctx, state) {
              if (state is GuestLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary900),
                );
              }
              if (state is GuestLoaded) {
                if (state.guests.isEmpty) return const _EmptyState();
                return ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: state.guests.length,
                  itemBuilder: (_, i) => GuestTile(
                    guest: state.guests[i],
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.checkout,
                      arguments: state.guests[i],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppColors.textSecondaryOf(context),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Belum ada tamu',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondaryOf(context)),
          ),
        ],
      ),
    );
  }
}

// Private _GuestTile removed — using shared GuestTile from lib/shared/widgets/
