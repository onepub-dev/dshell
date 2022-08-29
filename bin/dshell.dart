#! /usr/bin/env dcli

import 'dart:io';

import 'package:dcli/dcli.dart';

void main(List<String> args) {
  // Loop, asking for user input and evaluating it
  for (;;) {
    // print a > as a prompt
    stdout.write('${green(basename(pwd))}${blue('>')}');
    final line = stdin.readLineSync() ?? '';
    if (line.isNotEmpty) {
      evaluate(line);
    }
  }
}

// Evaluate the users input
void evaluate(String command) {
  final parts = command.split(' ');
  switch (parts[0]) {
    // list files in the current directory
    case 'ls':
      ls(parts.sublist(1));
      break;

    // change directories
    case 'cd':
      Directory.current = join(pwd, parts[1]);
      break;

    // treat the first word as the name of an app
    // and run it.
    default:
      if (which(parts[0]).found) {
        // The run command is part of DCli and does all of the
        // plumbing for stding/stdout/stderr.
        run(command);
      } else {
        print(red('Unknown command: ${parts[0]}'));
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
        types: [Find.file, Find.directory]).forEach((file) => print('  $file'));
  } else {
    for (final pattern in patterns) {
      find(pattern,
              workingDirectory: pwd,
              recursive: false,
              types: [Find.file, Find.directory])
          .forEach((file) => print('  $file'));
    }
  }
}
