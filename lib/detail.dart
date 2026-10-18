import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'model.dart';
import 'ui.dart';

class JobDetail extends StatefulWidget {
  final Job j;
  const JobDetail(this.j, {super.key});
  @override
  State<JobDetail> createState() => _JobDetailState();
}

class _JobDetailState extends State<JobDetail> {
  Job get j => widget.j;
  void upd(VoidCallback f) { setState(f); store.touch(); }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Job', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)), actions: [
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: () { store.remove(j); Navigator.pop(context); }),
        ]),
        body: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 32), children: [
          Text(j.project, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('${j.role} ${j.trade.toLowerCase()} · ${j.kind} · ${j.years}${j.company.isEmpty ? '' : '\n${j.company}'}', style: const TextStyle(color: g600, height: 1.4)),
          if (j.note.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(j.note, style: const TextStyle(height: 1.4))),
          const SizedBox(height: 12), Align(alignment: Alignment.centerLeft, child: vouchBadge(j)),
          const SizedBox(height: 18),
          _confirmCard(),
          const SizedBox(height: 20),
          const Text('What I did', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          for (final t in j.tasks)
            Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
              const Icon(Icons.check_circle, color: slate, size: 20), const SizedBox(width: 10),
              Expanded(child: Text(t, style: const TextStyle(fontSize: 15))),
              if (j.photos.any((p) => p.task == t)) const Icon(Icons.photo_camera_outlined, size: 16, color: g500),
            ])),
          const SizedBox(height: 16),
          Row(children: [const Expanded(child: Text('Photos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))), TextButton.icon(onPressed: _addPhoto, icon: const Icon(Icons.add_a_photo_outlined, size: 18), label: const Text('Add'))]),
          const SizedBox(height: 8),
          if (j.photos.isEmpty) const Text('No photos yet. Jobs with photos are easier to trust.', style: TextStyle(color: g500)),
          Wrap(spacing: 10, runSpacing: 10, children: [for (final p in j.photos) Column(crossAxisAlignment: CrossAxisAlignment.start, children: [PhotoTile(p, size: 104), const SizedBox(height: 4), SizedBox(width: 104, child: Text(p.task.isEmpty ? 'No task tagged' : p.task, maxLines: 2, style: const TextStyle(fontSize: 11, color: g500)))])]),
          const SizedBox(height: 20),
          SwitchListTile(contentPadding: EdgeInsets.zero, value: j.visible, activeColor: slate, onChanged: (v) => upd(() => j.visible = v), title: const Text('Show this job to employers', style: TextStyle(fontWeight: FontWeight.w600)), subtitle: const Text('Hidden jobs stay in your record only')),
        ]),
      );

  Widget _confirmCard() {
    Widget body;
    switch (j.vouch) {
      case Vouch.none:
        body = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Get this confirmed', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('A foreman or coworker confirming makes this job count for more.', style: TextStyle(color: g600)),
          const SizedBox(height: 12),
          FilledButton(onPressed: _ask, child: const Text('Ask someone to confirm (demo, sends nothing)')),
        ]);
      case Vouch.requested:
        body = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Request sent to ${j.vouchName} (${j.vouchRole})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('We will tell you when they reply. If they do not, you can send a reminder.', style: TextStyle(color: g600)),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reminder sent (demo, nothing was sent).'))), child: const Text('Send a reminder')),
          const SizedBox(height: 8),
          FilledButton.tonal(style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)), onPressed: () => upd(() => j.vouch = Vouch.confirmed), child: Text('Demo: simulate ${j.vouchName} confirming')),
        ]);
      case Vouch.confirmed:
        body = Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.verified, color: green), const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Confirmed by ${j.vouchName}, ${j.vouchRole}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 4),
            Text('Said yes to all ${j.tasks.length} tasks.', style: const TextStyle(color: g600)),
          ])),
        ]);
    }
    return Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: j.vouch == Vouch.confirmed ? greenBg : g50, borderRadius: BorderRadius.circular(16), border: Border.all(color: g200)), child: body);
  }

  Future<void> _ask() async {
    final name = TextEditingController();
    String role = 'Foreman';
    await showModalBottomSheet(
      context: context, isScrollControlled: true, showDragHandle: true,
      builder: (c) => StatefulBuilder(builder: (c, set) => Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(c).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Who saw this work?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: [for (final r in ['Foreman', 'Supervisor', 'Coworker', 'Instructor']) Pill(r, on: role == r, onTap: () => set(() => role = r))]),
          const SizedBox(height: 12),
          TextField(controller: name, decoration: const InputDecoration(hintText: 'First name and initial')),
          const SizedBox(height: 12),
          FilledButton(onPressed: () { if (name.text.trim().isEmpty) return; upd(() { j.vouch = Vouch.requested; j.vouchName = name.text.trim(); j.vouchRole = role; }); Navigator.pop(c); }, child: const Text('Send request (demo)')),
        ]),
      )),
    );
  }

  Future<void> _addPhoto() async {
    try {
      final files = await ImagePicker().pickMultiImage(imageQuality: 80);
      for (final f in files) { j.photos.add(Photo(bytes: await f.readAsBytes())); }
      upd(() {});
    } catch (_) {
      upd(() => j.photos.add(Photo(tint: slate, icon: Icons.handyman)));
    }
  }
}
