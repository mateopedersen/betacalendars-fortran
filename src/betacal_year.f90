!> Twelve ordered month grids for one calendar year.
module betacalendars__year
   use betacalendars__grid
   implicit none
   private
   type, public :: year_grid
      integer :: year=0
      type(month_grid) :: months(12)
   end type
   public :: make_year_grid
contains
   pure function make_year_grid(year,week_start,row_mode,overflow_mode,status) result(out)
      integer,intent(in)::year,week_start
      integer,intent(in),optional::row_mode,overflow_mode
      integer,intent(out),optional::status
      type(year_grid)::out
      integer::m,s,st
      out%year=year; s=0
      do m=1,12
         if(present(row_mode).and.present(overflow_mode)) then
            out%months(m)=make_month_grid(year,m,week_start,row_mode,overflow_mode,st)
         else if(present(row_mode)) then
            out%months(m)=make_month_grid(year,m,week_start,row_mode=row_mode,status=st)
         else if(present(overflow_mode)) then
            out%months(m)=make_month_grid(year,m,week_start,overflow_mode=overflow_mode,status=st)
         else
            out%months(m)=make_month_grid(year,m,week_start,status=st)
         end if
         if(st/=0) s=st
      end do
      if(present(status)) status=s
   end function
end module
