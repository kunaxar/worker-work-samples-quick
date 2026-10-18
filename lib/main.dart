import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'add_job.dart';
import 'detail.dart';
import 'model.dart';
import 'ui.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Work record (quick add)', debugShowCheckedModeBanner: false, theme: buildTheme(),
        builder: (c, child) => Container(color: g100, child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480), child: ClipRect(child: child)))),
        home: const Shell(),
      );
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: SafeArea(child: Column(children: [demoBanner(), Expanded(child: ListenableBuilder(listenable: store, builder: (c, _) => [WorkTab(), EmployerView(), ResearchTab()][tab]))])),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab, onDestinationSelected: (i) => setState(() => tab = i), backgroundColor: Colors.white, indicatorColor: Colors.transparent, height: 64,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.construction_outlined), selectedIcon: Icon(Icons.construction, color: orange), label: 'My work'),
          NavigationDestination(icon: Icon(Icons.badge_outlined), selectedIcon: Icon(Icons.badge, color: orange), label: 'Employer view'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book, color: orange), label: 'Research'),
        ],
      ),
    );
  }
}

class WorkTab extends StatelessWidget {
  const WorkTab({super.key});
  @override
  Widget build(BuildContext context) {
    final awaiting = store.jobs.where((j) => j.vouch == Vouch.requested).length;
    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('My work', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Show what you actually did, job by job.', style: TextStyle(color: g500, fontSize: 15)),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: g100, borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            _stat('${store.jobs.length}', 'jobs'),
            _stat('${store.taskCount}', 'tasks'),
            _stat('${store.photoCount}', 'photos'),
            _stat('${store.confirmed}', 'confirmed'),
          ]),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
        child: FilledButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddJob())), icon: const Icon(Icons.add), label: const Text('Add a job')),
      ),
      if (awaiting > 0)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Container(
            padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: amberBg, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [const Icon(Icons.schedule, color: amber, size: 20), const SizedBox(width: 10), Expanded(child: Text('$awaiting job${awaiting > 1 ? 's are' : ' is'} waiting for someone to confirm. Open it to nudge them.', style: const TextStyle(color: amber, fontSize: 13, fontWeight: FontWeight.w500)))]),
          ),
        ),
      sectionTitle('Jobs', sub: 'Newest first'),
      for (final j in store.jobs) JobCard(j),
      if (store.jobs.isEmpty) const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No jobs yet. Add the first one - it takes about two minutes.', style: TextStyle(color: g500)))),
    ]);
  }

  Widget _stat(String n, String l) => Expanded(child: Column(children: [Text(n, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), Text(l, style: const TextStyle(color: g500, fontSize: 12))]));
}

class JobCard extends StatelessWidget {
  final Job j;
  const JobCard(this.j, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JobDetail(j))),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: g200), boxShadow: const [BoxShadow(color: Color(0x0F101828), blurRadius: 8, offset: Offset(0, 2))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Expanded(child: Text(j.project, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))), const Icon(Icons.chevron_right, color: g500)]),
              const SizedBox(height: 2),
              Text('${j.role} ${j.trade.toLowerCase()} · ${j.years}', style: const TextStyle(color: g600, fontSize: 13)),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 6, children: [vouchBadge(j), Tag('${j.tasks.length} tasks', g600, g100), if (j.photos.isNotEmpty) Tag('${j.photos.length} photo${j.photos.length > 1 ? 's' : ''}', g600, g100, icon: Icons.photo_camera_outlined)]),
              if (j.photos.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(height: 64, child: ListView(scrollDirection: Axis.horizontal, children: [for (final p in j.photos) Padding(padding: const EdgeInsets.only(right: 8), child: PhotoTile(p, size: 64))])),
              ],
            ]),
          ),
        ),
      );
}

class EmployerView extends StatelessWidget {
  const EmployerView({super.key});
  @override
  Widget build(BuildContext context) {
    final shown = store.jobs.where((j) => j.visible).toList();
    final counts = <String, int>{};
    for (final j in shown) { for (final t in j.tasks) { counts[t] = (counts[t] ?? 0) + 1; } }
    final top = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      Container(
        color: g100, padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        child: const Row(children: [Icon(Icons.visibility_outlined, size: 18, color: g600), SizedBox(width: 8), Expanded(child: Text('This is what an employer sees when you share your profile. Hide any job from its page.', style: TextStyle(fontSize: 13, color: g600)))]),
      ),
      Padding(
        padding: const EdgeInsets.all(20),
        child: Row(children: [
          Container(width: 64, height: 64, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, color: g50, border: Border.all(color: const Color(0xFF3CF5B0), width: 3)), child: const Text('MA', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: g600))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Marcus A. (demo)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            Text('Electrician apprentice · ${shown.length} job${shown.length == 1 ? '' : 's'} shown', style: const TextStyle(color: g500)),
          ])),
        ]),
      ),
      if (top.isNotEmpty) ...[
        sectionTitle('Done most often', sub: 'Counted across the jobs shown below'),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Wrap(spacing: 8, runSpacing: 8, children: [for (final e in top.take(5)) Pill('${e.key}${e.value > 1 ? '  x${e.value}' : ''}')])),
      ],
      sectionTitle('Work history'),
      for (final j in shown)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            padding: const EdgeInsets.all(16), decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: g200)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(j.project, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              Text('${j.role} ${j.trade.toLowerCase()} · ${j.kind} · ${j.years}', style: const TextStyle(color: g600, fontSize: 13)),
              const SizedBox(height: 8), vouchBadge(j),
              const SizedBox(height: 10),
              for (final t in j.tasks) Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.check, size: 16, color: slate), const SizedBox(width: 6), Expanded(child: Text(t, style: const TextStyle(fontSize: 14)))])),
              if (j.photos.isNotEmpty) ...[const SizedBox(height: 8), Wrap(spacing: 8, runSpacing: 8, children: [for (final p in j.photos) PhotoTile(p, size: 72)])],
            ]),
          ),
        ),
      if (shown.isEmpty) const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Nothing shown yet.', style: TextStyle(color: g500)))),
      const Padding(padding: EdgeInsets.fromLTRB(20, 4, 20, 0), child: Text('Green "Confirmed" means a named person said yes. Grey "Self-reported" means only you said it. Employers can tell the difference. In this demo every confirmation is simulated.', style: TextStyle(color: g500, fontSize: 12))),
    ]);
  }
}

class ResearchTab extends StatelessWidget {
  const ResearchTab({super.key});
  Widget link(String t, String u) => InkWell(onTap: () => launchUrl(Uri.parse(u)), child: Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [const Icon(Icons.open_in_new, size: 16, color: slate), const SizedBox(width: 8), Expanded(child: Text(t, style: const TextStyle(color: slate, fontSize: 14, decoration: TextDecoration.underline)))])));
  Widget bullet(String t) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Padding(padding: EdgeInsets.only(top: 7, right: 10), child: Icon(Icons.circle, size: 6, color: g500)), Expanded(child: Text(t, style: const TextStyle(fontSize: 14, height: 1.4)))]));
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), children: [
        const Text('Why this flow', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        bullet('A course card proves someone passed a class. It does not show what they have built, fixed or run. In the trades, skill is learned on the job: the U.S. Department of Labor describes apprenticeship as on-the-job learning under a mentor plus classroom instruction.'),
        bullet('Task lists are not invented here. Each choice is a plain-language version of a task statement in O*NET, the U.S. occupational database (Electricians, Carpenters, Plumbers/Pipefitters, Welders).'),
        bullet('A worker saying "I did this" is weaker than a named foreman saying it. So every job shows Self-reported or Confirmed by name, and the employer can see which.'),
        bullet('Photos are tied to a task ("this shows: run conduit") so a picture is evidence, not decoration.'),
        const SizedBox(height: 8),
        const Text('Design choices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        bullet('Tap, do not type: tasks are chips and checkboxes. The only required text is the project name.'),
        bullet('Four steps, one question per screen, a progress bar. Photos and confirmation can be skipped and added later.'),
        bullet('Nothing is forced public. Each job has a visible/hidden switch.'),
        const SizedBox(height: 8),
        const Text('Not validated yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        bullet('No worker or employer interviews have been done. These are hypotheses to test: (1) workers will add 2+ jobs if each takes about two minutes; (2) foremen will reply to a text-link confirmation; (3) employers read the task list before calling.'),
        const SizedBox(height: 8),
        const Text('What is simulated in this demo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        bullet('"Send request" sends nothing. The "Simulate reply" button stands in for the foreman confirming.'),
        bullet('Photos you pick stay in your browser tab and disappear on refresh. Grey-gradient tiles marked "sample" are placeholders, not real work photos.'),
        bullet('Marcus, the jobs and the companies are fictional.'),
        bullet('Quick add (this version): photos or video first, then one review screen. The suggested tasks and description are built from the trade and role using O*NET wording. Nothing is analysed from your photos or video. Real photo analysis is not built; it would need a vision service and a privacy review. The video button picks a file but shows a placeholder tile only.'),
        bullet('Photos and video cannot show who did the work or that they were licensed. Only a person who was there can confirm that.'),
        const SizedBox(height: 8),
        const Text('Sources', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        link('O*NET OnLine - Electricians (47-2111.00)', 'https://www.onetonline.org/link/summary/47-2111.00'),
        link('O*NET OnLine - Carpenters (47-2031.00)', 'https://www.onetonline.org/link/summary/47-2031.00'),
        link('O*NET OnLine - Plumbers, Pipefitters, and Steamfitters (47-2152.00)', 'https://www.onetonline.org/link/summary/47-2152.00'),
        link('O*NET OnLine - Welders, Cutters, Solderers, and Brazers (51-4121.00)', 'https://www.onetonline.org/link/summary/51-4121.00'),
        link('Apprenticeship.gov - how apprenticeship differs from other training', 'https://www.apprenticeship.gov/help/how-apprenticeship-different-other-types-work-based-training-models'),
      ]);
}
