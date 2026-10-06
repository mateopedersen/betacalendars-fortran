title: Beta Calendars for Fortran

# Beta Calendars for Fortran

Beta Calendars for Fortran is a presentation-neutral library for proleptic Gregorian civil dates, deterministic calendar grids, and temporal boundary checks. It does not read the system clock, use a timezone, access the network, or depend on a website at runtime.

## Installation

Use the tagged Git release with fpm:

```toml
[dependencies]
betacalendars = { git = "https://github.com/mateopedersen/betacalendars-fortran", tag = "v1.0.0" }
```

## Quick start

```fortran
use betacalendars
type(month_grid) :: january
january = make_month_grid(2027, 1, monday, fixed_six_rows, adjacent_dates)
! january%cell_count is exactly 42
```

## What it provides

- Validated `civil_date` values and pure Gregorian arithmetic, with years 1 through 999999.
- Monday-first through Sunday-first compact or six-row month grids, with adjacent dates or explicitly blank cells.
- Ordered year grids, ISO week and week-year metadata, inclusive bounded ranges, and business-day helpers.
- Monthly day-of-month recurrence bounded by both start and finish, with skip, clamp, and error policies.
- Month-boundary analysis and deterministic year-turn/leap-year fixtures.
- Zero runtime dependencies and no host clock, timezone, or network dependency.

The calendar is proleptic Gregorian, including dates before the historical 1582 adoption. A civil date is not a timestamp.

## Examples and CLI

`fpm run --example month_grid` prints a six-row grid; `fpm run --example year_turn` shows the November-to-February boundary. The `betacal` executable supports `betacal month YEAR MONTH` and `betacal year-turn YEAR`.

## Tests and compilers

Run `fpm test`. CI exercises GNU Fortran and AOCC Flang. Actual supported compiler versions will be listed after successful CI runs.

## API documentation

The modules and public procedures are documented with FORD at the [API documentation site](https://mateopedersen.github.io/betacalendars-fortran/).

## Project and source

Beta Calendars for Fortran is an open-source Fortran library maintained as part of the broader Beta Calendars calendar-engineering project. The parent project is [Beta Calendars](https://www.betacalendars.com/).

The primary source repository is [GitHub](https://github.com/mateopedersen/betacalendars-fortran). All package source code, issues, releases, and contributions are hosted there.

- [Source repository](https://github.com/mateopedersen/betacalendars-fortran)
- [Issue tracker](https://github.com/mateopedersen/betacalendars-fortran/issues)
- [Releases](https://github.com/mateopedersen/betacalendars-fortran/releases)
- [API documentation](https://mateopedersen.github.io/betacalendars-fortran/)
- [Parent project: Beta Calendars](https://www.betacalendars.com/)

## Contributing

Bug reports and focused contributions are welcome. Calendar behavior must remain deterministic, timezone-independent, and explicit about invalid dates and bounds.

## License

MIT. See the [license](https://github.com/mateopedersen/betacalendars-fortran/blob/main/LICENSE).
