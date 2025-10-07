import 'dart:async';
import 'package:flutter/material.dart';
import '../models/member_model.dart';
import '../services/member_service.dart';

class MemberProvider with ChangeNotifier {
  final MemberService _service;
  List<Member> _members = [];
  StreamSubscription<List<Member>>? _sub;

  MemberProvider({MemberService? service})
      : _service = service ?? MemberService() {
    _listen();
  }

  void _listen() {
    _sub = _service.membersStream().listen((list) {
      _members = list;
      notifyListeners();
    }, onError: (err) {
      debugPrint('Member stream error: $err');
    });
  }

  List<Member> get members => _members;

  Future<void> addMember(Member m) async {
    await _service.addMember(m);
  }

  Future<void> updateMember(Member m) async {
    await _service.updateMember(m);
  }

  Future<void> deleteMember(String id) async {
    await _service.deleteMember(id);
  }

  @override
  Future<void> dispose() async {
    _sub?.cancel();
    super.dispose();
  }
}
