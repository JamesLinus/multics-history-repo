&version 2
&- ***********************************************************
&- *                                                         *
&- * Copyright, (C) Honeywell Information Systems Inc., 1985 *
&- *                                                         *
&- ***********************************************************
&trace off
&- ec to perform fix_quota_used function over a subtree
&- Greenberg 2/23/77
&- 84-02-05 BIM to protect against dir named -upward
&- 84-12-14, Loepere, for seg/dir variants
&-
&set path &r1
walk_subtree &(path) "&ec_name [wd] &rf2" -brief -bottom_up -priv -msf
&label upward_loop
&if &[equal &(path) >] &then &quit
&set path &[directory &(path)]
&ec_name &(path) &rf2
&goto upward_loop
