# Beta Calendars for Fortran

Deterministic civil-calendar grids, bounded recurrence, and temporal boundary utilities for Modern Fortran.

## Purpose

This is a standalone Fortran library for civil calendar structures and regression work around dates. It is useful in scientific reports, simulation schedules, batch processing, forecasting, and calendar UI backends. It is not a clock or timezone library, and its core has no runtime dependencies.

## Features

- Validated proleptic Gregorian dates and date arithmetic for years 1–999999.
- Weekdays numbered Monday=1 through Sunday=7; day-of-year and ISO week/week-year.
- Compact and fixed 42-cell month grids, all seven week starts, adjacent dates or blank cells.
- Twelve-month year grids, inclusive bounded date ranges, and business-day helpers with caller-supplied exclusions.
- Bounded monthly recurrence with explicit skip/clamp/error behavior for short months.
- Month-boundary reports and deterministic leap-year and year-turn fixtures.
- Optional `betacal` CLI for month CSV-like rows and year-turn dates.

## Why this library exists

Date arithmetic is often mixed with timestamps, local timezones, UI formatting, or operating-system clocks. Beta Calendars keeps the civil-date model independent and offers repeatable grid and boundary structures that are easy to test.

## Requirements

Fortran 2008 compiler and [fpm](https://github.com/fortran-lang/fpm). There are no runtime dependencies.

## Installation with fpm

Before registry acceptance, consume the tagged Git release:

```toml
[dependencies]
betacalendars = { git = "https://github.com/mateopedersen/betacalendars-fortran", tag = "v1.0.0" }
```

## Quick start

```fortran
program january
   use betacalendars
   implicit none
   type(month_grid) :: grid
   integer :: status
   grid = make_month_grid(2027, 1, monday, fixed_six_rows, adjacent_dates, status)
   if (status /= date_status_ok) error stop "invalid grid request"
   print *, grid%cell_count ! 42
end program
```

## Civil dates

`make_date` validates input and returns a status. It never normalizes invalid dates. Supported years are 1 through 999999, and dates use the proleptic Gregorian calendar. Arithmetic does not consult `DATE_AND_TIME`, timestamps, or timezones.

## Month and year grids

`make_month_grid` accepts any first weekday. `fixed_six_rows` always contains 42 slots; `compact_rows` allocates only the needed weeks. `adjacent_dates` fills edge slots with real neighboring dates, while `blank_overflow` leaves them invalid (`has_date=.false.`). `make_year_grid` creates January through December in order.

## Date ranges

`date_range` endpoints are inclusive. `range_length` does not allocate. `fill_range` materializes at most one million dates and reports a range error above that safety bound.

## Recurrence

`monthly_day_occurrences` generates a requested day of month between explicit start and finish bounds. Short months use `month_day_skip`, `month_day_clamp`, or `month_day_error`. This is a focused recurrence helper, not an iCalendar RRULE implementation.

## Business days

Saturday and Sunday are weekends. Pass an optional array of excluded dates to business-day procedures. The package does not ship a jurisdictional holiday calendar and makes no legal-holiday claims.

## ISO weeks

`iso_week` returns both ISO week number and ISO week-based year, including year-boundary cases.

## Boundary analysis and fixtures

`boundaries_for_month` reports month/year edges, adjacent month length, leap-day presence, and the ISO week of month end. `year_turn_window` supplies November, December, January, and February starts across a year transition.

## CLI

`fpm run -- betacal month 2027 1` and `fpm run -- betacal year-turn 2026`.

## Supported compilers

The CI workflow targets GNU Fortran and AOCC Flang. Specific version support will be stated from actual CI results.

## Documentation

API documentation is prepared for FORD; see `ford.md` and `page/index.md`.

## Testing

Run `fpm test`. Tests cover Gregorian leap rules, invalid inputs, ISO rollover, range inclusivity, recurrence policies, year-turn fixtures, and all months from 1900 through 2100 for 42-cell and date-sequence invariants.

## Contributing

Keep behavior deterministic, portable, explicit about bounds, and covered by regression tests. Avoid timezone, network, telemetry, and host-clock dependencies.

## License

MIT; see [LICENSE](LICENSE).

## Project

Beta Calendars for Fortran is maintained as part of the Beta Calendars developer tooling project: [https://www.betacalendars.com/](https://www.betacalendars.com/).
