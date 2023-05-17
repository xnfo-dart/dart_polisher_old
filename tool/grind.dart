// The code was taken from dart_style package and modified by Xnfo.
// The dart_style package copyright notice is as follows:
//
// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "dart:convert";
import "dart:io";

import "package:grinder/grinder.dart";
import "package:pub_semver/pub_semver.dart";
import "package:yaml/yaml.dart" as yaml;
import "package:package_config/package_config.dart";
import "package:path/path.dart" as p;

import "package:node_preamble/preamble.dart" as preamble;

/// Matches the version line in dart_style"s pubspec.
final _versionPattern = RegExp(r"^version: .*$", multiLine: true);

void main(List<String> args) => grind(args);

@DefaultTask()
@Task("Local dev validation")
Future<void> validate() async
{
    // Test it.
    await TestRunner().testAsync();

    // Make sure it"s warning clean.
    Analyzer.analyze("bin/format.dart", fatalWarnings: true);

    // Format project.
    Dart.run("bin/format.dart", arguments: ["format", ".", "-s", "1", "-l", "90"]);

    // Check if we can get parse all dependencies versions used as constants.
    if (await getDependancyVersion("dart_style") == null)
    {
        throw "Cant parse all dependencies versions";
    }
}

@Task("Validation for Continuous Integration")
Future<void> validateCI() async
{
    // Test it.
    await TestRunner().testAsync();

    // Make sure it"s warning clean.
    Analyzer.analyze("bin/format.dart", fatalWarnings: true);

    // Style is applied when bumping.
}

@Task("Compile to native, use --output=filename")
@Depends(validateCI)
Future<void> build() async
{
    TaskArgs args = context.invocation.arguments;
    var outName = args.getOption("output");
    var verbose = !args.getFlag("quiet");

    // Get base normalized output Dir and File name from input.
    var outPath = FilePath(outName);
    if (outPath.parent != null) outName = outPath.name;
    var basePath = outPath.parent?.path ?? "";
    var outDirPath = p.normalize(joinDir(buildDir, [basePath]).path);
    var outDir = getDir(outDirPath);

    // Get pubspec executable targets names
    var pubspecFile = getFile("pubspec.yaml");
    var pubspec = pubspecFile.readAsStringSync();
    var pubspecMap = yaml.loadYaml(pubspec) as yaml.YamlMap;
    var pubspecExecutables = pubspecMap["executables"] as yaml.YamlMap;
    var defaultOutName = pubspecExecutables.keys
        .firstWhere((k) => pubspecExecutables[k] == "format", orElse: () => null);
    // Use default name from pubspec if not given
    outName ??= defaultOutName;

    // Setup file output to compile
    FilePath(outDir).createDirectory(recursive: true);
    var outFile = joinFile(outDir, [outName!]);
    var binFile = joinFile(binDir, ["format.dart"]);

    // There should be a Dart Compile method but there is not, so we run it manually.
    // (dart compile "-v" flag is not in help messages)
    run(dartVM.path,
        arguments: [
            "compile",
            "exe",
            binFile.path,
            "-o",
            outFile.path,
            verbose ? "-v" : "--verbosity=error"
        ],
        quiet: !verbose);
}

@Task("Compile to Node.js project flags: es-export (use ES export style)")
Future<void> node() async
{
    TaskArgs args = context.invocation.arguments;
    var esExport = args.getFlag("es-export"); // default is commonjs export.

    var out = FilePath("dist").join("node");
    out.createDirectory(recursive: true);
    var fileName = "index.js";

    var pubspecFile = getFile("pubspec.yaml");
    var pubspec = pubspecFile.readAsStringSync();
    var pubspecMap = yaml.loadYaml(pubspec) as Map;
    var repository = pubspecMap["repository"];

    var outFile = out.join(fileName).asFile;
    Dart2js.compile(File("tool/js_format_service.dart"), outFile: outFile);

    var dart2jsOutput = outFile.readAsStringSync();
    // ES export not needed except when using raw file import from ts.
    String moduleExport = esExport ? "export const JSDartPolisher = exports;\n" : "";
    // Fix for self https://github.com/sass/dart-sass/issues/621
    var nodePreamble = preamble.getPreamble();
    var replace = "var self = Object.create(dartNodePreambleSelf);";
    nodePreamble = nodePreamble.replaceFirst(
        replace, "//! $replace\nvar self = dartNodePreambleSelf;");
    outFile.writeAsStringSync("$moduleExport$nodePreamble$dart2jsOutput");

    File("$out/package.json")
        .writeAsStringSync(const JsonEncoder.withIndent("  ").convert({
        "name": "dart-polisher",
        "version": pubspecMap["version"],
        "description": "Customizable Dart source code formatter. "
            "Transpiled to node.js from dart_polisher (forked from dart_style)",
        "main": fileName,
        "typings": "dart-polisher.d.ts",
        "files": ["index.js", "*.d.ts"],
        "scripts": {"test": "echo 'Error: no test specified' && exit 1"},
        "repository": {"type": "git", "url": "$repository.git"},
        "author": "xnfo",
        "license": "BSD",
        "bugs": {"url": "$repository/issues"},
        "homepage": repository
    }));

    run("npm", arguments: ["pack", out.path, "--pack-destination", out.parent!.path]);

    log("Package for node had been created in: ${out.asDirectory.absolute}");
}

@Task("Publish Node.js package")
@Depends(node)
Future<void> nodePublish() async
{
    TaskArgs args = context.invocation.arguments;
    var force = args.getFlag("force"); // default is commonjs export.
    var dryrun = args.getFlag("dry-run"); // default is commonjs export.

    // Read the version from the pubspec.
    var pubspecFile = getFile("pubspec.yaml");
    var pubspec = pubspecFile.readAsStringSync();
    var version = Version.parse((yaml.loadYaml(pubspec) as Map)["version"] as String);

    // Warning using a "n.n.n-*" version
    if (version.isPreRelease && !force)
        throw "Warning publishing pre-release version $version."
            " Are you sure? use --force flag to confirm";

    // Warning for like "n.n.n+*" because it"s not clear if the
    // user intended the "+*" to be published or not.
    if (version.build.isNotEmpty && !force)
        throw "Warning publishing build version $version with"
            " ${version.build.reduce((v, e) => "$v $e")}."
            " Are you sure? use --force flag to confirm";

    var out = FilePath("dist").join("node");
    run("npm", arguments: ["publish", out.path, dryrun ? "--dry-run" : ""]);

    log("Package for node had been published: ${out.asDirectory.absolute}");
}

@Task("Build Node.js benchmark files")
Future<void> nodeBench() async
{
    var out = FilePath("build").join("node");
    out.createDirectory(recursive: true);

    // Benchmark Test '> node build/node/bench.js'
    // [dart 3.0] 8x slower than Compiled Dart :()
    // [dart 2.19] 10x slower than Compiled Dart :(

    var tempFile = File("${Directory.systemTemp.path}/dart_polish_bench.js");
    Dart2js.compile(File("benchmark/js/benchmark_js.dart"), outFile: tempFile);

    var dart2jsBenOutput = tempFile.readAsStringSync();
    var outFilePath = out.join("bench.js");
    File("$outFilePath").writeAsStringSync("${preamble.getPreamble()}$dart2jsBenOutput");

    log("Benchmark for node had been created in: ${outFilePath.asFile.absolute}");
}

/// Gets ready to publish a new version of the package.
///
/// To publish a version, you need to:
///
///   1. Make sure the version in the pubspec is a "-dev" number. This should
///      already be the case since you"ve already landed patches that change
///      the formatter and bumped to that as a consequence.
///
///   2. Commit to master
///
///      dart run grinder bump
///      git commit -a
///         Version $THE_VERSION_BEING_BUMPED
///
///   4. Tag the commit:
///
///         git tag -a "<version>" -m "<version>"
///         git push origin <version>
///
///   5. Publish the package: (not for now)
///
///         pub lish
@Task()
@Depends(validate)
Future<void> bump() async
{
    // Read the version from the pubspec.
    var pubspecFile = getFile("pubspec.yaml");
    var pubspec = pubspecFile.readAsStringSync();
    var version = Version.parse((yaml.loadYaml(pubspec) as Map)["version"] as String);

    // Require a "-dev" version since we don"t otherwise know what to bump it to.
    if (!version.isPreRelease) throw "Cannot publish non-dev version $version.";

    // Don"t allow versions like "1.2.3-dev+4" because it"s not clear if the
    // user intended the "+4" to be discarded or not.
    if (version.build.isNotEmpty) throw "Cannot publish build version $version.";

    var bumped = Version(version.major, version.minor, version.patch);

    // Update the version in the pubspec.
    pubspec = pubspec.replaceAll(_versionPattern, "version: $bumped");
    pubspecFile.writeAsStringSync(pubspec);

    // Update the version constants in formatter_constants.dart.
    var versionFile = getFile("lib/src/dp_constants.dart");
    var versionSource = versionFile.readAsStringSync();
    var versionReplaced = updateVersionConstant(versionSource, "VERSION", bumped);
    // Update the version dependencies in dp_constants.dart.
    var dartStyleVersion = await getDependancyVersion("dart_style");
    if (dartStyleVersion != null)
    {
        versionReplaced = updateVersionConstant(
            versionReplaced, "DART_STYLE_DEP_VERSION", dartStyleVersion);
        versionFile.writeAsStringSync(versionReplaced);
    }
    versionFile.writeAsStringSync(versionReplaced);

    // Update the version in the CHANGELOG.
    // TODO(tekert): create bump header and move Unreleased header
    var changelogFile = getFile("CHANGELOG.md");
    var changelog = changelogFile
        .readAsStringSync()
        .replaceAll(version.toString(), bumped.toString());
    changelogFile.writeAsStringSync(changelog);

    log("Updated version to \"$bumped\".");
}

String updateVersionConstant(String source, String constant, Version v)
{
    return source.replaceAll(RegExp("""const String $constant = "[^"]+";"""),
        """const String $constant = "$v";""");
}

Future<Version?> getDependancyVersion(String packageName) async
{
    var packageConfig = await findPackageConfig(Directory(""),
        recurse: false,
        onError: (error) => print("Could not find package config file: $error"));

    if (packageConfig == null) return null;

    Package package;
    try
    {
        package =
            packageConfig.packages.firstWhere((element) => element.name == packageName);
    }
    catch (e)
    {
        print("Package not found: $packageName");
        return null;
    }

    // Get the dependency package pubspec file.
    Version version;
    try
    {
        final pubspecFile = getFile(p.join(p.fromUri(package.root), "pubspec.yaml"));
        final pubspec = pubspecFile.readAsStringSync();
        version = Version.parse((yaml.loadYaml(pubspec) as Map)["version"] as String);
    }
    catch (e)
    {
        print("Package $packageName pubspec.yaml: $e");
        return null;
    }

    return version;
}
