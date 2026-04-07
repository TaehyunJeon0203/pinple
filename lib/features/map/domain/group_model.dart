import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final int maxMembers;
  final List<String> memberIds;
  final String ownerId;
  final String ownerNickname;
  final double latitude;
  final double longitude;
  final String locationName;
  final DateTime createdAt;
  final bool isActive;

  GroupModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.maxMembers,
    required this.memberIds,
    required this.ownerId,
    required this.ownerNickname,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.createdAt,
    this.isActive = true,
  });

  factory GroupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GroupModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '기타',
      maxMembers: data['maxMembers'] ?? 4,
      memberIds: List<String>.from(data['memberIds'] ?? []),
      ownerId: data['ownerId'] ?? '',
      ownerNickname: data['ownerNickname'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      locationName: data['locationName'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'maxMembers': maxMembers,
      'memberIds': memberIds,
      'ownerId': ownerId,
      'ownerNickname': ownerNickname,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  bool get isFull => memberIds.length >= maxMembers;
}

class JoinRequestModel {
  final String id;
  final String groupId;
  final String requesterId;
  final String requesterNickname;
  final String message;
  final String status; // pending, accepted, rejected
  final DateTime createdAt;

  JoinRequestModel({
    required this.id,
    required this.groupId,
    required this.requesterId,
    required this.requesterNickname,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory JoinRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JoinRequestModel(
      id: doc.id,
      groupId: data['groupId'] ?? '',
      requesterId: data['requesterId'] ?? '',
      requesterNickname: data['requesterNickname'] ?? '',
      message: data['message'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'groupId': groupId,
      'requesterId': requesterId,
      'requesterNickname': requesterNickname,
      'message': message,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
