// Faithful Dart port of flutter-clean-arch-audit/scripts/audit_flutter_arch.py
// (python is not installed on this machine). Usage:
//   dart run audit_flutter_arch.dart <root> [--json out.json] [--md out.md] [--no-dio-rule]
import 'dart:convert';
import 'dart:io';

const sevWeight = {'error': 5, 'warning': 2, 'info': 0};

class Finding {
  Finding(this.id, this.severity, this.file, this.line, this.message, [this.feature]);
  final String id, severity, file, message;
  final int? line;
  final String? feature;
  Map<String, dynamic> toJson() => {
        'id': id, 'severity': severity, 'file': file, 'line': line,
        'message': message, 'feature': feature,
      };
}

class Report {
  Report(this.project);
  final String project;
  final features = <String>[];
  final findings = <Finding>[];
  void add(String id, String sev, String file, int? line, String msg, [String? feat]) =>
      findings.add(Finding(id, sev, file, line, msg, feat));
  int count(String s) => findings.where((f) => f.severity == s).length;
  int score() {
    final p = findings.fold<int>(0, (a, f) => a + sevWeight[f.severity]!);
    return p >= 100 ? 0 : 100 - p;
  }
}

final snake = RegExp(r'^[a-z][a-z0-9_]*\.dart$');
final classRe = RegExp(r'^\s*(?:abstract\s+|sealed\s+|final\s+|base\s+)?class\s+([A-Za-z0-9_]+)', multiLine: true);
final importRe = RegExp(r"^\s*import\s+'([^']+)'", multiLine: true);
const rootAllowed = {'main.dart', 'app.dart', 'bootstrap.dart', 'firebase_options.dart'};
const aliases = {
  'datasource': 'data_sources', 'datasources': 'data_sources', 'data_source': 'data_sources', 'sources': 'data_sources',
  'model': 'models', 'dto': 'models', 'dtos': 'models',
  'repository': 'repositories', 'repo': 'repositories', 'repos': 'repositories',
  'entity': 'entities',
  'usecase': 'use_cases', 'usecases': 'use_cases', 'use_case': 'use_cases',
  'bloc': 'logic', 'blocs': 'logic', 'cubit': 'logic', 'cubits': 'logic', 'state': 'logic', 'manager': 'logic', 'controllers': 'logic', 'controller': 'logic',
  'screens': 'screen', 'pages': 'screen', 'page': 'screen', 'views': 'screen', 'view': 'screen', 'ui': 'screen',
  'widgets': 'widget', 'components': 'widget',
};
const layerRequired = {
  'data': ['data_sources', 'models', 'repositories'],
  'domain': ['entities', 'repositories', 'use_cases'],
  'presentation': ['logic', 'screen', 'widget'],
};
const suffixRules = {
  'data|data_sources': ['_data_source.dart'],
  'data|repositories': ['_repository_impl.dart'],
  'data|models': ['_model.dart'],
  'domain|repositories': ['_repository.dart'],
  'domain|use_cases': ['_use_case.dart'],
  'presentation|logic': ['_cubit.dart', '_bloc.dart', '_state.dart', '_event.dart'],
  'presentation|screen': ['_screen.dart', '_sheet.dart', '_dialog.dart', '_view.dart', '_tab.dart'],
};
const coreExpected = [
  'constants/api_endpoints.dart', 'constants/app_assets.dart', 'constants/app_routes.dart',
  'errors/failures.dart', 'errors/exceptions.dart', 'network/http_helper.dart',
  'storage/storage_helper.dart', 'di/service_locator.dart', 'routing/app_router.dart',
];
const pubspecExpected = ['get_it', 'go_router', 'flutter_bloc', 'flutter_secure_storage', 'equatable'];
final secretPatterns = [
  (RegExp(r'AIza[0-9A-Za-z\-_]{30,}'), 'Google API key'),
  (RegExp(r'sk_(live|test)_[0-9A-Za-z]{16,}'), 'Stripe secret key'),
  (RegExp(r'''(api[_-]?key|secret|password)\s*[:=]\s*['"][^'"]{8,}['"]''', caseSensitive: false), 'inline credential'),
  (RegExp(r'eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{20,}'), 'hardcoded JWT'),
];

late String rootPath;
String rel(String p) => p.substring(rootPath.length + 1).replaceAll('\\', '/');
String norm(String p) => p.replaceAll('\\', '/');
String read(String p) {
  try {
    return File(p).readAsStringSync();
  } catch (_) {
    try {
      return latin1.decode(File(p).readAsBytesSync());
    } catch (_) {
      return '';
    }
  }
}
int lineOf(String t, int idx) => '\n'.allMatches(t.substring(0, idx)).length + 1;
String baseName(String p) => norm(p).split('/').last;
String pascal(String s) => s.replaceAll('.dart', '').split('_').map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1).toLowerCase()).join();
List<Directory> dirs(Directory d) => d.listSync().whereType<Directory>().toList();
List<File> dartFiles(Directory d) => d.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')).toList();
bool gitTracked(String name) {
  final r = Process.runSync('git', ['ls-files', '--error-unmatch', '--', '*$name'], workingDirectory: rootPath);
  return r.exitCode == 0 && (r.stdout as String).trim().isNotEmpty;
}

void checkStructure(Directory lib, Report r) {
  final core = Directory('${lib.path}/core'), feats = Directory('${lib.path}/features');
  if (!core.existsSync()) r.add('S01', 'error', 'lib/core', null, 'lib/core is missing — all shared code must live here');
  if (!feats.existsSync()) {
    r.add('S02', 'error', 'lib/features', null, 'lib/features is missing — every feature must live here');
    return;
  }
  for (final p in lib.listSync()) {
    final n = baseName(p.path);
    if (p is File && n.endsWith('.dart') && !rootAllowed.contains(n)) {
      r.add('S06', 'warning', rel(p.path), null, 'Dart file at lib/ root — move into core/ or a feature');
    }
  }
  for (final p in dirs(lib)) {
    final n = baseName(p.path);
    if (!{'core', 'features', 'l10n', 'generated'}.contains(n)) {
      r.add('S07', 'warning', rel(p.path), null, 'lib/$n/ is outside core/ and features/ — decide where its contents belong');
    }
  }
  final fs = dirs(feats)..sort((a, b) => a.path.compareTo(b.path));
  for (final f in fs) {
    checkFeature(f, r);
  }
}

void checkFeature(Directory feat, Report r) {
  final name = baseName(feat.path);
  r.features.add(rel(feat.path));
  final present = dirs(feat).map((d) => baseName(d.path)).toSet();
  for (final layer in ['data', 'domain', 'presentation']) {
    if (!present.contains(layer)) {
      r.add('S03', 'error', rel(feat.path), null, "feature '$name' has no $layer/ layer", name);
      continue;
    }
    final layerDir = Directory('${feat.path}/$layer');
    final sub = dirs(layerDir).map((d) => baseName(d.path)).toSet();
    for (final wrong in sub) {
      final canon = aliases[wrong];
      if (canon != null && canon != wrong) {
        r.add('S04', 'error', rel('${layerDir.path}/$wrong'), null, "folder '$wrong' should be '$canon'", name);
      }
    }
    for (final req in layerRequired[layer]!) {
      if (!sub.contains(req) && !sub.any((s) => aliases[s] == req)) {
        final sev = layer == 'presentation' && req == 'widget' ? 'warning' : 'error';
        r.add('S03', sev, rel(layerDir.path), null, '$layer/ is missing $req/', name);
      }
    }
  }
  for (final w in ['${name}_injection.dart', '${name}_routes.dart']) {
    if (!File('${feat.path}/$w').existsSync()) {
      r.add('S05', 'warning', rel('${feat.path}/$w'), null, "missing $w — DI/routes for '$name' are probably inlined in core", name);
    }
  }
  for (final d in dirs(feat)) {
    final n = baseName(d.path);
    if (!{'data', 'domain', 'presentation'}.contains(n)) {
      if (['data', 'domain', 'presentation'].any((l) => Directory('${d.path}/$l').existsSync())) checkFeature(d, r);
    }
  }
}

List<String> partsUnderLib(Directory lib, File f) => norm(f.path).substring(norm(lib.path).length + 1).split('/');

void checkNaming(Directory lib, Report r) {
  for (final p in dartFiles(lib)) {
    final n = baseName(p.path);
    final parts = partsUnderLib(lib, p);
    if (n.contains('.g.dart') || n.contains('.freezed.dart') || parts.contains('generated')) continue;
    if (!snake.hasMatch(n)) r.add('N01', 'error', rel(p.path), null, 'file name is not snake_case');
    if (parts.length >= 4 && parts[0] == 'features') {
      for (var i = parts.length - 3; i > 0; i--) {
        final key = '${parts[i]}|${parts[i + 1]}';
        final sfx = suffixRules[key];
        if (sfx != null) {
          if (!sfx.any(n.endsWith)) r.add('N02', 'warning', rel(p.path), null, 'expected suffix ${sfx.join(' or ')}');
          break;
        }
      }
    }
    final text = read(p.path);
    final m = classRe.firstMatch(text);
    if (m != null) {
      final cls = m.group(1)!, expect = pascal(n);
      if (cls != expect && !cls.startsWith(expect.replaceAll('Impl', ''))) {
        r.add('N03', 'info', rel(p.path), lineOf(text, m.start), "first class is '$cls', file name suggests '$expect'");
      }
    }
  }
}

void checkDependencies(Directory lib, Report r) {
  final cf = RegExp(r'features/([a-z0-9_]+)/(data|presentation)/');
  for (final p in dartFiles(lib)) {
    final raw = partsUnderLib(lib, p);
    if (raw.contains('generated')) continue;
    final parts = raw.map((x) => aliases[x] ?? x).toList();
    if (parts[0] != 'features') continue;
    final text = read(p.path);
    final feat = parts[1];
    final layer = parts.cast<String?>().firstWhere((x) => ['data', 'domain', 'presentation'].contains(x), orElse: () => null);
    for (final m in importRe.allMatches(text)) {
      final imp = m.group(1)!, ln = lineOf(text, m.start);
      final nm = imp.replaceAll('package:', '');
      if (layer == 'domain') {
        if (nm.contains('/data/') || nm.startsWith('../data') || nm.contains('/presentation/') || nm.startsWith('../presentation')) {
          r.add('D01', 'error', rel(p.path), ln, 'domain imports outer layer: $imp', feat);
        }
        if (nm.startsWith('flutter/material') || nm.startsWith('flutter/widgets') || nm.startsWith('flutter/cupertino')) {
          r.add('D02', 'error', rel(p.path), ln, 'domain imports Flutter widgets — entities and use cases must be pure Dart', feat);
        }
      }
      if (layer == 'presentation') {
        if (nm.contains('/data/') || nm.startsWith('../data') || nm.startsWith('../../data')) {
          r.add('D03', 'error', rel(p.path), ln, 'presentation imports data layer: $imp — use the entity and the use case', feat);
        }
      }
      final c = cf.firstMatch(nm);
      if (c != null && c.group(1) != feat && !parts.contains(c.group(1))) {
        r.add('D07', 'warning', rel(p.path), ln,
            "reaches into feature '${c.group(1)}' ${c.group(2)}/ — shared UI belongs in core/widgets, shared domain in a parent feature", feat);
      }
    }
    if (layer == 'data' && parts.contains('data_sources') && RegExp(r'\bEither\s*<').hasMatch(text)) {
      r.add('D04', 'error', rel(p.path), null, 'data source returns Either — data sources throw, repositories wrap', feat);
    }
    if (layer == 'data' && parts.contains('repositories') && !text.contains('try')) {
      r.add('D05', 'warning', rel(p.path), null, 'repository impl has no try/catch — exceptions will leak past the domain boundary', feat);
    }
    if (layer == 'domain' && parts.contains('repositories')) {
      final m = classRe.firstMatch(text);
      if (m != null) {
        final s = m.start - 40 < 0 ? 0 : m.start - 40;
        final e = m.start + 10 > text.length ? text.length : m.start + 10;
        if (!text.substring(s, e).contains('abstract')) {
          r.add('D06', 'warning', rel(p.path), lineOf(text, m.start), 'domain repository is not abstract', feat);
        }
      }
    }
    if (layer == 'data' && parts.contains('models')) {
      final m = classRe.firstMatch(text);
      if (m != null) {
        final e = m.start + 200 > text.length ? text.length : m.start + 200;
        final w = text.substring(m.start, e);
        if (!w.contains('extends') && !w.contains('implements')) {
          r.add('C17', 'warning', rel(p.path), lineOf(text, m.start), 'model does not extend/implement its entity', feat);
        }
      }
      if (!text.contains('fromJson')) r.add('C17', 'info', rel(p.path), null, 'model has no fromJson', feat);
    }
    if (layer == 'domain' && parts.contains('entities') && !text.contains('copyWith') && !text.contains('enum ')) {
      r.add('C18', 'info', rel(p.path), null, 'entity has no copyWith', feat);
    }
    if (layer == 'presentation' && parts.contains('screen')) {
      final n = RegExp(r'\bsetState\s*\(').allMatches(text).length;
      if (n >= 3) r.add('C15', 'info', rel(p.path), null, '$n setState calls in a screen — state probably belongs in a cubit', feat);
    }
  }
}

void checkHygiene(Directory lib, Report r, bool dioRule) {
  final core = Directory('${lib.path}/core');
  final coreFiles = core.existsSync() ? dartFiles(core).map((f) => baseName(f.path)).toList() : <String>[];
  for (final rp in coreExpected) {
    if (!File('${core.path}/$rp').existsSync()) {
      final stem = baseName(rp).replaceAll('.dart', '');
      if (!coreFiles.any((n) => n.contains(stem))) {
        r.add('C13', 'warning', 'lib/core/$rp', null, 'expected core module missing: $rp');
      }
    }
  }
  final url = RegExp(r'''['"]https?://[^'"]+['"]''');
  final asset = RegExp(r'''['"]assets/[^'"]+['"]''');
  final imgNet = RegExp(r'\bImage\.network\s*\(');
  final prnt = RegExp(r'(?<![\w.])print\s*\(');
  final c06 = RegExp(r'(setString|write)\s*\(\s*[^,]*([Tt][Oo][Kk][Ee][Nn]|[Pp][Aa][Ss][Ss][Ww][Oo][Rr][Dd]|[Ss][Ee][Cc][Rr][Ee][Tt])[^,]*,');
  for (final p in dartFiles(lib)) {
    if (partsUnderLib(lib, p).contains('generated')) continue;
    final text = read(p.path), rp = rel(p.path), n = baseName(p.path);
    final inConfig = rp.contains('core/config') || rp.contains('core/constants') || n.contains('firebase_options');
    for (final m in url.allMatches(text)) {
      if (!inConfig) r.add('C01', 'error', rp, lineOf(text, m.start), 'hardcoded URL — move to ApiEndpoints / AppConfig');
    }
    for (final m in asset.allMatches(text)) {
      if (!n.contains('app_assets')) r.add('C02', 'warning', rp, lineOf(text, m.start), 'hardcoded asset path — move to AppAssets');
    }
    for (final m in imgNet.allMatches(text)) {
      r.add('C03', 'warning', rp, lineOf(text, m.start), 'Image.network — use the core image helper (caching + error state)');
    }
    for (final m in prnt.allMatches(text)) {
      r.add('C04', 'warning', rp, lineOf(text, m.start), 'print() — use the redacting logger');
    }
    if (dioRule && RegExp(r"import\s+'package:dio/").hasMatch(text)) {
      r.add('C05', 'warning', rp, null, 'Dio import — house rule is package:http behind HttpHelper');
    }
    for (final m in c06.allMatches(text)) {
      if (!text.toLowerCase().contains('secure')) {
        r.add('C06', 'error', rp, lineOf(text, m.start), 'token/secret written to plain storage — must go through secure storage');
      }
    }
    if (text.contains('flutter_dotenv')) r.add('C07', 'warning', rp, null, 'flutter_dotenv — house rule is --dart-define-from-file with const AppConfig');
    if (RegExp(r"import\s+'package:dartz/").hasMatch(text)) r.add('C12', 'warning', rp, null, 'dartz import — migrate to fpdart (dartz is unmaintained)');
    if (text.contains('easy_localization')) r.add('C11', 'info', rp, null, 'easy_localization — house rule is gen-l10n (compile-time checked)');
    for (final (pat, label) in secretPatterns) {
      for (final m in pat.allMatches(text)) {
        r.add('C10', 'error', rp, lineOf(text, m.start), 'possible $label in source');
      }
    }
  }
  if (File('${lib.path}/main_dev.dart').existsSync() || File('${lib.path}/main_prod.dart').existsSync()) {
    r.add('C08', 'info', 'lib/main_*.dart', null, 'flavor entrypoints found — house rule is a single main.dart + --dart-define-from-file');
  }
  for (final g in ['android/app/build.gradle', 'android/app/build.gradle.kts']) {
    final f = File('$rootPath/$g');
    if (f.existsSync() && read(f.path).contains('productFlavors')) {
      r.add('C08', 'info', g, null, 'productFlavors configured — house rule avoids flavors');
    }
  }
  final gi = read('$rootPath/.gitignore');
  for (final must in ['.env', 'google-services.json', 'GoogleService-Info.plist', 'key.properties']) {
    if (!gi.contains(must)) r.add('C09', 'error', '.gitignore', null, "'$must' is not ignored");
  }
  for (final t in ['google-services.json', 'GoogleService-Info.plist', '.env', 'key.properties']) {
    if (gitTracked(t)) r.add('C09', 'error', t, null, '$t is tracked by git — remove from history');
  }
  final pub = read('$rootPath/pubspec.yaml');
  for (final pkg in pubspecExpected) {
    if (!RegExp('^\\s+${RegExp.escape(pkg)}\\s*:', multiLine: true).hasMatch(pub)) {
      r.add('C14', 'warning', 'pubspec.yaml', null, 'expected dependency missing: $pkg');
    }
  }
  if (!RegExp(r'^\s+(fpdart|dartz)\s*:', multiLine: true).hasMatch(pub)) {
    r.add('C14', 'warning', 'pubspec.yaml', null, 'no Either package (fpdart) — how are failures returned?');
  }
  if (!File('$rootPath/.env.example').existsSync()) {
    r.add('C09', 'warning', '.env.example', null, "no .env.example — new developers can't discover required keys");
  }
  final tests = Directory('$rootPath/test');
  final testFiles = tests.existsSync()
      ? tests.listSync(recursive: true).map((e) => norm(e.path)).toList()
      : <String>[];
  if (!testFiles.any((p) => p.endsWith('_test.dart'))) {
    r.add('C19', 'warning', 'test/', null, 'no tests found');
  } else {
    final tf = Directory('$rootPath/test/features');
    final featTests = tf.existsSync() ? tf.listSync(recursive: true).map((e) => baseName(e.path)).toList() : <String>[];
    for (final f in r.features) {
      final fname = baseName(f);
      if (!tf.existsSync() || !featTests.any((n) => n.contains(fname))) {
        r.add('C19', 'info', 'test/features/$fname', null, "no tests for feature '$fname'", fname);
      }
    }
  }
}

String toMarkdown(Report r) {
  final b = StringBuffer()
    ..writeln('# Architecture audit — ${r.project}')
    ..writeln()
    ..writeln('**Score: ${r.score()}/100** · errors ${r.count('error')} · warnings ${r.count('warning')} · info ${r.count('info')}')
    ..writeln()
    ..writeln('Features found: ${r.features.map(baseName).join(', ')}')
    ..writeln();
  for (final sev in ['error', 'warning', 'info']) {
    final g = r.findings.where((f) => f.severity == sev).toList()
      ..sort((a, c) => a.id != c.id ? a.id.compareTo(c.id) : a.file.compareTo(c.file));
    if (g.isEmpty) continue;
    b
      ..writeln('## ${sev.toUpperCase()} (${g.length})')
      ..writeln()
      ..writeln('| Rule | File | Line | Message |')
      ..writeln('|---|---|---|---|');
    for (final f in g) {
      b.writeln('| ${f.id} | `${f.file}` | ${f.line ?? ''} | ${f.message.replaceAll('|', '\\|')} |');
    }
    b.writeln();
  }
  final byRule = <String, int>{};
  for (final f in r.findings) {
    byRule[f.id] = (byRule[f.id] ?? 0) + 1;
  }
  b..writeln('## By rule')..writeln();
  for (final e in byRule.entries.toList()..sort((a, c) => c.value.compareTo(a.value))) {
    b.writeln('- ${e.key}: ${e.value}');
  }
  return b.toString();
}

void main(List<String> args) {
  String? jsonOut, mdOut;
  var dio = true;
  String? root;
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--json') {
      jsonOut = args[++i];
    } else if (args[i] == '--md') {
      mdOut = args[++i];
    } else if (args[i] == '--no-dio-rule') {
      dio = false;
    } else {
      root = args[i];
    }
  }
  rootPath = Directory(root!).absolute.path.replaceAll(RegExp(r'[\\/]\.?$'), '');
  final lib = Directory('$rootPath/lib');
  if (!File('$rootPath/pubspec.yaml').existsSync() || !lib.existsSync()) {
    stderr.writeln('not a Flutter project root');
    exit(2);
  }
  final r = Report(baseName(rootPath));
  checkStructure(lib, r);
  checkNaming(lib, r);
  checkDependencies(lib, r);
  checkHygiene(lib, r, dio);
  final md = toMarkdown(r);
  if (mdOut != null) File(mdOut).writeAsStringSync(md);
  if (jsonOut != null) {
    File(jsonOut).writeAsStringSync(const JsonEncoder.withIndent('  ').convert({
      'project': r.project, 'score': r.score(), 'features': r.features,
      'findings': r.findings.map((f) => f.toJson()).toList(),
    }));
  }
  stdout.writeln('score=${r.score()} errors=${r.count('error')} warnings=${r.count('warning')} info=${r.count('info')}');
  exit(r.count('error') > 0 ? 1 : 0);
}
