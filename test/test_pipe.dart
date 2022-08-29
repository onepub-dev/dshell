import 'dart:io';

Future<void> main() async {
  final ls = await Process.start('ls', []);
  final head = await Process.start('head', ['-1']);

  // the output from ls is sent to the input of head
  await ls.stdout.pipe(head.stdin).catchError(
    // ignore: avoid_types_on_closure_parameters
    (Object e) {
      // ignore broken pipe after head process exit
    },
    test: (e) => e is SocketException && (e.osError!.message == 'Broken pipe'),
  );

  /// the output of head is sent to the console.
  /// We can't use the normal pipe command is it will close stdout
  /// which will stop our app from outputting any further text to stdout.
  await pipeNoClose(head.stdout, stdout);

  print('done');
}

Future<void> pipeNoClose(Stream<List<int>> stdout, IOSink stdin) async =>
    stdin.addStream(stdout);
