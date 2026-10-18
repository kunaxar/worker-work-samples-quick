import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'data.dart';

enum Vouch { none, requested, confirmed }

class Photo {
  final Uint8List? bytes; // real picture picked on this device (kept in memory only)
  final Color? tint; // demo placeholder
  final IconData icon;
  String task;
  Photo({this.bytes, this.tint, this.icon = Icons.photo, this.task = ''});
}

class Job {
  String id, project, kind, company, trade, role, startYear, endYear;
  bool current, visible;
  Set<String> tasks;
  List<Photo> photos;
  Vouch vouch;
  String vouchName, vouchRole, note;
  Job({
    required this.id, required this.project, required this.kind, this.company = '', required this.trade, required this.role,
    required this.startYear, this.endYear = '', this.current = false, this.visible = true,
    Set<String>? tasks, List<Photo>? photos, this.vouch = Vouch.none, this.vouchName = '', this.vouchRole = '', this.note = '',
  })  : tasks = tasks ?? {}, photos = photos ?? [];

  String get years => current ? '$startYear - now' : (endYear.isEmpty || endYear == startYear ? startYear : '$startYear - $endYear');
  TradeDef get tradeDef => trades.firstWhere((t) => t.name == trade);
}

class Store extends ChangeNotifier {
  final List<Job> jobs = [
    Job(
      id: 'j1', project: 'Riverside Apartments, unit fit-out', kind: 'Apartments', company: 'Example Electric Co.', trade: 'Electrician', role: 'Apprentice',
      startYear: '2024', current: true,
      tasks: {'Run conduit and pull wire', 'Connect breakers and panels', 'Install fixtures and devices', 'Test circuits with a meter', 'Work from ladders and lifts'},
      photos: [
        Photo(tint: const Color(0xFFB54708), icon: Icons.electrical_services, task: 'Run conduit and pull wire'),
        Photo(tint: const Color(0xFF3C5F82), icon: Icons.electric_meter, task: 'Test circuits with a meter'),
      ],
      vouch: Vouch.confirmed, vouchName: 'Dana R.', vouchRole: 'Foreman',
    ),
    Job(
      id: 'j2', project: 'Community clinic, tenant improvement', kind: 'School / hospital', company: 'Example Electric Co.', trade: 'Electrician', role: 'Helper',
      startYear: '2023', endYear: '2024',
      tasks: {'Read blueprints and plan wiring', 'Install fixtures and devices'},
      photos: [Photo(tint: const Color(0xFF027A48), icon: Icons.lightbulb, task: 'Install fixtures and devices')],
      vouch: Vouch.requested, vouchName: 'Sam T.', vouchRole: 'Supervisor',
    ),
  ];

  void add(Job j) { jobs.insert(0, j); notifyListeners(); }
  void touch() => notifyListeners();
  void remove(Job j) { jobs.remove(j); notifyListeners(); }

  int get taskCount => jobs.fold(0, (a, j) => a + j.tasks.length);
  int get photoCount => jobs.fold(0, (a, j) => a + j.photos.length);
  int get confirmed => jobs.where((j) => j.vouch == Vouch.confirmed).length;
}

final store = Store();
