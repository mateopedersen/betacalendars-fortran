!> Deterministic presentation-neutral calendar month grids.
module betacalendars__grid
   use betacalendars__date
   implicit none
   private
   integer, parameter, public :: blank_overflow=0, adjacent_dates=1
   integer, parameter, public :: compact_rows=0, fixed_six_rows=1
   !> One slot in a month grid. A blank slot has has_date=false.
   type, public :: calendar_cell
      type(civil_date) :: date
      integer :: row=0, column=0, weekday=0
      logical :: has_date=.false., in_month=.false., weekend=.false.
      logical :: month_start=.false., month_end=.false., year_start=.false., year_end=.false.
   end type
   !> Row-major grid. Fixed grids contain exactly 42 cells.
   type, public :: month_grid
      integer :: year=0, month=0, week_start=1, rows=0, cell_count=0
      type(calendar_cell), allocatable :: cells(:)
   end type
   public :: make_month_grid
contains
   !> Build a Monday=1 ... Sunday=7 based month grid.
   function make_month_grid(year, month, week_start, row_mode, overflow_mode, status) result(grid)
      integer, intent(in) :: year,month,week_start
      integer, intent(in), optional :: row_mode,overflow_mode
      integer, intent(out), optional :: status
      type(month_grid) :: grid
      integer :: rm,om,s,first_w,offset,nmonth,ncells,i,k,st
      type(civil_date) :: first,d
      rm=compact_rows; om=adjacent_dates; s=date_status_ok
      if (present(row_mode)) rm=row_mode
      if (present(overflow_mode)) om=overflow_mode
      if (year<min_year .or. year>max_year .or. month<1 .or. month>12 .or. &
          week_start<1 .or. week_start>7 .or. (rm/=compact_rows .and. rm/=fixed_six_rows) .or. &
          (om/=blank_overflow .and. om/=adjacent_dates)) then
         s=date_status_invalid; allocate(grid%cells(0)); if (present(status)) status=s; return
      end if
      first=make_date(year,month,1)
      first_w=weekday(first); offset=modulo(first_w-week_start,7)
      nmonth=days_in_month(year,month)
      ncells=offset+nmonth
      grid%rows=(ncells+6)/7
      if (rm==fixed_six_rows) grid%rows=6
      grid%cell_count=grid%rows*7
      grid%year=year; grid%month=month; grid%week_start=week_start
      allocate(grid%cells(grid%cell_count))
      do i=1,grid%cell_count
         grid%cells(i)%row=(i-1)/7+1; grid%cells(i)%column=mod(i-1,7)+1
         k=i-offset
         if (k<1 .or. k>nmonth) then
            if (om==blank_overflow) cycle
         end if
         d=add_days(first,int(k-1,int64),st)
         if (st/=date_status_ok) then
            s=st; cycle
         end if
         grid%cells(i)%date=d; grid%cells(i)%has_date=.true.
         grid%cells(i)%weekday=weekday(d)
         grid%cells(i)%in_month=(month_of(d)==month .and. year_of(d)==year)
         grid%cells(i)%weekend=weekday(d)>=saturday
         grid%cells(i)%month_start=grid%cells(i)%in_month .and. day_of(d)==1
         grid%cells(i)%month_end=grid%cells(i)%in_month .and. day_of(d)==nmonth
         grid%cells(i)%year_start=year_of(d)==year .and. month_of(d)==1 .and. day_of(d)==1
         grid%cells(i)%year_end=year_of(d)==year .and. month_of(d)==12 .and. day_of(d)==31
      end do
      if (present(status)) status=s
   end function
end module betacalendars__grid
