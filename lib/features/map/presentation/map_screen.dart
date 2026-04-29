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
      body: NaverMap(
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
