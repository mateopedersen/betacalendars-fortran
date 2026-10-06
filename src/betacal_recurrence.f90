!> Explicitly bounded monthly recurrence helpers; not an iCalendar RRULE parser.
module betacalendars__recurrence
   use, intrinsic :: iso_fortran_env, only:int64
   use betacalendars__date
   implicit none
   private
   integer,parameter,public::month_day_skip=0,month_day_clamp=1,month_day_error=2
   public::monthly_day_occurrences
contains
   !> Emit dates from start through finish on the requested day of each month.
   !! A short month skips, clamps to month end, or reports an error explicitly.
   pure subroutine monthly_day_occurrences(start,finish,day,policy,dates,status)
      type(civil_date),intent(in)::start,finish
      integer,intent(in)::day,policy
      type(civil_date),allocatable,intent(out)::dates(:)
      integer,intent(out),optional::status
      type(civil_date)::candidate
      integer::s,y,m,n,limit,d,pass
      s=date_status_ok;n=0
      if(day<1.or.day>31.or.policy<month_day_skip.or.policy>month_day_error.or.compare_dates(start,finish)>0)then
         s=date_status_invalid
      else
         do pass=1,2
            n=0
            do y=year_of(start),year_of(finish)
               do m=1,12
                  if(y==year_of(start).and.m<month_of(start))cycle
                  if(y==year_of(finish).and.m>month_of(finish))cycle
                  limit=days_in_month(y,m)
                  if(day>limit)then
                     if(policy==month_day_skip)cycle
                     if(policy==month_day_error)then
                        s=date_status_invalid;exit
                     end if
                     d=limit
                  else
                     d=day
                  end if
                  candidate=make_date(y,m,d)
                  if(compare_dates(candidate,start)<0.or.compare_dates(candidate,finish)>0)cycle
                  n=n+1
                  if(n>1000000)then
                     s=date_status_range;exit
                  end if
                  if(pass==2)dates(n)=candidate
               end do
               if(s/=date_status_ok)exit
            end do
            if(s/=date_status_ok.or.pass==2)exit
            allocate(dates(n))
         end do
      end if
      if(s==date_status_ok)then
         if(.not.allocated(dates))allocate(dates(0))
      else
         if(allocated(dates))deallocate(dates)
         allocate(dates(0))
      end if
      if(present(status))status=s
   end subroutine
end module
