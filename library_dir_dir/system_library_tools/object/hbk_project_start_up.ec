&version 2
&-  ***********************************************************
&-  *                                                         *
&-  * Copyright, (C) Honeywell Information Systems Inc., 1984 *
&-  *                                                         *
&-  ***********************************************************

&- Created to allow the Hierarchy Dumper Daemons to run under a limited service subsystem.
&- This exec_com should be run from the project_start_up_ process overseer to ensure
&- that these Daemons never reach an unprotected command level.

&- Created 1985-02-21, BIM.

&if &[equal [user name] Backup] &then &goto hbk_restrict
&if &[equal [user name] Dumper] &then &goto hbk_restrict
&quit

&label hbk_restrict
enter_lss hierarchy_backup_dumper_lss
&quit

