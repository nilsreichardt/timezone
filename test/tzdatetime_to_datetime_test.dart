import 'package:cron_parser/cron_parser.dart';
import 'package:test/test.dart';
import 'package:timezone/standalone.dart';

void main() {
  group('MatchmakingCubit', () {
    group('.calcMatchmakingEndtime()', () {
      test('5h', () {
        expect(
            calcMatchmakingEndtime(
                DateTime(2021, 1, 1), const Duration(hours: 5)),
            DateTime(2021, 1, 1, 5));
      });

      test('1d', () {
        expect(
            calcMatchmakingEndtime(
                DateTime(2021, 1, 1), const Duration(days: 1)),
            DateTime(2021, 1, 2));
      });
    });

    group('.calcMatchmakingStart())', () {
      const timezone = "Europe/Berlin";

      test(
          'get previous cron time, if matchmaking already starting and is still going',
          () {
        final current = DateTime.parse('2019-11-23 12:00:00');
        final expected = DateTime.parse('2019-11-23 11:00:00');
        const duration = Duration(hours: 2);
        expect(
          calcMatchmakingStart(
            current,
            Cron().parse(
              '0 11 * * *',
              timezone,
              TZDateTime.from(
                  current, TZDateTime.now(getLocation(timezone)).location),
            ),
            duration,
          ),
          expected,
        );
      });

      test('get next cron time, if matchmaking ended', () {
        final current = DateTime.parse('2019-11-23 13:00:01');
        final expected = DateTime.parse('2019-11-24 11:00:00');
        const duration = Duration(hours: 2);
        expect(
          calcMatchmakingStart(
            current,
            Cron().parse(
              '0 11 * * *',
              timezone,
              TZDateTime.from(
                  current, TZDateTime.now(getLocation(timezone)).location),
            ),
            duration,
          ),
          expected,
        );
      });

      // Test for bug "app shoes matchmaking is started on 1. August, even if cron job is set to 7. August":
      // https://github.com/GatchHQ/gatch/issues/479
      test(
          'should start 7. August, if 7. August is set in the cron (0 19 7 8 *)',
          () {
        final current = DateTime.parse('2021-07-11 13:00:01');
        final expected = DateTime.parse('2021-08-07 19:00:00');
        const duration = Duration(hours: 2);
        expect(
          calcMatchmakingStart(
            current,
            Cron().parse(
              '0 19 7 8 *',
              timezone,
              TZDateTime.from(
                  current, TZDateTime.now(getLocation(timezone)).location),
            ),
            duration,
          ),
          expected,
        );
      });
    });
  });
}

DateTime calcMatchmakingStart(
    DateTime current, CronIterator<TZDateTime> cron, Duration duration) {
  final previous = cron.previous();
  if (previous.add(duration).isAfter(current)) {
    return previous;
  }
  return cron.next();
}

DateTime calcMatchmakingEndtime(DateTime start, Duration duration) {
  return start.add(duration);
}
