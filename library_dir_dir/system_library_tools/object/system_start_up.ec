&  ***********************************************************
&  *                                                         *
&  * Copyright, (C) Honeywell Bull Inc., 1987                *
&  *                                                         *
&  * Copyright, (C) Honeywell Information Systems Inc., 1984 *
&  *                                                         *
&  * Copyright (c) 1972 by Massachusetts Institute of        *
&  * Technology and Honeywell Information Systems, Inc.      *
&  *                                                         *
&  ***********************************************************
& 
&
& SYSTEM_START_UP.EC - Installation-dependent commands at system startup time.
&
& This exec_com is invoked by system_control_ three times:
& 1. Before answering service startup, in response to "startup" or "multics" command.
& 2. After answering service startup, in response to "startup" or "go" command.
& 3. After channel attachment, in response to "startup" or "go" command.
&
& a ten-second pause is made between step 2 and channel attachment to allow the
& message coordinator to get output from "login" commands and such out.
&
& Modified 1985-01-02, BIM: new system control.
& Modified 1985-02-04, Steve Herbst: Added comment showing command line to
&	log in a Data_Management daemon.
& 
& 
&  HISTORY COMMENTS:
&   1) change(87-10-01,Beattie), approve(87-10-01,MECR0010),
&      audit(87-10-01,Parisek), install(87-10-02,MR12.1-1123):
&      Insert reconfigure command line and exec_com command line to start
&      scavenging into an "on" command line to prevent an abort when
&      they signal command_error.
&                                                       END HISTORY COMMENTS
& 
& 
& ----------------------------------------------------------------------------
&
&  To log in a Data Management daemon, issue the command line:
&
&	  login Data_Management Daemon <message_coordinator_channel_id>
&
& ----------------------------------------------------------------------------
&
&command_line off
&goto &1
&
&label part1
&  must create and set acls for ".message" segments used by non-SysDaemon daemons:
&
&if [exists segment mc.message] &then &else create mc.message; set_acl mc.message rw *.Daemon.*
&if [exists segment reader.message] &then &else create reader.message; set_acl reader.message rw *.Daemon.*
&if [exists segment vinc.message] &then &else create vinc.message; set_acl vinc.message rw *.Daemon.*
&if [exists segment vcons.message] &then &else create vcons.message; set_acl vcons.message rw *.Daemon.*
&if [exists segment vcomp.message] &then &else create vcomp.message; set_acl vcomp.message rw *.Daemon.*
&quit
&
&label part2
&
&	a.h000 is an example of an installation-dependent channel number
&	of a terminal in an input/output area remote from the main computer
&	room.  The lines referring to a.h000 and ioc2d are commented out,
&	and are present to show how a remote i/o terminal can be set up
&	using the message coordinator
&
&	EXAMPLE OF REMOTE I/O TERMINAL
& sc_command accept a.h000
sc_command define alarm tty otw_
sc_command define scc tty otw_
sc_command define asc tty otw_
sc_command define ioc tty otw_
sc_command define bkc tty otw_
&	EXAMPLE OF REMOTE I/O TERMINAL
& sc_command define ioc2d tty a.h000
&
sc_command define iolog log iolog
sc_command reroute as severity1 default_vcons asc
sc_command reroute as severity2 default_vcons *asc
sc_command reroute as severity3 default_vcons *asc
sc_command route as severity3 *alarm
sc_command route (io1 io2 cord prta prtb) user_i/o ioc
&	EXAMPLE OF REMOTE I/O TERMINAL
& sc_command route (io1 prtb cord) user_i/o ioc2d
sc_command route (io1 io2 cord prta prtb) error_i/o *ioc
&	EXAMPLE OF REMOTE I/O TERMINAL
& sc_command route (io1 prtb cord) error_i/o *ioc2d
sc_command route (prta prtb reader io1) log_i/o iolog
sc_command route (prta prtb reader io1) log_i/o ioc
&	EXAMPLE OF REMOTE I/O TERMINAL
& sc_command route (prtb io1) log_i/o ioc2d
sc_command route (bk cd1 cd2 rt vinc vcons vcomp) user_i/o bkc
sc_command route (bk cd1 cd2 rt vinc vcons vcomp) error_i/o *bkc
&
& CHANGE and uncomment the following line to name the volumes that should 
&   be used for process directories.
& sc_command set_pdir_volumes public
sc_command login IO SysDaemon cord
sc_command login Backup SysDaemon bk
sc_command login IO SysDaemon prta
sc_command login Utility SysDaemon ut
sc_command login Volume_Dumper Daemon vinc
&
& if system rebooted itself after a crash, while unattended (flagbox 5 is "unattended")
&if [and [get_flagbox 5] [get_flagbox rebooted]] &then &else &goto not_unattended_reboot
& delete the tape drives
on command_error "" -brief -restart reconfigure delete device tape_(01 02 03 04 05 06 07 08)
& turn off automatic rebooting, to avoid a crash loop
set_flagbox auto_reboot false
&label not_unattended_reboot
&
&quit
&
&label part3
& set_timax 1
initialize_peek_limits >system_library_1>ring_zero_meter_limits_ASCII_
set_flagbox booting false
hpsa >system_library_1>system_privilege_ re *.Daemon.*
hpsa >system_library_1>rcp_priv_ re *.HFED.*
hpsa >system_library_1>phcs_ re *.HFED.*
hpsa >system_library_1>tandd_ re *.HFED.*
set_acl >sl1>syserr_log.** [list_iacl_seg >sc1>syserr_log]
save_history_registers off -priv
& The following will log in a daemon to scavenge all mounted physical
& volumes with inconsistencies.
on command_error "" -brief -restart ec admin scav -all -auto -nopt
&quit
&
&label &1
&print ERROR &1
& end
