&version 2
&-  ***********************************************************
&-  *                                                         *
&-  * Copyright, (C) Honeywell Information Systems Inc., 1982 *
&-  *                                                         *
&-  * Copyright (c) 1972 by Massachusetts Institute of        *
&-  * Technology and Honeywell Information Systems, Inc.      *
&-  *                                                         *
&-  ***********************************************************
&-
&- utility functions for system admin operations
&- 
&- Modification history:
&- Modified 1984-12-11, BIM: summarize_sys_log, new value, V2
&- Modified 1985-02-18, E. Swenson: Prevent eor from asking questions
&-   when there are problems with the segment to be printed.
&-
&trace &command off
&goto &1
&-
&label del
&if &[not [exists argument &2]] &then &quit
&if &[exists file &2] &then answer yes -bf delete &2
&quit
&-
&label dp
&label dprint
&if &[not [value_defined -pn sys_admin &3_addr]] &then &quit
&if &[not [exists argument &2]] &then &quit
&if &[not [exists file &2]] &then &quit
set_acl &2 r IO.SysDaemon
answer no eor -bf -he [value_get -pn sys_admin &3_addr] -ds [value_get -pn sys_admin &3_dest] &2 -q [default default &4]
&quit
&-
&label check_access 
&- usage: ec util check_access OBJECT MODE {name}
&if [exists argument &4] &then &set USER "-user &4"
&else &set USER ""
&set ACCESS &[get_effective_access &2 &(USER)]
&set X 1
&label _loop_check_access
&if &[ngreater &(X) [length &3]] &then &goto _done_check_access
&if &[equal 0 [index &(ACCESS) [substr &3 &(X) 1]]]
&then &do
      &if &is_af &then &return false
      &else &do
            &print Warning: &[default You &4] lack &[substr &3 &(X) 1] access to &2.
            &quit
      &end
&end
&set X &[plus &(X) 1]
&goto _loop_check_access
&label _done_check_access
&if &is_af &then &return true
&quit

&label &1
&print Invalid call to util.ec -- first argument &1
&quit
&- end
