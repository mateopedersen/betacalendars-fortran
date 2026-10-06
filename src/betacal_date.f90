!> Validated proleptic Gregorian civil dates and arithmetic.
module betacalendars__date
   use, intrinsic :: iso_fortran_env, only : int64
   implicit none
   private
   integer, parameter, public :: date_status_ok = 0
   integer, parameter, public :: date_status_invalid = 1
   integer, parameter, public :: date_status_range = 2
   integer, parameter, public :: min_year = 1, max_year = 999999
   integer, parameter, public :: monday = 1, tuesday = 2, wednesday = 3, thursday = 4
   integer, parameter, public :: friday = 5, saturday = 6, sunday = 7

   !> A date in the proleptic Gregorian calendar, with year in [1, 999999].
   type, public :: civil_date
      private
      integer :: y = 1, m = 1, d = 1
   end type civil_date

   public :: make_date, year_of, month_of, day_of, is_valid_date
   public :: is_leap_year, days_in_month, weekday, day_of_year
   public :: compare_dates, days_between, add_days, next_day, previous_day
   public :: date_to_string, date_from_ordinal
contains
   !> Construct a date. Invalid input returns 0001-01-01 and a nonzero status.
   function make_date(year, month, day, status) result(date)
      integer, intent(in) :: year, month, day
      integer, intent(out), optional :: status
      type(civil_date) :: date
      integer :: s
      s = date_status_ok
      if (year < min_year .or. year > max_year .or. month < 1 .or. month > 12) then
         s = date_status_invalid
      else if (day < 1 .or. day > days_in_month(year, month)) then
         s = date_status_invalid
      end if
      if (s == date_status_ok) then
         date%y = year; date%m = month; date%d = day
      end if
      if (present(status)) status = s
   end function make_date

   pure integer function year_of(date) result(value)
      type(civil_date), intent(in) :: date
      value = date%y
   end function
   pure integer function month_of(date) result(value)
      type(civil_date), intent(in) :: date
      value = date%m
   end function
   pure integer function day_of(date) result(value)
      type(civil_date), intent(in) :: date
      value = date%d
   end function
   pure logical function is_valid_date(date)
      type(civil_date), intent(in) :: date
      is_valid_date = date%y >= min_year .and. date%y <= max_year .and. &
         date%m >= 1 .and. date%m <= 12
      if (is_valid_date) is_valid_date = date%d >= 1 .and. date%d <= days_in_month(date%y,date%m)
   end function
   pure elemental logical function is_leap_year(year)
      integer, intent(in) :: year
      is_leap_year = mod(year,4) == 0 .and. (mod(year,100) /= 0 .or. mod(year,400) == 0)
   end function
   pure integer function days_in_month(year, month) result(n)
      integer, intent(in) :: year, month
      integer, parameter :: lengths(12) = [31,28,31,30,31,30,31,31,30,31,30,31]
      n = 0
      if (month < 1 .or. month > 12) return
      n = lengths(month)
      if (month == 2 .and. is_leap_year(year)) n = 29
   end function

   pure integer(int64) function ordinal(year, month, day) result(n)
      integer, intent(in) :: year, month, day
      integer(int64) :: y, era, yoe, doy, mp, z
      y = int(year,int64)
      if (month <= 2) y = y - 1_int64
      z = y
      if (z < 0_int64) z = z - 399_int64
      era = z / 400_int64
      yoe = y - era*400_int64
      if (month > 2) then
         mp = int(month-3,int64)
      else
         mp = int(month+9,int64)
      end if
      doy = (153_int64*mp+2_int64)/5_int64 + int(day-1,int64)
      n = era*146097_int64 + yoe*365_int64 + yoe/4_int64 - yoe/100_int64 + doy
   end function

   !> Return Monday=1 through Sunday=7.
   pure integer function weekday(date) result(w)
      type(civil_date), intent(in) :: date
      w = int(modulo(ordinal(date%y,date%m,date%d)+5_int64,7_int64))+1
   end function
   pure integer function day_of_year(date) result(n)
      type(civil_date), intent(in) :: date
      integer :: m
      n = date%d
      do m=1,date%m-1
         n = n + days_in_month(date%y,m)
      end do
   end function
   !> Compare dates: -1 if a<b, 0 if equal, +1 if a>b.
   pure integer function compare_dates(a,b) result(order)
      type(civil_date), intent(in) :: a,b
      integer(int64) :: delta
      delta = ordinal(a%y,a%m,a%d)-ordinal(b%y,b%m,b%d)
      order = 0
      if (delta < 0_int64) order=-1
      if (delta > 0_int64) order=1
   end function
   !> Signed number of midnights from start to finish (finish-start).
   pure integer(int64) function days_between(start_date, finish_date) result(n)
      type(civil_date), intent(in) :: start_date,finish_date
      n = ordinal(finish_date%y,finish_date%m,finish_date%d)- &
          ordinal(start_date%y,start_date%m,start_date%d)
   end function
   !> Add a signed day count. On overflow of the supported year range, returns
   !> the input date and sets status=date_status_range.
   function add_days(date, count, status) result(out)
      type(civil_date), intent(in) :: date
      integer(int64), intent(in) :: count
      integer, intent(out), optional :: status
      type(civil_date) :: out
      integer :: s
      integer(int64) :: base, target, lower, upper
      s=date_status_ok
      base=ordinal(date%y,date%m,date%d)
      lower=ordinal(min_year,1,1); upper=ordinal(max_year,12,31)
      if (count > upper-base .or. count < lower-base) then
         s=date_status_range
         out=date
      else
         target=base+count
         out=date_from_ordinal(target,s)
      end if
      if (s /= date_status_ok) out=date
      if (present(status)) status=s
   end function
   function next_day(date, status) result(out)
      type(civil_date), intent(in) :: date
      integer, intent(out), optional :: status
      type(civil_date) :: out
      out=add_days(date,1_int64,status)
   end function
   function previous_day(date, status) result(out)
      type(civil_date), intent(in) :: date
      integer, intent(out), optional :: status
      type(civil_date) :: out
      out=add_days(date,-1_int64,status)
   end function
   !> Convert an ordinal produced by this module back to a date.
   function date_from_ordinal(n, status) result(date)
      integer(int64), intent(in) :: n
      integer, intent(out), optional :: status
      type(civil_date) :: date
      integer(int64) :: era, doe, yoe, y, doy, mp, d, m
      integer :: s
      s=date_status_ok
      if (n < ordinal(min_year,1,1) .or. n > ordinal(max_year,12,31)) then
         s=date_status_range; date=make_date(1,1,1)
      else
         era=n/146097_int64
         doe=n-era*146097_int64
         yoe=(doe-doe/1460_int64+doe/36524_int64-doe/146096_int64)/365_int64
         y=yoe+era*400_int64
         doy=doe-(365_int64*yoe+yoe/4_int64-yoe/100_int64)
         mp=(5_int64*doy+2_int64)/153_int64
         d=doy-(153_int64*mp+2_int64)/5_int64+1_int64
         if (mp < 10_int64) then
            m=mp+3_int64
         else
            m=mp-9_int64
         end if
         if (m <= 2_int64) y=y+1_int64
         date=make_date(int(y),int(m),int(d))
      end if
      if (present(status)) status=s
   end function
   function date_to_string(date) result(text)
      type(civil_date), intent(in) :: date
      character(len=10) :: text
      write(text,'(i4.4,"-",i2.2,"-",i2.2)') date%y,date%m,date%d
   end function
end module betacalendars__date
