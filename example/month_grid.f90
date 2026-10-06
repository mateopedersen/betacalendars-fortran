program month_grid_example
   use betacalendars
   implicit none
   type(month_grid)::grid
   integer::i
   grid=make_month_grid(2027,1,monday,fixed_six_rows,adjacent_dates)
   do i=1,grid%cell_count
      if(grid%cells(i)%has_date)then
         write(*,'(i3)',advance='no')day_of(grid%cells(i)%date)
      else
         write(*,'(a)',advance='no')'   '
      end if
      if(grid%cells(i)%column==7)write(*,*)
   end do
end program
