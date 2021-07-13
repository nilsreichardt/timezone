import 'package:test/test.dart';
import 'package:timezone/standalone.dart';

Future<void> main() async {
  await initializeTimeZone();

  const timezone = "Europe/Berlin";

  test(
      // ignore: lines_longer_than_80_chars
      'casting test', () {
    final current = DateTime.parse('2021-07-11 13:00:01');
    final expected = DateTime.parse('2021-07-11 13:00:01');
    expect(
      cast(
        TZDateTime.from(
            current, TZDateTime.now(getLocation(timezone)).location),
      ),
      expected,
    );
  });
}

DateTime cast(
  TZDateTime cron,
) {
  return cron;
}
