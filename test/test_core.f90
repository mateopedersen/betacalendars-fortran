program test_core
   use, intrinsic :: iso_fortran_env, only:int64
   use betacalendars
   implicit none
   integer::failures,year,month,status,i,current_count,week,week_year
   type(civil_date)::d,a,b
   type(month_grid)::grid
   type(year_turn_window_type)::turn
   type(date_range)::r
   type(civil_date),allocatable::filled(:),recurrence(:)
   failures=0
   call check(.not.is_leap_year(1900),'1900 common')
   call check(is_leap_year(2000),'2000 leap')
   call check(is_leap_year(2024),'2024 leap')
   call check(.not.is_leap_year(2100),'2100 common')
   call check(is_leap_year(2400),'2400 leap')
   d=make_date(2027,2,29,status);call check(status/=0,'invalid leap day rejected')
   d=make_date(2027,4,31,status);call check(status/=0,'invalid April date rejected')
   d=make_date(2027,13,1,status);call check(status/=0,'invalid month rejected')
   d=make_date(2000,1,1);call check(weekday(d)==saturday,'weekday epoch')
   a=make_date(2024,12,30);call iso_week(a,week,week_year)
   call check(week==1.and.week_year==2025,'ISO week-year rollover')
   a=make_date(2027,1,1);b=make_date(2027,1,31);r=make_date_range(a,b,status)
   call check(status==0.and.range_length(r)==31_int64,'inclusive date range')
   call fill_range(r,filled,status);call check(size(filled)==31,'range materialization')
   turn=year_turn_window(2026,status)
   call check(date_to_string(turn%november)=='2026-11-01','year turn Nov')
   call check(date_to_string(turn%february)=='2027-02-01','year turn Feb')
   grid=make_month_grid(2027,1,monday,fixed_six_rows,adjacent_dates,status)
   call check(status==0.and.grid%cell_count==42,'fixed grid invariant')
   current_count=0
   do i=1,grid%cell_count
      call check(grid%cells(i)%row>=1.and.grid%cells(i)%row<=6,'grid row bound')
      call check(grid%cells(i)%column>=1.and.grid%cells(i)%column<=7,'grid column bound')
      if(grid%cells(i)%in_month)current_count=current_count+1
   end do
   call check(current_count==31,'all current month days represented')
   do year=1900,2100
      do month=1,12
         grid=make_month_grid(year,month,wednesday,fixed_six_rows,adjacent_dates,status)
         call check(status==0.and.grid%cell_count==42,'property fixed grid')
         current_count=count([(grid%cells(i)%in_month,i=1,grid%cell_count)])
         call check(current_count==days_in_month(year,month),'property month cell count')
         do i=2,grid%cell_count
            call check(days_between(grid%cells(i-1)%date,grid%cells(i)%date)==1_int64,'grid consecutive dates')
         end do
      end do
   end do
   a=make_date(2026,1,1);b=make_date(2026,5,31)
   call monthly_day_occurrences(a,b,31,month_day_skip,recurrence,status)
   call check(status==0.and.size(recurrence)==3,'monthly skip policy')
   call monthly_day_occurrences(a,b,31,month_day_clamp,recurrence,status)
   call check(status==0.and.size(recurrence)==5.and.day_of(recurrence(2))==28,'monthly clamp policy')
   call monthly_day_occurrences(a,b,31,month_day_error,recurrence,status)
   call check(status/=0.and.size(recurrence)==0,'monthly error policy')
   if(failures>0)error stop 1
   print '(a)','All Beta Calendars tests passed.'
contains
   subroutine check(condition,label)
      logical,intent(in)::condition
      character(len=*),intent(in)::label
      if(.not.condition)then
         failures=failures+1
         print '(a)','FAIL: '//label
      end if
   end subroutine
end program
