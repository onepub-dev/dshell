class AppWithArgs {
  AppWithArgs(this.cmdLine) {
    final parts = cmdLine.trim().split(' ');
    app = parts[0];

    if (parts.length > 1) {
      args = parts.sublist(1);
    } else {
      args = [];
    }
  }

  String cmdLine;
  late final String app;
  late final List<String> args;
}
