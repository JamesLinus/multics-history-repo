&version 2
&- ***********************************************************
&- *                                                         *
&- * Copyright, (C) Honeywell Information Systems Inc., 1984 *
&- *                                                         *
&- ***********************************************************
&trace &command off
&-
&- Copy to >dumps any dump files not yet picked up.
copy_dump
&-
&- If AIM site execute the following command.
&- set_system_priv seg dir rcp
&-
&- Delete the old process directories from here
&- so that the system will come up faster.
delete_old_pdds
&-
&- Let the Initializer delete >pdd directory.
sac delete_old_pdds
&-
&- monitor storage in system directories.
monitor_quota -pn >system_control_1>syserr_log -console
monitor_quota -pn >system_control_1 -console
monitor_quota -pn >user_dir_dir>SysAdmin>a -console
monitor_quota -pn >dumps -console
&-
&- monitor_the memories for EDAC errors.
set_mos_polling_time 5
&-
&- monitor the MPCs for errors.
poll_mpc -tm 30
&-
&- Check disk storage.
list_vols -tt
&-
&quit
