import 'dart:io';

import 'app_with_args.dart';

Future<void> pipe(AppWithArgs app1, AppWithArgs app2) async {
  final app1Process = await Process.start(app1.app, app1.args);
  final app2Process = await Process.start(app2.app, app2.args);

  // the output from app1 is sent to the input of app2
  await app1Process.stdout.pipe(app2Process.stdin).catchError(
    // ignore: avoid_types_on_closure_parameters
    (Object e) {
      // ignore broken pipe after app2 process exit
    },
    test: (e) =>
        e is SocketException &&
        (e.osError!.message == 'Broken pipe' ||
            e.osError!.message == 'StreamSink is closed'),
  );

  /// the output of app2 is sent to the console.
  /// We can't use the normal pipe command is it close the consumer (stdout)
  /// would would stop our app from outputing any further
  await pipeNoClose(app2Process.stdout, stdout);
}

Future<void> pipeNoClose(Stream<List<int>> stdout, IOSink stdin) async {
  await stdin.addStream(stdout);
}
