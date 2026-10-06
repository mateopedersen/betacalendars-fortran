program betacal
   use betacalendars
   implicit none
   character(len=32)::command,arg
   integer::year,month,ios,i
   type(month_grid)::grid
   type(year_turn_window_type)::turn
   call get_command_argument(1,command)
   select case(trim(command))
   case('month')
      call get_command_argument(2,arg);read(arg,*,iostat=ios)year
      if(ios/=0)call usage()
      call get_command_argument(3,arg);read(arg,*,iostat=ios)month
      if(ios/=0)call usage()
      grid=make_month_grid(year,month,monday,fixed_six_rows,adjacent_dates,ios)
      if(ios/=0)error stop 'Invalid year or month'
      do i=1,grid%cell_count
         if(grid%cells(i)%has_date)then
            print '(i0,a,i0,a,i0,a,i0)',year_of(grid%cells(i)%date),'-',month_of(grid%cells(i)%date),'-', &
               day_of(grid%cells(i)%date),',',grid%cells(i)%weekday
         end if
      end do
   case('year-turn')
      call get_command_argument(2,arg);read(arg,*,iostat=ios)year
      if(ios/=0)call usage()
      turn=year_turn_window(year,ios)
      if(ios/=0)error stop 'Year outside supported range'
      print '(a)',date_to_string(turn%november)
      print '(a)',date_to_string(turn%december)
      print '(a)',date_to_string(turn%january)
      print '(a)',date_to_string(turn%february)
   case default
      call usage()
   end select
contains
   subroutine usage()
      print '(a)','Usage: betacal month YEAR MONTH | betacal year-turn YEAR'
      stop 2
   end subroutine
end program
