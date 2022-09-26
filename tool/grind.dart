// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:grinder/grinder.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart' as yaml;
import 'package:package_config/package_config.dart';
import 'package:path/path.dart' as p;

/// Matches the version line in dart_style's pubspec.
final _versionPattern = RegExp(r'^version: .*$', multiLine: true);

void main(List<String> args) => grind(args);

@DefaultTask()
@Task()
Future<void> validate() async
{
    // Test it.
    //await TestRunner().testAsync();

    // Make sure it's warning clean.
    Analyzer.analyze('bin/format.dart', fatalWarnings: true);

    // Format it.
    Dart.run('bin/format.dart',
        arguments: ['format', './benchmark/after.dart.txt', '-o', 'none']);

    // Check if we can get parse all dependencys versions used as constants.
    if (await getDependancyVersion("dart_style") == null)
    {
        throw "Cant parse all dependencys versions";
    }
}

/// Gets ready to publish a new version of the package.
///
/// To publish a version, you need to:
///
///   1. Make sure the version in the pubspec is a "-dev" number. This should
///      already be the case since you've already landed patches that change
///      the formatter and bumped to that as a consequence.
///
///   2. Run this task:
///
///         dart run grinder bump
///
///   3. Commit the change to a branch.
///
///   4. Send it out for review:
///
///         git cl upload
///
///   5. After the review is complete, land it:
///
///         git cl land
///
///   6. Tag the commit:
///
///         git tag -a "<version>" -m "<version>"
///         git push origin <version>
///
///   7. Publish the package:
///
///         pub lish
@Task()
@Depends(validate)
Future<void> bump() async
{
    // Read the version from the pubspec.
    var pubspecFile = getFile('pubspec.yaml');
    var pubspec = pubspecFile.readAsStringSync();
    var version = Version.parse((yaml.loadYaml(pubspec) as Map)['version'] as String);

    // Require a "-dev" version since we don't otherwise know what to bump it to.
    if (!version.isPreRelease) throw 'Cannot publish non-dev version $version.';

    // Don't allow versions like "1.2.3-dev+4" because it's not clear if the
    // user intended the "+4" to be discarded or not.
    if (version.build.isNotEmpty) throw 'Cannot publish build version $version.';

    var bumped = Version(version.major, version.minor, version.patch);

    // Update the version in the pubspec.
    pubspec = pubspec.replaceAll(_versionPattern, 'version: $bumped');
    pubspecFile.writeAsStringSync(pubspec);

    // Update the version constants in formatter_constants.dart.
    var versionFile = getFile('lib/src/formatter_constants.dart');
    var versionSource = versionFile.readAsStringSync();
    var versionReplaced =
        updateVersionConstant(versionSource, "FORMATTER_VERSION", bumped);
    // Update the version constants dependencys in formatter_constants.dart.
    var dartStyleVersion = await getDependancyVersion("dart_style");
    if (dartStyleVersion != null)
    {
        versionReplaced = updateVersionConstant(
            versionReplaced, "DART_STYLE_DEP_VERSION", dartStyleVersion);
        versionFile.writeAsStringSync(versionReplaced);
    }
    versionFile.writeAsStringSync(versionReplaced);

    // Update the version in the CHANGELOG.
    var changelogFile = getFile('CHANGELOG.md');
    var changelog = changelogFile
        .readAsStringSync()
        .replaceAll(version.toString(), bumped.toString());
    changelogFile.writeAsStringSync(changelog);

    log("Updated version to '$bumped'.");
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
        final pubspecFile = getFile(p.join(p.fromUri(package.root), 'pubspec.yaml'));
        final pubspec = pubspecFile.readAsStringSync();
        version = Version.parse((yaml.loadYaml(pubspec) as Map)['version'] as String);
    }
    catch (e)
    {
        print("Package $packageName pubspec.yaml: $e");
        return null;
    }

    return version;
}
