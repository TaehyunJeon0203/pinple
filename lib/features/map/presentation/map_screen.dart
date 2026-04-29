import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinple/core/constants/campus_constants.dart';
import 'package:pinple/core/theme/app_theme.dart';
import 'package:pinple/core/utils/category_helpers.dart';
import 'package:pinple/features/map/domain/group_model.dart';
import 'package:pinple/features/map/presentation/widgets/group_bottom_sheet.dart';
import 'package:pinple/features/map/providers/group_provider.dart';
import 'package:pinple/features/shell/presentation/app_drawer.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  NaverMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    ref.listen(activeGroupsProvider, (_, next) {
      next.whenData(_setMarkers);
    });

    return Scaffold(
      drawer: const AppDrawer(),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          NaverMap(
            options: const NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: NLatLng(
                  CampusConstants.latitude,
                  CampusConstants.longitude,
                ),
                zoom: 15.5,
              ),
              mapType: NMapType.basic,
              locationButtonEnable: true,
              logoClickEnable: false,
            ),
            onMapReady: (controller) {
              _mapController = controller;
              ref.read(activeGroupsProvider).whenData(_setMarkers);
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.md,
            left: AppSpacing.lg,
            child: Builder(
              builder: (context) => _CircleIconButton(
                icon: Icons.menu_rounded,
                onTap: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.md,
            right: AppSpacing.lg,
            child: _CircleIconButton(
              icon: Icons.list_rounded,
              onTap: () => context.push('/list'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/group/create'),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          '모임 만들기',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<void> _setMarkers(List<GroupModel> groups) async {
    final controller = _mapController;
    if (controller == null) return;

    await controller.clearOverlays();

    for (final group in groups) {
      final color = categoryColor(group.category);
      final marker = NMarker(
        id: group.id,
        position: NLatLng(group.latitude, group.longitude),
        caption: NOverlayCaption(
          text: group.title,
          color: color,
          textSize: 13,
          haloColor: Colors.white,
        ),
      );
      marker.setOnTapListener((_) {
        _showGroupBottomSheet(group);
      });
      await controller.addOverlay(marker);
    }
  }

  void _showGroupBottomSheet(GroupModel group) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bg,
      builder: (_) => GroupBottomSheet(
        group: group,
        onDetailTap: () {
          Navigator.pop(context);
          context.push('/group/${group.id}');
        },
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bg,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(icon, size: 22, color: AppColors.textStrong),
        ),
      ),
    );
  }
}
