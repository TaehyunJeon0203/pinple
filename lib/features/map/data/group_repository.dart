import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pinple/features/map/domain/group_model.dart';

class GroupRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _groupsRef => _firestore.collection('groups');
  CollectionReference get _requestsRef =>
      _firestore.collection('join_requests');

  Stream<List<GroupModel>> getActiveGroups() {
    return _groupsRef
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => GroupModel.fromFirestore(doc)).toList());
  }

  Future<GroupModel?> getGroupById(String groupId) async {
    final doc = await _groupsRef.doc(groupId).get();
    if (!doc.exists) return null;
    return GroupModel.fromFirestore(doc);
  }

  Future<String> createGroup(GroupModel group) async {
    final doc = await _groupsRef.add(group.toFirestore());
    return doc.id;
  }

  Future<void> updateGroup(String groupId, Map<String, dynamic> data) async {
    await _groupsRef.doc(groupId).update(data);
  }

  Future<void> deleteGroup(String groupId) async {
    await _groupsRef.doc(groupId).delete();
    // Also delete related join requests
    final requests =
        await _requestsRef.where('groupId', isEqualTo: groupId).get();
    for (final doc in requests.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> sendJoinRequest(JoinRequestModel request) async {
    await _requestsRef.add(request.toFirestore());
  }

  Stream<List<JoinRequestModel>> getJoinRequestsForGroup(String groupId) {
    return _requestsRef
        .where('groupId', isEqualTo: groupId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JoinRequestModel.fromFirestore(doc))
            .toList());
  }

  Future<void> acceptJoinRequest(String requestId, String groupId,
      String requesterUid) async {
    await _requestsRef.doc(requestId).update({'status': 'accepted'});
    await _groupsRef.doc(groupId).update({
      'memberIds': FieldValue.arrayUnion([requesterUid]),
    });
  }

  Future<void> rejectJoinRequest(String requestId) async {
    await _requestsRef.doc(requestId).update({'status': 'rejected'});
  }

  Stream<List<GroupModel>> getMyGroups(String userId) {
    return _groupsRef
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => GroupModel.fromFirestore(doc)).toList());
  }
}
