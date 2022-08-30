#! /usr/bin/env dcli

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:dshell/src/app_with_args.dart';
import 'package:dshell/src/pipe.dart';

void main(List<String> args) async {
  // Loop, asking for user input and evaluating it
  for (;;) {
    // print a > as a prompt
    stdout.write('${green(basename(pwd))}${blue('>')}');
    final commandLine = stdin.readLineSync() ?? '';
    if (commandLine.isNotEmpty) {
      await evaluate(commandLine);
    }
  }
}

// Evaluate the user's input
Future<void> evaluate(String commandLine) async {
  final apps = commandLine.split('|');
  if (apps.length == 1) {
    runApp(AppWithArgs(apps[0]));
    return;
  }

  if (apps.length == 2) {
    final app1 = AppWithArgs(apps[0]);
    final app2 = AppWithArgs(apps[1]);

    await simplePipe(app1, app2);
  } else {
    stderr.writeln('We only support piping 2 apps');
  }
}

void runApp(AppWithArgs appWithArgs) {
  switch (appWithArgs.app) {
    // list files in the current directory
    case 'ls':
      ls(appWithArgs.args);
      break;

    // change directories
    case 'cd':
      Directory.current = join(pwd, appWithArgs.args[0]);
      break;

    // treat the first word as the name of an app
    // and run it.
    default:
      if (which(appWithArgs.app).found) {
        // The run command is part of DCli and does all of the
        // plumbing for stding/stdout/stderr.
        run(appWithArgs.cmdLine);
      } else {
        stdout.writeln(red('Unknown command: ${appWithArgs.app}'));
      }
      break;
  }
}

/// our own implementation of the 'ls' command.
void ls(List<String> patterns) {
  if (patterns.isEmpty) {
    find('*',
            workingDirectory: pwd,
            recursive: false,
            types: [Find.file, Find.directory])
        .forEach((file) => stdout.writeln('  $file'));
  } else {
    for (final pattern in patterns) {
      find(pattern,
              workingDirectory: pwd,
              recursive: false,
              types: [Find.file, Find.directory])
          .forEach((file) => stdout.writeln('  $file'));
    }
  }
}
