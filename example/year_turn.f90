program year_turn_example
   use betacalendars
   implicit none
   type(year_turn_window_type)::window
   window=year_turn_window(2026)
   print '(a)',date_to_string(window%november)
   print '(a)',date_to_string(window%december)
   print '(a)',date_to_string(window%january)
   print '(a)',date_to_string(window%february)
end program
