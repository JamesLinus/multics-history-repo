&  ******************************************************
&  *                                                    *
&  * Copyright, (C) Honeywell Bull Inc., 1987           *
&  *                                                    *
&  * Copyright (c) 1972 by Massachusetts Institute of   *
&  * Technology and Honeywell Information Systems, Inc. *
&  *                                                    *
&  ******************************************************

& 
& 
&  HISTORY COMMENTS:
&   1) change(87-08-12,GDixon), approve(88-08-15,MCR7969),
&      audit(88-08-03,Lippard), install(88-08-29,MR12.2-1093):
&      Change to call print_motd instead of using the print command to print
&      the message of the day. (phx15921)
&                                                       END HISTORY COMMENTS
& 
&
& start_up.ec -- default start_up for >sc1
& this exec com just prints the motd to duplicate the old behavior of
& process_overseer_.
&
& It is executed by all users (with standard process overseers) who
& lack start_up.ec in their homedir and project dir.
&
&command_line off
&goto &ec_name

&label start_up
&if [equal &1 login] &then print_motd
&quit
