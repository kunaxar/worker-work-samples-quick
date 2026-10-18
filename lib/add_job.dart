import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'data.dart';
import 'model.dart';
import 'ui.dart';

/// Quick flow: 1) add photos or video (optional), 2) one review screen.
/// Suggested tasks come from the O*NET list for the chosen trade and role.
/// Nothing is analysed from the photos. That would need a vision service and a privacy review.
class AddJob extends StatefulWidget {
  const AddJob({super.key});
  @override
  State<AddJob> createState() => _AddJobState();
}

class _AddJobState extends State<AddJob> {
  int step = 0;
  TradeDef trade = trades[0];
  String role = 'Apprentice';
  final project = TextEditingController();
  final custom = TextEditingController();
  final note = TextEditingController();
  bool noteEdited = false;
  bool current = true;
  final tasks = <String>{};
  final photos = <Photo>[];
  bool askVouch = false;
  final vname = TextEditingController();

  @override
  void initState() { super.initState(); _suggest(); }

  void _suggest() {
    tasks..clear()..addAll(trade.tasks.take(4).map((t) => t.label));
    _autoNote();
  }

  void _autoNote() {
    if (noteEdited) return;
    note.text = 'Worked as ${role.toLowerCase()} ${trade.name.toLowerCase()}: ${tasks.map((t) => t.toLowerCase()).join(', ')}.';
  }

  void finish() {
    final j = Job(
      id: 'j${DateTime.now().millisecondsSinceEpoch}', project: project.text.trim(), kind: 'Job', trade: trade.name, role: role,
      startYear: '2024', current: current, endYear: '2025', tasks: tasks, photos: photos, note: note.text.trim(),
      vouch: askVouch && vname.text.trim().isNotEmpty ? Vouch.requested : Vouch.none, vouchName: vname.text.trim(), vouchRole: 'Foreman',
    );
    store.add(j);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added. ${j.tasks.length} tasks and ${j.photos.length} photo(s) saved on this job.')));
  }

  Future<void> pick(bool video) async {
    try {
      if (video) {
        final f = await ImagePicker().pickVideo(source: ImageSource.gallery);
        if (f != null) photos.add(Photo(tint: slate, icon: Icons.videocam));
      } else {
        final files = await ImagePicker().pickMultiImage(imageQuality: 80);
        for (final f in files) { photos.add(Photo(bytes: await f.readAsBytes())); }
      }
      setState(() {});
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open the gallery here. Use a sample for the demo.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(step == 0 ? Icons.close : Icons.arrow_back), onPressed: () => step == 0 ? Navigator.pop(context) : setState(() => step--)),
        title: Text('Step ${step + 1} of 2', style: const TextStyle(fontSize: 14, color: g500, fontWeight: FontWeight.w500)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(4), child: LinearProgressIndicator(value: (step + 1) / 2, minHeight: 4, color: orange, backgroundColor: g200)),
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 16), children: step == 0 ? _media() : _review())),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: step == 0
                ? FilledButton(onPressed: () => setState(() => step = 1), child: Text(photos.isEmpty ? 'Skip, add details only' : 'Continue'))
                : Column(mainAxisSize: MainAxisSize.min, children: [
                    FilledButton(onPressed: project.text.trim().isEmpty || tasks.isEmpty ? null : finish, child: const Text('Save job')),
                    if (project.text.trim().isEmpty) const Padding(padding: EdgeInsets.only(top: 6), child: Text('Add a project name to save', style: TextStyle(color: g500, fontSize: 12))),
                  ]),
          ),
        ]),
      ),
    );
  }

  List<Widget> _media() => [
        const Text('Show the work', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('Add photos or a short video of the job. Skip faces and client addresses. You choose what to add and can remove it any time.', style: TextStyle(color: g600, height: 1.4)),
        const SizedBox(height: 16),
        Wrap(spacing: 10, runSpacing: 10, children: [
          for (final p in photos) Stack(children: [
            PhotoTile(p, size: 100),
            Positioned(right: 4, top: 4, child: InkWell(onTap: () => setState(() => photos.remove(p)), child: const CircleAvatar(radius: 11, backgroundColor: Colors.black54, child: Icon(Icons.close, size: 14, color: Colors.white)))),
          ]),
          InkWell(onTap: () => pick(false), child: _addBox(Icons.add_a_photo_outlined, 'Photos')),
          InkWell(onTap: () => pick(true), child: _addBox(Icons.videocam_outlined, 'Video')),
        ]),
        const SizedBox(height: 14),
        OutlinedButton.icon(onPressed: () => setState(() => photos.add(Photo(tint: [slate, amber, green][photos.length % 3], icon: Icons.handyman))), icon: const Icon(Icons.image_outlined), label: const Text('Use a sample photo (demo)')),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: g100, borderRadius: BorderRadius.circular(14)),
          child: const Text('Next you get a draft of the tasks and a description. It is built from your trade and role. Your photos are not analysed, and they stay on this device in the demo.', style: TextStyle(height: 1.4, color: g600)),
        ),
      ];

  Widget _addBox(IconData i, String t) => Container(width: 100, height: 100, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: g300), color: g50), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, color: slate), const SizedBox(height: 4), Text(t, style: const TextStyle(fontSize: 12, color: slate, fontWeight: FontWeight.w600))]));

  List<Widget> _review() => [
        const Text('Check your draft', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFFF4E5), borderRadius: BorderRadius.circular(12)),
          child: const Text('Demo suggestions. These tasks come from your trade and role, not from your photos. Untick what you did not do and add what is missing.', style: TextStyle(height: 1.4, fontSize: 13)),
        ),
        const SizedBox(height: 16),
        if (photos.isNotEmpty) ...[
          SizedBox(height: 70, child: ListView(scrollDirection: Axis.horizontal, children: [for (final p in photos) Padding(padding: const EdgeInsets.only(right: 8), child: PhotoTile(p, size: 70, onTap: () => _tag(p)))])),
          const SizedBox(height: 4),
          const Text('Tap a photo to say which task it shows.', style: TextStyle(color: g500, fontSize: 12)),
          const SizedBox(height: 14),
        ],
        const Text('Project name', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(controller: project, onChanged: (_) => setState(() {}), decoration: const InputDecoration(hintText: 'e.g. Maple Street apartments')),
        const SizedBox(height: 16),
        const Text('Trade and role', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [for (final t in trades) Pill('${t.emoji}  ${t.name}', on: trade == t, onTap: () => setState(() { trade = t; _suggest(); }))]),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [for (final r in roles) Pill(r, on: role == r, onTap: () => setState(() { role = r; _autoNote(); }))]),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('I still work here'), value: current, activeColor: slate, onChanged: (v) => setState(() => current = v)),
        const Text('Tasks (suggested, tick what is true)', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        for (final t in trade.tasks)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: tasks.contains(t.label) ? slate : g200), color: tasks.contains(t.label) ? const Color(0xFFEFF4F9) : Colors.white),
            child: CheckboxListTile(
              value: tasks.contains(t.label), activeColor: slate, controlAffinity: ListTileControlAffinity.leading,
              title: Text(t.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              onChanged: (v) => setState(() { v == true ? tasks.add(t.label) : tasks.remove(t.label); _autoNote(); }),
            ),
          ),
        for (final t in tasks.where((t) => !trade.tasks.any((d) => d.label == t)))
          Container(margin: const EdgeInsets.only(bottom: 8), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: slate), color: const Color(0xFFEFF4F9)), child: ListTile(title: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)), trailing: IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() { tasks.remove(t); _autoNote(); })))),
        Row(children: [
          Expanded(child: TextField(controller: custom, decoration: const InputDecoration(hintText: 'Something else you did'))),
          const SizedBox(width: 8),
          IconButton.filled(style: IconButton.styleFrom(backgroundColor: slate), onPressed: () { final v = custom.text.trim(); if (v.isNotEmpty) { setState(() { tasks.add(v); custom.clear(); _autoNote(); }); } }, icon: const Icon(Icons.add)),
        ]),
        const SizedBox(height: 16),
        const Text('Description (draft you can edit)', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(controller: note, maxLines: 3, onChanged: (_) => noteEdited = true),
        const SizedBox(height: 12),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Ask someone to confirm (demo)'), subtitle: const Text('Photos and video cannot show who did the work. A person who was there can. Nothing is sent in this demo.', style: TextStyle(fontSize: 12)), value: askVouch, activeColor: slate, onChanged: (v) => setState(() => askVouch = v)),
        if (askVouch) TextField(controller: vname, onChanged: (_) => setState(() {}), decoration: const InputDecoration(hintText: 'Their first name and initial')),
      ];

  void _tag(Photo p) => showModalBottomSheet(
        context: context, showDragHandle: true,
        builder: (c) => Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('This shows...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [for (final t in tasks) Pill(t, on: p.task == t, onTap: () { setState(() => p.task = t); Navigator.pop(c); })]),
        ])),
      );
}
