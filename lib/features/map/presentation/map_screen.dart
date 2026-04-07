import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinple/core/constants/campus_constants.dart';
import 'package:pinple/features/location_gate/presentation/location_blocked_screen.dart';
import 'package:pinple/features/location_gate/providers/location_provider.dart';
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
    final locationCheck = ref.watch(locationCheckProvider);

    return locationCheck.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(error.toString().replaceFirst('Exception: ', '')),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(locationCheckProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
      data: (isWithin) {
        if (!isWithin) return const LocationBlockedScreen();
        return _buildMapContent();
      },
    );
  }

  Widget _buildMapContent() {
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
        ),
        onMapReady: (controller) {
          _mapController = controller;
          _updateMarkers();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/group/create'),
        icon: const Icon(Icons.add),
        label: const Text('모임 만들기'),
      ),
    );
  }

  void _updateMarkers() {
    ref.listen(activeGroupsProvider, (_, next) {
      next.whenData((groups) => _setMarkers(groups));
    });

    final groups = ref.read(activeGroupsProvider);
    groups.whenData((groups) => _setMarkers(groups));
  }

  Color _categoryColor(String category) {
    switch (category) {
      case '스터디':
        return Colors.blue;
      case '운동':
        return Colors.green;
      case '밥약':
        return Colors.orange;
      case '취미':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Future<void> _setMarkers(List<GroupModel> groups) async {
    final controller = _mapController;
    if (controller == null) return;

    await controller.clearOverlays();

    for (final group in groups) {
      final marker = NMarker(
        id: group.id,
        position: NLatLng(group.latitude, group.longitude),
        caption: NOverlayCaption(
          text: group.title,
          color: _categoryColor(group.category),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
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
