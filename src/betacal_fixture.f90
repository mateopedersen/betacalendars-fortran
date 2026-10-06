!> Small deterministic regression fixture constructors.
module betacalendars__fixture
   use betacalendars__date
   use betacalendars__boundary
   implicit none
   private
   type,public::leap_year_fixture
      integer::year
      logical::is_leap
      integer::february_days
   end type
   type,public::month_boundary_fixture
      integer::year,month
      type(civil_date)::first,last
      integer::length
   end type
   public::leap_fixture,month_fixture,year_turn_fixture
contains
   pure function leap_fixture(year) result(f)
      integer,intent(in)::year
      type(leap_year_fixture)::f
      f%year=year;f%is_leap=is_leap_year(year);f%february_days=days_in_month(year,2)
   end function
   function month_fixture(year,month) result(f)
      integer,intent(in)::year,month
      type(month_boundary_fixture)::f
      f%year=year;f%month=month;f%length=days_in_month(year,month)
      f%first=make_date(year,month,1)
      if(month>=1.and.month<=12)then
         f%last=make_date(year,month,max(1,f%length))
      else
         f%last=f%first
      end if
   end function
   function year_turn_fixture(year,status) result(w)
      integer,intent(in)::year
      integer,intent(out),optional::status
      type(year_turn_window_type)::w
      w=year_turn_window(year,status)
   end function
end module
