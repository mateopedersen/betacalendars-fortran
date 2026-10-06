!> Inclusive bounded date ranges.
module betacalendars__range
   use, intrinsic :: iso_fortran_env, only:int64
   use betacalendars__date
   implicit none
   private
   type, public :: date_range
      type(civil_date)::start_date,end_date
   end type
   public::make_date_range,range_length,range_contains,fill_range
contains
   pure function make_date_range(first,last,status) result(r)
      type(civil_date),intent(in)::first,last
      integer,intent(out),optional::status
      type(date_range)::r
      integer::s
      s=date_status_ok
      if(compare_dates(first,last)>0)s=date_status_invalid
      r%start_date=first;r%end_date=last
      if(present(status))status=s
   end function
   pure integer(int64) function range_length(r) result(n)
      type(date_range),intent(in)::r
      n=days_between(r%start_date,r%end_date)+1_int64
      if(n<1)n=0
   end function
   pure logical function range_contains(r,d)
      type(date_range),intent(in)::r
      type(civil_date),intent(in)::d
      range_contains=compare_dates(d,r%start_date)>=0.and.compare_dates(d,r%end_date)<=0
   end function
   pure subroutine fill_range(r,dates,status)
      type(date_range),intent(in)::r
      type(civil_date),allocatable,intent(out)::dates(:)
      integer,intent(out),optional::status
      integer(int64)::n,i
      integer::s,st
      type(civil_date)::d
      s=date_status_ok;n=range_length(r)
      if(n<1.or.n>1000000_int64)then
         allocate(dates(0));s=date_status_range
      else
         allocate(dates(int(n)));d=r%start_date
         do i=1,n
            dates(int(i))=d
            if(i<n)d=add_days(d,1_int64,st)
         end do
      end if
      if(present(status))status=s
   end subroutine
end module
