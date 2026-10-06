!> ISO-8601 week numbering for supported civil dates.
module betacalendars__iso_week
   use betacalendars__date
   implicit none
   private
   public :: iso_week
contains
   !> Return ISO week number and week-based year.
   pure subroutine iso_week(date, week, week_year)
      type(civil_date), intent(in) :: date
      integer, intent(out) :: week,week_year
      type(civil_date) :: thursday,jan4,week1
      integer :: st
      thursday=add_days(date,int(4-weekday(date)),st)
      week_year=year_of(thursday)
      jan4=make_date(week_year,1,4)
      week1=add_days(jan4,int(1-weekday(jan4)),st)
      week=int(days_between(week1,date)/7)+1
   end subroutine
end module
