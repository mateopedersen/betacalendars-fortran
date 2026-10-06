!> Business-day utilities with caller-provided excluded dates.
module betacalendars__business
   use, intrinsic :: iso_fortran_env, only:int64
   use betacalendars__date
   implicit none
   private
   public::is_weekend,is_business_day,business_days_between,next_business_day,previous_business_day
contains
   pure logical function is_weekend(d)
      type(civil_date),intent(in)::d
      is_weekend=weekday(d)>=saturday
   end function
   pure logical function is_business_day(d,excluded)
      type(civil_date),intent(in)::d
      type(civil_date),intent(in),optional::excluded(:)
      integer::i
      is_business_day=.not.is_weekend(d)
      if(present(excluded))then
         do i=1,size(excluded)
            if(compare_dates(d,excluded(i))==0)is_business_day=.false.
         end do
      end if
   end function
   integer(int64) function business_days_between(first,last,excluded) result(n)
      type(civil_date),intent(in)::first,last
      type(civil_date),intent(in),optional::excluded(:)
      type(civil_date)::d
      integer(int64)::i,span
      integer::st,sign
      n=0;sign=1
      if(compare_dates(first,last)>0)sign=-1
      span=abs(days_between(first,last));d=first
      do i=0_int64,span
         if(is_business_day(d,excluded))n=n+1
         if(i<span)d=add_days(d,int(sign,int64),st)
      end do
      n=n*sign
   end function
   function next_business_day(d,excluded,status) result(out)
      type(civil_date),intent(in)::d
      type(civil_date),intent(in),optional::excluded(:)
      integer,intent(out),optional::status
      type(civil_date)::out
      integer::i,st
      out=d
      do i=1,8
         out=add_days(out,1_int64,st)
         if(st/=0)exit
         if(is_business_day(out,excluded))exit
      end do
      if(present(status))status=st
   end function
   function previous_business_day(d,excluded,status) result(out)
      type(civil_date),intent(in)::d
      type(civil_date),intent(in),optional::excluded(:)
      integer,intent(out),optional::status
      type(civil_date)::out
      integer::i,st
      out=d
      do i=1,8
         out=add_days(out,-1_int64,st)
         if(st/=0)exit
         if(is_business_day(out,excluded))exit
      end do
      if(present(status))status=st
   end function
end module
