&version 2
&-  ***********************************************************
&-  *                                                         *
&-  * Copyright, (C) Honeywell Information Systems Inc., 1984 *
&-  *                                                         *
&-  ***********************************************************

&- Created to allow the Volume Backup Daemons to run under a limited service subsystem.
&- This exec_com should be run from the project_start_up_ process overseer to ensure
&- that these Daemons never reach an unprotected command level.

&- Modified 1985-02-21, BIM: added _lss to names.

&if &[equal [user name] Volume_Dumper] &then &goto volume_dumper
&if &[equal [user name] Volume_Retriever] &then &goto volume_retriever
&if &[equal [user name] Volume_Reloader] &then &goto volume_reloader
&quit

&label volume_dumper
enter_lss volume_dumper_lss
&quit

&label volume_retriever
enter_lss volume_retriever_lss
&quit

&label volume_reloader
enter_lss volume_reloader_lss
&quit
