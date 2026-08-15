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
        return Scaffold(
          backgroundColor: context.appBackground,
          body: SafeArea(
            child: Column(
              children: <Widget>[
                _LocationsAppBar(
                  onAdd: state.saving
                      ? null
                      : () => _openLocationForm(context, null),
                ),
                if (state.saving) const LinearProgressIndicator(minHeight: 2),
                Expanded(
                  child: state.loading
                      ? const Center(child: CircularProgressIndicator())
                      : state.locations.isEmpty
                          ? _EmptyLocation(
                              onAdd: () => _openLocationForm(context, null),
                            )
                          : ListView.separated(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                20,
                                4,
                                20,
                                28,
                              ),
                              itemCount: state.locations.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final ProfileLocation location =
                                    state.locations[index];
                                return Dismissible(
                                  key: ValueKey<String>(
                                    location.id ??
                                        '${location.latitude}:'
                                            '${location.longitude}:$index',
                                  ),
                                  direction: DismissDirection.endToStart,
                                  confirmDismiss: (_) async {
                                    final bool confirmed =
                                        await _confirmDelete(context);
                                    if (confirmed && context.mounted) {
                                      await context
                                          .read<ProfileLocationCubit>()
                                          .delete(location);
                                    }
                                    return false;
                                  },
                                  background: Container(
                                    alignment: AlignmentDirectional.centerEnd,
                                    padding: const EdgeInsetsDirectional.only(
                                      end: 24,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.error500,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.white,
                                    ),
                                  ),
                                  child: _PrimaryLocationCard(
                                    location: location,
                                    onFavorite: () => context
                                        .read<ProfileLocationCubit>()
                                        .setDefault(location),
                                    saving: state.saving,
                                    onEdit: () =>
                                        _openLocationForm(context, location),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openLocationForm(
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
      builder: (_) => _LocationFormSheet(initialLocation: location),
    );
    if (selected != null && context.mounted) {
      await context.read<ProfileLocationCubit>().save(selected);
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
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
    return confirmed ?? false;
  }
}

class _LocationsAppBar extends StatelessWidget {
  const _LocationsAppBar({required this.onAdd});

  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final Color foreground =
        context.isDark ? AppColors.primary300 : AppColors.libraryGreen;
    return SizedBox(
      height: 76,
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 18),
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: HugeIcon(
                icon: context.isRTL
                    ? HugeIcons.strokeRoundedArrowRight01
                    : HugeIcons.strokeRoundedArrowLeft01,
                color: foreground,
                size: 23,
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                LocalizationConstants.profileLocationsTitleKey.tr(),
                style: AppTextStyles.h3.copyWith(
                  color: foreground,
                  fontSize: 28,
                ),
              ),
            ),
            IconButton(
              onPressed: onAdd,
              icon: Icon(Icons.add_rounded, color: foreground, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyLocation extends StatelessWidget {
  const _EmptyLocation({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            HugeIcon(
              icon: HugeIcons.strokeRoundedLocation01,
              size: 72,
              color: AppColors.primary600,
            ),
            const SizedBox(height: 16),
            Text(
              LocalizationConstants.profileLocationEmptyKey.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                color: context.appTextSecondary,
              ),
            ),
            const SizedBox(height: 22),
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

class _PrimaryLocationCard extends StatelessWidget {
  const _PrimaryLocationCard({
    required this.location,
    required this.saving,
    required this.onEdit,
    required this.onFavorite,
  });

  final ProfileLocation location;
  final bool saving;
  final VoidCallback onEdit;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final LatLng point = LatLng(location.latitude, location.longitude);
    final String label = location.name?.trim().isNotEmpty == true
        ? location.name!.trim()
        : LocalizationConstants.profileLocationDefaultNameKey.tr();
    final String address = location.address?.trim() ?? '';
    final String details = address.isNotEmpty
        ? address
        : '${location.latitude.toStringAsFixed(5)}, '
            '${location.longitude.toStringAsFixed(5)}';
    return Container(
      decoration: BoxDecoration(
        color: context.appCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary100),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 184,
            child: _ProfileMap(point: point, interactive: false),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 13, 8, 13),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: context.appTextPrimary,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        details,
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
                  color: context.isDark
                      ? AppColors.primary300
                      : AppColors.libraryGreen,
                ),
                IconButton(
                  tooltip: location.isDefault
                      ? LocalizationConstants.profileLocationFavoriteKey.tr()
                      : LocalizationConstants.profileLocationSetFavoriteKey
                          .tr(),
                  onPressed: saving || location.isDefault ? null : onFavorite,
                  icon: Icon(
                    location.isDefault
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: location.isDefault
                        ? const Color(0xFFFFC800)
                        : context.appTextSecondary,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationFormSheet extends StatefulWidget {
  const _LocationFormSheet({this.initialLocation});

  final ProfileLocation? initialLocation;

  @override
  State<_LocationFormSheet> createState() => _LocationFormSheetState();
}

class _LocationFormSheetState extends State<_LocationFormSheet> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.initialLocation?.name,
  );
  ProfileLocation? _selected;
  String? _nameError;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialLocation;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        22,
        22,
        22,
        MediaQuery.viewInsetsOf(context).bottom + 22,
      ),
      child: SingleChildScrollView(
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
                      fontSize: 30,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              LocalizationConstants.profileLocationNameKey.tr(),
              style: AppTextStyles.bodySmall.copyWith(
                color: context.appTextSecondary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: LocalizationConstants.profileLocationNameHintKey.tr(),
                errorText: _nameError,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _pickOnMap,
              icon: Icon(
                _selected == null ? Icons.add_rounded : Icons.check_rounded,
              ),
              label: Text(
                _selected == null
                    ? LocalizationConstants.profileLocationSelectKey.tr()
                    : LocalizationConstants.profileLocationSelectedKey.tr(),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                shape: const StadiumBorder(),
              ),
            ),
            if (_locationError != null) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                _locationError!,
                style: const TextStyle(color: AppColors.error500),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: const StadiumBorder(),
              ),
              child: Text(LocalizationConstants.profileLocationNextKey.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickOnMap() async {
    final ProfileLocation? location = await Navigator.of(context).push(
      MaterialPageRoute<ProfileLocation>(
        fullscreenDialog: true,
        builder: (_) => _LocationMapPicker(initialLocation: _selected),
      ),
    );
    if (location != null && mounted) {
      setState(() {
        _selected = location;
        _locationError = null;
      });
    }
  }

  void _submit() {
    final String label = _nameController.text.trim();
    setState(() {
      _nameError = label.isEmpty
          ? LocalizationConstants.profileEditRequiredKey.tr()
          : null;
      _locationError = _selected == null
          ? LocalizationConstants.profileLocationRequiredKey.tr()
          : null;
    });
    final ProfileLocation? selected = _selected;
    if (_nameError != null || _locationError != null || selected == null) {
      return;
    }
    Navigator.of(context).pop(
      ProfileLocation(
        id: widget.initialLocation?.id,
        name: label,
        address: widget.initialLocation?.address,
        latitude: selected.latitude,
        longitude: selected.longitude,
        isDefault: widget.initialLocation?.isDefault ?? false,
        creationTime: widget.initialLocation?.creationTime,
        lastModificationTime: widget.initialLocation?.lastModificationTime,
      ),
    );
  }
}

class _LocationMapPicker extends StatefulWidget {
  const _LocationMapPicker({this.initialLocation});

  final ProfileLocation? initialLocation;

  @override
  State<_LocationMapPicker> createState() => _LocationMapPickerState();
}

class _LocationMapPickerState extends State<_LocationMapPicker> {
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
    return Scaffold(
      backgroundColor: context.appBackground,
      appBar: AppBar(
        backgroundColor: context.appBackground,
        title: Text(LocalizationConstants.profileLocationMapTitleKey.tr()),
        actions: <Widget>[
          TextButton(
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
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: _ProfileMap(
              point: _selected,
              onTap: (point) => setState(() => _selected = point),
            ),
          ),
          PositionedDirectional(
            start: 20,
            end: 20,
            bottom: 24,
            child: Column(
              children: <Widget>[
                if (_error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    color: context.appCard,
                    child: Text(
                      _error!,
                      style: const TextStyle(color: AppColors.error500),
                    ),
                  ),
                FilledButton.icon(
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
              ],
            ),
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
      key: ValueKey<String>(
        '${point.latitude}:${point.longitude}:$interactive',
      ),
      options: MapOptions(
        initialCenter: point,
        initialZoom: 15,
        interactionOptions: InteractionOptions(
          flags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
        ),
        onTap: onTap == null ? null : (_, point) => onTap!(point),
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
        Align(
          alignment: Alignment.bottomRight,
          child: ColoredBox(
            color: context.appCard.withValues(alpha: 0.82),
            child: const Padding(
              padding: EdgeInsets.all(3),
              child: Text(
                '\u00A9 OpenStreetMap contributors',
                style: TextStyle(fontSize: 9),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
