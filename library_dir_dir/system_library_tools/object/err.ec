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
&-  Modification history:
&-  Modified 1984-12-11 BIM: new value segments.
&-
&trace &command off
&goto &1
&-
&label crank_abort
&print --> A PREVIOUS CRANK ABORTED. MAKE SURE EVERYTHING IS OK.
sm [value_get -pn sys_admin admin_online] "CRANK ABORTED"
&goto common
&-
&label not_user
&print --> ERROR User &2 is not registered
&goto common
&-
&label fatal
&print --> ERROR Serious error. Get help
&goto common
&-
&label no_pmf
&print --> ERROR Project &2 master file not found (may be delegated or misspelled)
&goto common
&-
&label try_again
&print --> ERROR Try again
&goto common
&-
&label noarg
&print --> ERROR Not enough arguments
&goto common
&-
&label noarg_nolock
&print --> ERROR Not enough arguments
&goto common1
&-
&label nofile
&print --> ERROR File missing: &2
&goto common
&-
&label many_arg
&print --> ERROR Too many Arguments
&goto common
&-
&label quote_arg
&print --> ERROR Argument must be enclosed in quotes
&goto common
&-
&label badcom
&print --> ERROR Invalid command: &2
&goto common
&-
&label already_delegated
&print --> ERROR Proj &2 already delegated
&goto common
&-
&label noproj
&print --> ERROR Project &2 does not exist
&goto common
&-
&label already_proj
&print --> ERROR Project &2 already exists
&goto common
&-
&label crank_absout_missing
&print --> ERROR crank.absout not found.
&print 'day' may have been done already or crank may have failed to run.
&goto common
&-
&label common
admin_util unlock
&label common1
signal master_ec_error_ -info_string "An error occured in the master.ec"
&- program_interrupt would be a noop in the normal Multics environment
&goto common1 &- we mean this.
&quit
&-
&label &1
&print --> ERROR &1 &2 &3 &4 &5
&goto common
