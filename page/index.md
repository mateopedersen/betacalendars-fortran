# Beta Calendars for Fortran

Beta Calendars for Fortran is a presentation-neutral library for proleptic Gregorian civil dates, deterministic calendar grids, and temporal boundary checks. It does not read the system clock, use a timezone, access the network, or depend on a website at runtime.

## Installation

Before a public tagged release is available, use a Git dependency:

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

Run `fpm test`. CI exercises GNU Fortran with runtime checks and LLVM Flang. Actual supported compiler versions will be listed after successful CI runs.

## API documentation

The source is documented for FORD. Generate local documentation with `ford ford.md`; the GitHub Pages deployment URL will be recorded after Pages is configured and verified.

## Project

Beta Calendars for Fortran is maintained as part of the Beta Calendars developer tooling project: [betacalendars.com](https://www.betacalendars.com/).

## Contributing

Bug reports and focused contributions are welcome. Calendar behavior must remain deterministic, timezone-independent, and explicit about invalid dates and bounds.

## License

MIT. See [LICENSE](../LICENSE).
