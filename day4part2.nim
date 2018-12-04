import algorithm
import strscans
import sequtils
import strutils
import tables

type Guard = int
type Entry = tuple[year: int, month: int, day: int, hour: int, minute: int]
type GuardSleepEntry = tuple[guard: Guard, minute: int]


proc generateSleepTables(lines: seq[string]): CountTable[GuardSleepEntry] =
    var currentGuard: Guard = -1;

    result = initCountTable[GuardSleepEntry]()

    var entry: Entry;
    var sleepStart: Entry;
    var sleepEnd: Entry

    for line in lines.sorted(cmp):
        if(scanf(line, "[$i-$i-$i $i:$i] Guard #$i begins shift", entry.year, entry.month, entry.day, entry.hour, entry.minute, currentGuard)):
            discard
        elif(scanf(line, "[$i-$i-$i $i:$i] falls asleep", entry.year, entry.month, entry.day, entry.hour, entry.minute)):
            sleepStart = entry
        elif(scanf(line, "[$i-$i-$i $i:$i] wakes up", entry.year, entry.month, entry.day, entry.hour, entry.minute)):
            sleepEnd = entry

            # verify no cross day entries
            assert(sleepEnd.year == sleepStart.year)
            assert(sleepEnd.month == sleepStart.month)
            assert(sleepEnd.day == sleepStart.day)

            for i in countup(sleepStart.minute, sleepEnd.minute - 1):
                result.inc((currentGuard, i))


proc mostSleepyOverall(lines: seq[string]): int =
    var sleepCounts = generateSleepTables(lines)

    # find guard who is asleep the most in a given minute
    var mostSleepy: GuardSleepEntry = sleepCounts.largest().key
    return mostSleepy.guard * mostSleepy.minute


assert(mostSleepyOverall("""[1518-11-01 00:00] Guard #10 begins shift
[1518-11-01 00:05] falls asleep
[1518-11-01 00:25] wakes up
[1518-11-01 00:30] falls asleep
[1518-11-01 00:55] wakes up
[1518-11-01 23:58] Guard #99 begins shift
[1518-11-02 00:40] falls asleep
[1518-11-02 00:50] wakes up
[1518-11-03 00:05] Guard #10 begins shift
[1518-11-03 00:24] falls asleep
[1518-11-03 00:29] wakes up
[1518-11-04 00:02] Guard #99 begins shift
[1518-11-04 00:36] falls asleep
[1518-11-04 00:46] wakes up
[1518-11-05 00:03] Guard #99 begins shift
[1518-11-05 00:45] falls asleep
[1518-11-05 00:55] wakes up""".splitLines) == 4455)

echo mostSleepyOverall(toSeq(stdin.lines))