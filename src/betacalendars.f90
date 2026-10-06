!> Beta Calendars public umbrella module.
module betacalendars
   use betacalendars__date
   use betacalendars__grid
   use betacalendars__year
   use betacalendars__iso_week
   use betacalendars__range
   use betacalendars__recurrence
   use betacalendars__business
   use betacalendars__boundary
   use betacalendars__fixture
   implicit none
   private
   public :: civil_date, make_date, year_of, month_of, day_of, is_valid_date
   public :: is_leap_year, days_in_month, weekday, day_of_year, compare_dates
   public :: days_between, add_days, next_day, previous_day, date_to_string
   public :: date_status_ok, date_status_invalid, date_status_range
   public :: min_year, max_year, monday, tuesday, wednesday, thursday, friday, saturday, sunday
   public :: calendar_cell, month_grid, make_month_grid
   public :: blank_overflow, adjacent_dates, compact_rows, fixed_six_rows
   public :: year_grid, make_year_grid, iso_week
   public :: date_range, make_date_range, range_length, range_contains, fill_range
   public :: monthly_day_occurrences, month_day_skip, month_day_clamp, month_day_error
   public :: is_weekend, is_business_day, business_days_between
   public :: next_business_day, previous_business_day
   public :: year_turn_window_type, boundary_report, year_turn_window, boundaries_for_month
   public :: leap_year_fixture, month_boundary_fixture, leap_fixture, month_fixture, year_turn_fixture
end module
