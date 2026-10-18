import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'model.dart';

const slate = Color(0xFF3C5F82);
const orange = Color(0xFFFD6A3E);
const g50 = Color(0xFFF9FAFB);
const g100 = Color(0xFFF2F4F7);
const g200 = Color(0xFFEAECF0);
const g300 = Color(0xFFD0D5DD);
const g500 = Color(0xFF667085);
const g600 = Color(0xFF475467);
const g900 = Color(0xFF101828);
const green = Color(0xFF027A48);
const greenBg = Color(0xFFECFDF3);
const amber = Color(0xFFB54708);
const amberBg = Color(0xFFFFFAEB);

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: slate).copyWith(primary: slate, secondary: orange, surface: Colors.white),
    scaffoldBackgroundColor: Colors.white,
  );
  return base.copyWith(
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(bodyColor: g900, displayColor: g900),
    appBarTheme: const AppBarTheme(backgroundColor: Colors.white, surfaceTintColor: Colors.white, elevation: 0, scrolledUnderElevation: 0, foregroundColor: g900),
    dividerColor: g200,
    filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52), shape: const StadiumBorder(), textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16))),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48), shape: const StadiumBorder(), side: const BorderSide(color: g300), foregroundColor: g900, textStyle: const TextStyle(fontWeight: FontWeight.w600))),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: g50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: g300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: g300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: slate, width: 1.5)),
    ),
  );
}

class Pill extends StatelessWidget {
  final String text; final bool on; final VoidCallback? onTap; final IconData? icon;
  const Pill(this.text, {super.key, this.on = false, this.onTap, this.icon});
  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(color: on ? slate : g50, borderRadius: BorderRadius.circular(40), border: Border.all(color: on ? slate : g300)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[Icon(icon, size: 16, color: on ? Colors.white : g600), const SizedBox(width: 6)],
            Flexible(child: Text(text, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: on ? Colors.white : g600))),
          ]),
        ),
      );
}

class Tag extends StatelessWidget {
  final String text; final Color fg, bg; final IconData? icon;
  const Tag(this.text, this.fg, this.bg, {super.key, this.icon});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 4)],
          Text(text, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      );
}

Widget vouchBadge(Job j) {
  switch (j.vouch) {
    case Vouch.confirmed: return Tag('Confirmed by ${j.vouchName}', green, greenBg, icon: Icons.verified);
    case Vouch.requested: return Tag('Waiting for ${j.vouchName}', amber, amberBg, icon: Icons.schedule);
    case Vouch.none: return const Tag('Self-reported', g600, g100, icon: Icons.edit_note);
  }
}

class PhotoTile extends StatelessWidget {
  final Photo p; final double size; final VoidCallback? onTap;
  const PhotoTile(this.p, {super.key, this.size = 96, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: size, height: size,
            child: p.bytes != null
                ? Image.memory(p.bytes!, fit: BoxFit.cover)
                : Container(
                    decoration: BoxDecoration(gradient: LinearGradient(colors: [p.tint ?? slate, (p.tint ?? slate).withOpacity(.65)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                    child: Stack(children: [
                      Center(child: Icon(p.icon, color: Colors.white.withOpacity(.9), size: size * .38)),
                      Positioned(left: 6, bottom: 4, child: Text('sample', style: TextStyle(color: Colors.white.withOpacity(.8), fontSize: 10))),
                    ]),
                  ),
          ),
        ),
      );
}

Widget sectionTitle(String t, {String? sub}) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        if (sub != null) Padding(padding: const EdgeInsets.only(top: 2), child: Text(sub, style: const TextStyle(color: g500, fontSize: 13))),
      ]),
    );

Widget demoBanner() => Container(
      width: double.infinity, color: g100, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: const Text('Prototype - fictional worker and jobs. Nothing is sent or saved.', style: TextStyle(color: g600, fontSize: 12), textAlign: TextAlign.center),
    );
