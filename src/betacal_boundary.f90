!> Deterministic temporal boundary analysis helpers.
module betacalendars__boundary
   use betacalendars__date
   use betacalendars__iso_week
   implicit none
   private
   type,public::year_turn_window_type
      type(civil_date)::november,december,january,february
   end type
   type,public::boundary_report
      type(civil_date)::month_start,month_end,next_month_start,year_start,year_end,leap_day
      logical::has_leap_day=.false.
      integer::iso_week=0,iso_week_year=0,month_length=0,next_month_length=0
   end type
   public::year_turn_window,boundaries_for_month
contains
   !> Start dates of November and December in year and January and February in year+1.
   function year_turn_window(year,status) result(w)
      integer,intent(in)::year
      integer,intent(out),optional::status
      type(year_turn_window_type)::w
      integer::s
      s=date_status_ok
      if(year<min_year.or.year>=max_year)then
         s=date_status_range
      else
         w%november=make_date(year,11,1);w%december=make_date(year,12,1)
         w%january=make_date(year+1,1,1);w%february=make_date(year+1,2,1)
      end if
      if(present(status))status=s
   end function
   !> Summarize the month's edges, length transition, leap day, and ending ISO week.
   function boundaries_for_month(year,month,status) result(report)
      integer,intent(in)::year,month
      integer,intent(out),optional::status
      type(boundary_report)::report
      integer::s,st
      s=date_status_ok
      if(year<min_year.or.year>max_year.or.month<1.or.month>12)then
         s=date_status_invalid
      else
         report%month_start=make_date(year,month,1)
         report%month_length=days_in_month(year,month)
         report%month_end=make_date(year,month,report%month_length)
         if(month==12)then
            report%next_month_length=31
            if(year<max_year)then
               report%next_month_start=make_date(year+1,1,1)
            else
               s=date_status_range
            end if
         else
            report%next_month_length=days_in_month(year,month+1)
            report%next_month_start=make_date(year,month+1,1)
         end if
         report%year_start=make_date(year,1,1);report%year_end=make_date(year,12,31)
         report%has_leap_day=is_leap_year(year)
         if(report%has_leap_day)report%leap_day=make_date(year,2,29)
         call iso_week(report%month_end,report%iso_week,report%iso_week_year)
      end if
      if(present(status))status=s
   end function
end module
