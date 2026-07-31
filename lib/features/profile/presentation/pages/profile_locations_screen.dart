import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/localization_constants.dart';
import '../../../../shared/shared.dart';
import '../../domain/entities/profile.dart';
import '../cubit/profile_location_cubit.dart';

class ProfileLocationsScreen extends StatelessWidget {
  const ProfileLocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileLocationCubit>(
      create: (_) => sl<ProfileLocationCubit>()..load(),
      child: const _ProfileLocationsView(),
    );
  }
}

class _ProfileLocationsView extends StatelessWidget {
  const _ProfileLocationsView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileLocationCubit, ProfileLocationState>(
      listenWhen: (previous, current) =>
          previous.error != current.error ||
          previous.changeSerial != current.changeSerial,
      listener: (context, state) {
        if (state.error != null) {
          context.showResolvedErrorSnackBar(state.error);
        } else if (state.changeSerial > 0) {
          context.showSuccessSnackBar(
            message: Message(
              title: '',
              value: LocalizationConstants.profileLocationSavedKey.tr(),
            ),
          );
        }
      },
      builder: (context, state) {
        final ProfileLocation? location = state.profile?.location;
        return Scaffold(
          backgroundColor: context.appBackground,
          appBar: AppBar(
            backgroundColor: context.appBackground,
            foregroundColor: context.isDark
                ? AppColors.primary300
                : AppColors.libraryGreen,
            elevation: 0,
            title: Text(LocalizationConstants.profileLocationsTitleKey.tr()),
            actions: <Widget>[
              IconButton(
                onPressed: state.saving
                    ? null
                    : () => _openLocationPicker(context, location),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          body: state.loading
              ? const Center(child: CircularProgressIndicator())
              : location == null
              ? _EmptyLocation(onAdd: () => _openLocationPicker(context, null))
              : _LocationContent(
                  location: location,
                  saving: state.saving,
                  onEdit: () => _openLocationPicker(context, location),
                  onDelete: () => _confirmDelete(context),
                ),
        );
      },
    );
  }

  Future<void> _openLocationPicker(
    BuildContext context,
    ProfileLocation? location,
  ) async {
    final ProfileLocation? selected =
        await showModalBottomSheet<ProfileLocation>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: context.appCard,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          builder: (_) => _LocationPickerSheet(initialLocation: location),
        );
    if (selected != null && context.mounted) {
      await context.read<ProfileLocationCubit>().save(selected);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(LocalizationConstants.profileLocationDeleteTitleKey.tr()),
        content: Text(
          LocalizationConstants.profileLocationDeleteMessageKey.tr(),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(LocalizationConstants.commonCancelKey.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(LocalizationConstants.profileLocationDeleteKey.tr()),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<ProfileLocationCubit>().delete();
    }
  }
}

class _EmptyLocation extends StatelessWidget {
  const _EmptyLocation({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.spacing24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            HugeIcon(
              icon: HugeIcons.strokeRoundedLocation01,
              size: 72,
              color: AppColors.primary600,
            ),
            const SizedBox(height: AppSpacing.spacing16),
            Text(
              LocalizationConstants.profileLocationEmptyKey.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                color: context.appTextSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.spacing24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_location_alt_outlined),
              label: Text(LocalizationConstants.profileLocationAddKey.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationContent extends StatelessWidget {
  const _LocationContent({
    required this.location,
    required this.saving,
    required this.onEdit,
    required this.onDelete,
  });

  final ProfileLocation location;
  final bool saving;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final LatLng point = LatLng(location.latitude, location.longitude);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.spacing24),
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.radius24),
          child: SizedBox(
            height: 250,
            child: _ProfileMap(point: point, interactive: false),
          ),
        ),
        const SizedBox(height: AppSpacing.spacing18),
        Container(
          padding: const EdgeInsets.all(AppSpacing.spacing18),
          decoration: BoxDecoration(
            color: context.appCard,
            borderRadius: BorderRadius.circular(AppRadius.radius24),
            border: Border.all(color: context.appBorder),
          ),
          child: Row(
            children: <Widget>[
              const Icon(
                Icons.location_on_outlined,
                color: AppColors.primary600,
              ),
              const SizedBox(width: AppSpacing.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      LocalizationConstants.profileLocationCurrentKey.tr(),
                      style: AppTextStyles.titleMedium.copyWith(
                        color: context.appTextPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.spacing4),
                    Text(
                      '${location.latitude.toStringAsFixed(6)}, '
                      '${location.longitude.toStringAsFixed(6)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: context.appTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: saving ? null : onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                onPressed: saving ? null : onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
        if (saving) ...<Widget>[
          const SizedBox(height: AppSpacing.spacing18),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
    );
  }
}

class _LocationPickerSheet extends StatefulWidget {
  const _LocationPickerSheet({this.initialLocation});

  final ProfileLocation? initialLocation;

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  static const LatLng _damascus = LatLng(33.5138, 36.2765);
  late LatLng _selected = widget.initialLocation == null
      ? _damascus
      : LatLng(
          widget.initialLocation!.latitude,
          widget.initialLocation!.longitude,
        );
  bool _locating = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.spacing20,
        right: AppSpacing.spacing20,
        top: AppSpacing.spacing20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.spacing20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  LocalizationConstants.profileLocationNewKey.tr(),
                  style: AppTextStyles.h3.copyWith(
                    color: context.appTextPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacing12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.radius20),
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.42,
              child: _ProfileMap(
                point: _selected,
                onTap: (LatLng point) => setState(() => _selected = point),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.spacing12),
          OutlinedButton.icon(
            onPressed: _locating ? null : _useCurrentLocation,
            icon: _locating
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location_rounded),
            label: Text(
              LocalizationConstants.profileLocationUseCurrentKey.tr(),
            ),
          ),
          if (_error != null) ...<Widget>[
            const SizedBox(height: AppSpacing.spacing8),
            Text(_error!, style: const TextStyle(color: AppColors.error500)),
          ],
          const SizedBox(height: AppSpacing.spacing12),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(
              ProfileLocation(
                latitude: _selected.latitude,
                longitude: _selected.longitude,
              ),
            ),
            child: Text(LocalizationConstants.commonSaveKey.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _locating = true;
      _error = null;
    });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError(
          LocalizationConstants.profileLocationServiceDisabledKey.tr(),
        );
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw StateError(
          LocalizationConstants.profileLocationPermissionDeniedKey.tr(),
        );
      }
      final Position position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() => _selected = LatLng(position.latitude, position.longitude));
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error is StateError
              ? error.message.toString()
              : LocalizationConstants.profileLocationUnavailableKey.tr();
        });
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }
}

class _ProfileMap extends StatelessWidget {
  const _ProfileMap({required this.point, this.onTap, this.interactive = true});

  final LatLng point;
  final ValueChanged<LatLng>? onTap;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: point,
        initialZoom: 15,
        interactionOptions: InteractionOptions(
          flags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
        ),
        onTap: onTap == null ? null : (_, LatLng point) => onTap!(point),
      ),
      children: <Widget>[
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.quraaa',
        ),
        MarkerLayer(
          markers: <Marker>[
            Marker(
              point: point,
              width: 48,
              height: 48,
              child: const Icon(
                Icons.location_pin,
                color: AppColors.primary600,
                size: 44,
              ),
            ),
          ],
        ),
        const SimpleAttributionWidget(
          source: Text('OpenStreetMap contributors'),
        ),
      ],
    );
  }
}
