&version 2
&- ***********************************************************
&- *                                                         *
&- * Copyright, (C) Honeywell Bull Inc., 1987                *
&- *                                                         *
&- * Copyright, (C) Honeywell Information Systems Inc., 1982 *
&- *                                                         *
&- * Copyright (c) 1972 by Massachusetts Institute of        *
&- * Technology and Honeywell Information Systems, Inc.      *
&- *                                                         *
&- ***********************************************************
&-
&trace off
&goto &ec_name
&-
&-	ACCOUNTING COLD START SECTION, FOR INITIALIZING SYSTEM FILES
&-			AFTER A "boot -cold".
&-
&-      	UP TO DATE AS OF ANSWERING SERVICE 17.0 (MR12.1)
&-
&-	Modified by T. Casey, June 1976, for MR4.0
&-	Modified by T. Casey, December 1976, for MR5.0
&-	Modified by T. Casey and B. Greenberg, September 1977 for MR6.0
&-	Modified by F. W. Martinson, January 1978 for MR7.0
&-	Modified by C. Hornig, August 1979, for MR8.0
&-	Modified by T. Casey, February 1980, for MR8.0
&-	Modified by R. Holmstedt, July 1981, for MR9.0
&-	Modified by F. W. Martinson, August 1981, for MR9.0 final changes
&-	Modified by R. Holmstedt, May, 1982, for MR10.0
&-	Modified by G. Palter, October 1983, to create the mail table
&-	   (MR10.2)
&-        Modified by R. Holmstedt, Nov. 1983, for final changes.
&-	Modified 84-09-21 by E. Swenson for MR11, A.S. 14.2.
&-        Modified 1984-12-11 by BIM for new value.
&-	Modified 1984-01-28 by Steve Herbst, preregister and give
&-		necessary access to Data_Management.Daemon.
&-        Modified 1985-03-21 by E. Swenson to use set_acl instead of
&-       	          ms_set_acl to avoid warning messages.  Note that the
&-		current AS version is 16.1.
&-	Modified 1985-03-29 by E. Swenson to create the directory 
&-		>system_control_1>mc_acs.
&-	Modified 1985-04-23 by E. Swenson to make Data_Management setup
&-		work.
&-	Modified 1985-05-05 by Art Beattie to correct minor bugs.
&-
&-
&- HISTORY COMMENTS:
&-  1) change(87-08-28,Lippard), approve(87-02-09,PBF7616),
&-     audit(87-08-28,Farley), install(87-09-01,MR12.1-1095):
&-     Modified to create and set_acl on set_proc_required.acs (in
&-     >sc1>admin_acs).
&-                                                      END HISTORY COMMENTS
&-
&-
&- ---------------------------------------------------------------------------
&-			U T I L I T Y   F U N C T I O N S
&-
&-	These exec_com "subroutines" are placed at the beginning of the
&-	segment for efficiency, since exec_com performs a linear search of 
&-	the segment, from the beginning, to find the label, when executing
&-	the &goto &ec_name at the beginning of the segment.
&- ---------------------------------------------------------------------------
&-
&label make_dir
&trace off
&if &[not [exists directory &(1)]]
&then &do
   create_dir &(1)
   &if &[exists argument &(3)]
   &then &do
      move_quota &1 &3
      &if &[equal [wd] >] &then move_dir_quota &(1) &(3)
      &if &[equal [wd] >udd] &then move_dir_quota &(1) &(3)
      &if &[equal [wd] >user_dir_dir] &then move_dir_quota &(1) &(3)
   &end
&end
&- Set the ACL appropriately
set_acl &(1) sma *.SysDaemon sma *.SysAdmin &f4
&- Get rid of redundant acl term for Initializer.SysDaemon
delete_acl &(1) -brief
set_iacl_seg &(1) rw *.SysAdmin
set_iacl_dir &(1) sma *.SysAdmin
&- Add the specified name
&if &[not [equal x x&(2)]]
&then &if &[not [exists entry &2]] &then add_name &(1) &(2)
&-
&quit
&-
&- ------------------------------------------------------------
&-
&label dir_addname
&trace off
&- USAGE ec &ec_dir>dir_addname PRIMARY_NAME ADDITIONAL_NAMES
&-                               &1           &f2
&-
&if &[exists directory &(1)]
&then &do
   &if &[exists argument &(2)]
   &then add_name &(1) &f(2) -brief
&end
&else &print (asu.ec): directory &1 not found.  Unable to add names to it.
&quit
&-
&- add_project:  This entry will create one project with the specified
&-   name and other information.  It calls new_proj to create the project.
&-
&label add_project
&trace off
&if &[not [exists argument &(6)]] &then &do
    &print (add_project.ec): Usage: ec add_project Name Alias Title Quota Attributes Min_Ring
    &quit
&end
&set NAME &(1)
&set ALIAS &(2)
&set TITLE "&(3)"
&set QUOTA &(4)
&-
&if &[equal &r(5) ""]
   &then &set ATTRIBUTES ""
&else &set ATTRIBUTES &(5)
&-
&set MIN_RING &(6)
&attach
new_proj &(NAME)
&- Title
&(TITLE)
&- Investigator
System Administration
&- Investigator Address
System Administration
&- Supervisor
=
&- Phone
unknown_phone
&- Account
nonbill
&- req
nonbill
&- amount

&- cutoff

&- billing name
System Administration
&- Billing Address
System Administration
&- Alias
&(ALIAS)
&- Administrator

&- abs-max-fg-cpu

&- auth
system_low
&- audit

&- quota
&(QUOTA)
&- dir_quota

&- rate structure

&- group
System
&- groups

&- Attributes
&(ATTRIBUTES)
&- grace

&- min_ring
&(MIN_RING)
&- max_ring

&- pdir_quota
1000
&- max_fg

&- max_bg

&- review?
no
&- project dir LV

&- Users (add a dummy, we will replace the PMF later)
SA1
.
&detach 
&quit
&-
&- add_person:  This entry adds a user_id to the PNT by calling new_user.
&-
&label add_person
&trace off
&if &[not [exists argument &(3)]]
&then &do
   &print (asu.ec (add_person.ec)):  Syntax is:
   &print ec add_person Personid Default_Project Description {Password}
   &quit
&end
&-
&if &[not [exists argument &(4)]]
   &then &set PASSWORD ""
   &else &set PASSWORD &(4)
&-
&attach
new_user
&- Enter full user name (Last, First I.)
*&(3)
&- Enter mailing address
c/o System Administration
&- Enter programmer number or "none"
none
&- Enter notes
Default user
&- Enter default project id or "none"
&(2)
&- Password
&(PASSWORD)
&- Password Again
&(PASSWORD)
&- Network Input Password

&- Password Again

&- Please suggest a userid for <user name>
&(1)
&- Userid assigned is <userid>
&- Is this ok?
yes
&- More users to add?
no
&detach
&quit
&-
&- edit_ssu:  This entry edits the system_start_up.ec to reflect the 
&-   use of a message coordinator terminal.  It is only called if
&-   a message coordinator channel has been specified in the call
&-   to acct_start_up.ec.
&-
&label edit_ssu
&trace off
&if &[not [exists argument &(2)]]
&then &do
   &print (asu.ec): Syntax is:
   &print (asu.ec): ec edit_ssu ssu_path mc_channel
   &quit
&end
&if &[not [exists entry &(1)]]
&then &do
   &print (asu.ec): System_start_up.ec segment &1 not found.
   &quit
&end
&set SSU_PATH &(1)
&set MC_CHANNEL &(2)
&attach
qedx
r &(SSU_PATH)
/^&AMP sc_command accept a.h000/a
sc_command accept &(MC_CHANNEL)
sc_command redefine default_vcons otw_ tty &(MC_CHANNEL)
\f
/^sc_command define scc tty otw_/s/otw_/&(MC_CHANNEL)/
/^sc_command define asc tty otw_/s/otw_/&(MC_CHANNEL)/
/^sc_command define ioc tty otw_/s/otw_/&(MC_CHANNEL)/
/^sc_command define bkc tty otw_/s/otw_/&(MC_CHANNEL)/
w
q
&detach
&quit
&-
&- 
&-  
&- acct_start_up: This entry is the driver for the accounting startup
&-   procedure.  It sets up the directories off the root, sets up
&-   >system_control_1, >udd>SysAdmin>admin, >udd>SysAdmin>library,
&-   and other directories necessary for running a service Multics.
&-   It registers various projects and various userids necessary for
&-   proper running of Multics.
&-
&label acct_start_up
&label asu
&print (asu.ec): Multics Accounting Startup (version of 87-08-28 for MR12.1)
&if &[not [exists argument &(1)]]
&then &do
	&print (asu.ec): Syntax is:
	&print (asu.ec): ec asu [cold | cold2] channel
	&quit
&end
&-
&if &[exists argument &(2)]
&then &set MC_CHANNEL &(2)
&else &set MC_CHANNEL otw_
&-
&if &[exists argument &(3)]
&then &set ROOT &(3)
&else &set ROOT >
&-
&-
&if &[exists argument &(4)]
&then &do
      &set TEST true
      &if &[equal &(4) lgtest]
      &then &trace on &all
      &else &if &[equal &(4) test]
      &then &trace &command on
&end
&else &set TEST false
&-
&if &[exists argument &(5)]
&then &set RESTART_LABEL &(5)
&else &set RESTART_LABEL ""
&-
&set ACTION &(1)
&-
&if &[equal &(ROOT) >]
&then &do
   &set TOOLS >system_library_tools
   &set SC1 >system_control_1
   &set UDD >user_dir_dir
   &set SITE >site
&end
&else &do
   &set TOOLS &(ROOT)>system_library_tools
   &set SC1 &(ROOT)>system_control_1
   &set UDD &(ROOT)>user_dir_dir
   &set SITE &(ROOT)>site
&end
&-
&goto &(ACTION)
&-
&-	&1 - cold, cold1, cold2, reload (ACTION)
&-	&2 - a.hNNN
&-	&3 - root directory
&-	&4 - test flag
&-	&4 - <restart label> (RESTART_LABEL)
&-
&-  &1:	cold and cold1 are synonymous, for the first part of coldstart
&-	cold2 is for the second part of coldstart
&-	reload stops after the first part of cold1, just before
&-	        the contents of >system_control_1 are initialized
&-
&-  &2:	F.ANSS is the terminal line reserved for the message coordinator
&-        (e.g. a.h000, but may also be "otw_")
&-        where:
&-		F  = FNP tag (a-h)
&-		A  = Adaptor type (h= hsla)
&-		N  = Adaptor number (0-2 for hsla)
&-		SS = Decimal subchannel number of specified adaptor
&-
&-  &3:	The third argument is the pathname of the directory to be
&-	used as the root directory.  The test hierarhcy is built
&-	starting at this directory rather than off the root.
&-
&-  &4:   Specifies the type of exec_com tracing to be used.  If it is
&-	lgtest, then both command and input tracing is done.  If
&-	it is test, then only command tracing is done.
&-
&-  &5:	the fifth argument allows the first part of coldstart to be 
&-	restarted at an arbitrary point, after it has aborted for some 
&-	reason. (Coldstart can not be restarted from the beginning because
&-	it assumes the segments that it creates do not exist yet, and the
&-	first "<thing> already exists; do you want to delete it?" question
&-	would eat the rest of the exec_com, looking for a "yes" or "no"
&-	answer (we run with &attach on all the time)).
&-
&-	To restart, do the following:
&-	1) Fix the problem that caused the abort.
&-	2) Optionally, re-execute the command that aborted.
&-	3) Choose a spot, either before or after the command that aborted,
&-	   at which to restart.
&-	4) Edit >tools>asu.ec, inserting some label at the chosen restart
&-	   point. A label of the form: &label restart_<name> is suggested,
&-	   to avoid possible conflicts with existing labels.  Note: if there
&-	   is an existing label at or before the chosen restart point, and
&-	   it is certain that any intervening commands will not ask any 
&-	   questions as a result of being executed twice, then the existing
&-	   label can be used, avoiding the need to edit asu.ec.
&-	5) change_wdir to the directory that should be the current working
&-	   directory at the chosen restart point (read asu.ec to determine
&-	   this).
&-	6) ec >tools>asu Arg1 Arg2 "" "" <label>
&-	   e.g., ec >t>asu cold a.h000 "" "" restart_1
&-	   to restart at the inserted label &label restart_1.
&-
&- ============================================================================
&-
&label cold
&label cold1
&label part1
&label reload
&-
&if &[equal &(MC_CHANNEL) otw_] &then &goto have_init_line
&if &[not [equal [length &(MC_CHANNEL)] 6]] &then &goto illegal_line
&if &[not [equal [substr &(MC_CHANNEL) 2 1] .]] &then &goto illegal_line
&if &[equal [index abcdefgh [substr &(MC_CHANNEL) 1 1]] 0]
&then &do
	&print (asu.ec): Illegal FNP tag specified for initializer terminal line, &(MC_CHANNEL)
	&quit
&end
&if &[not [equal [substr &(MC_CHANNEL) 2 2] .h]]
&then &do
&label illegal_line
	&print (asu.ec): &(MC_CHANNEL) must of form "F.ANSS" or be "otw_"
	&print (asu.ec): F  = FNP tag. (a-h)
	&print (asu.ec): A  = adaptor type (h = hsla)
	&print (asu.ec): N  = Adaptor no. (0-2 for hsla)
	&print (asu.ec): SS = decimal subchan number
	&quit
&end
&-
&if &[equal [index 012 [substr &(MC_CHANNEL) 4 1]] 0]
&then &do
	&print (asu.ec): Illegal HSLA adapter number specified for initializer terminal line, &(MC_CHANNEL)
	&quit
&end
&-
&if &[greater [substr &(MC_CHANNEL) 5 2] 31]
&then &do
	&print (asu.ec): Illegal HSLA subchannel specified for initializer terminal line, &(MC_CHANNEL)
	&quit
&end
&-
&label have_init_line
&-
&if &[exists argument &(RESTART_LABEL)]
&then &do
	&print (asu.ec): will restart at label "&(RESTART_LABEL)"
	&print (asu.ec): your working directory is:
	pwd
	&attach
	&goto &(RESTART_LABEL)
&end
&-
&- This section is to be run from the initializer console when the system 
&- comes to console level after the cold boot. You should be in ring 4 at
&- this point, as a result of a "standard" command to the ring-1 environment
&- and in the root directory.  In the "test" mode, the "root" is wdir at the
&- start of execution.
&-
&attach
&-
change_wdir &(ROOT)
&-
&print (asu.ec): Root segment quota is:
get_quota
&print (asu.ec): Root directory quota is:
get_dir_quota
&-
&print (asu.ec): Setting up directories off the root
&-
&- First, put additional names onto directories reloaded from the 
&- distribution tapes.
ec &ec_dir>dir_addname system_library_standard standard sss SSS
&+ system_library_languages languages lang LANG
ec &ec_dir>dir_addname system_library_tools tools t TOOLS T
ec &ec_dir>dir_addname system_library_obsolete obsolete obs OBS
ec &ec_dir>dir_addname system_library_tandd firmware firm
&-
&- Now, create some more directories
&-
ec &ec_dir>dir_addname system_control_1 sc1 system_control_dir
move_quota system_control_1 5000
set_acl system_control_1 sma *.SysAdmin s *.*.* -rp
set_iacl_dir system_control_1 sma *.SysAdmin s *.*.*
set_iacl_seg system_control_1 rw *.SysAdmin
&-
ec &ec_dir>make_dir user_dir_dir udd 20000
set_acl user_dir_dir sma *.SysAdmin s *.*.* -rp
set_iacl_dir user_dir_dir sma *.SysAdmin
set_iacl_seg user_dir_dir rw *.SysAdmin
&-
ec &ec_dir>make_dir documentation doc 1500
set_acl documentation sma *.SysAdmin s *.*.* -rp
set_iacl_dir documentation sma *.SysAdmin s *.*.*
set_iacl_seg documentation r *.*.*
&-
ec &ec_dir>make_dir library_dir_dir ldd 30000
set_acl library_dir_dir sma *.SysAdmin s *.*.* -rp
set_iacl_dir library_dir_dir sma *.SysAdmin s *.*.*
set_iacl_seg library_dir_dir r *.*.*
&-
ec &ec_dir>make_dir daemon_dir_dir ddd 2000
set_acl daemon_dir_dir sma *.SysAdmin sma *.Daemon s *.*.* -rp
set_iacl_dir daemon_dir_dir sma *.SysAdmin sma *.Daemon
set_iacl_seg daemon_dir_dir rw *.SysAdmin
&-
ec &ec_dir>make_dir site "" 5000
set_acl site sma *.SysAdmin s *.*.* -rp
set_iacl_seg site r *.*.*
set_iacl_dir site s *.*.*
&-
ec &ec_dir>make_dir dumps "" 5000
set_acl dumps sma *.SysAdmin sma *.Daemon -rp
set_iacl_dir dumps sma *.SysAdmin
set_iacl_seg dumps rw *.SysAdmin rw *.Daemon
&-
change_wdir dumps
ec &ec_dir>make_dir save_pdirs saved_pdirs
set_acl save_pdirs sma *.SysAdmin -rp
set_iacl_seg save_pdirs rw *.SysAdmin
&-
change_wdir &(ROOT)
&-
&- ***** in case this installation did not buy the unbundled software.
ec &ec_dir>make_dir system_library_unbundled unbundled 7000
ec &ec_dir>dir_addname system_library_unbundled unb UNB
set_acl system_library_unbundled sma *.SysAdmin s *.*.* -rp
&-
&- ***** also avoid trouble caused by >am not existing
ec &ec_dir>make_dir system_library_auth_maint auth_maint 1000
ec &ec_dir>dir_addname system_library_auth_maint am
set_acl system_library_auth_maint sma *.SysAdmin s *.*.* -rp
&-
&- ***** make directory for 3rd party software *****
ec &ec_dir>make_dir system_library_3rd_party sl3p 1000
set_acl system_library_3rd_party sma *.SysAdmin s *.*.* -rp
&-
&- Set default homedir for initializer if not "test" mode
&if &[not &(TEST)]
   &then change_default_wdir system_control_1
&-
change_wdir documentation
ec &ec_dir>make_dir info_segments info
set_acl info_segments sma *.SysAdmin s *.*.* -rp
set_iacl_seg info_segments r *.*.*
&-
ec &ec_dir>make_dir iml_info
set_acl iml_info sma *.SysAdmin s *.*.* -rp
set_iacl_seg iml_info r *.*.*
&-
change_wdir &(SITE)
ec &ec_dir>make_dir mail_system_dir mail_system 0
ec &ec_dir>dir_addname mail_system_dir mlsys
set_acl mail_system_dir sma *.SysAdmin s *.*.* -rp
set_iacl_seg mail_system_dir r *.*.*
set_iacl_dir mail_system_dir s *.*.*
&-
change_wdir &(ROOT)
&-
&print (asu.ec): Setting up directories off daemon_dir_dir
change_wdir daemon_dir_dir
ec &ec_dir>make_dir cards card_pool 500
set_acl cards sma *.SysAdmin s *.*.* -rp
ec &ec_dir>make_dir io_daemon_dir idd
set_acl idd sma *.SysAdmin s *.*.* -rp
&-
change_wdir io_daemon_dir
&print (ssu.ec): Creating iod_tables.iodt
copy &(TOOLS)>iod_tables.iodt -force
set_acl iod_tables.iodt rw *.SysAdmin r *.*.* -rp
iod_tables_compiler iod_tables
set_acl iod_tables r *.*.* -rp
copy iod_tables iod_working_tables -force
set_acl iod_working_tables r *.*.* -rp
create_daemon_queues -dr [wd]
set_acl printer_(1 2 3).ms adros *.SysDaemon.* adros *.SysAdmin aros *.*.* -rp
set_acl punch_(1 2 3).ms adros *.SysDaemon.* adros *.SysAdmin aros *.*.* -rp
&-
&print (asu.ec): Setting up directories off user_dir_dir
change_wdir &(UDD)
&-
&- Note that addnames will be placed on these directories automatically
&-  by new_proj later on.
&-
ec &ec_dir>make_dir SysAdmin "" 5000
ec &ec_dir>make_dir SysDaemon "" 5000
ec &ec_dir>make_dir Daemon "" 1000 s *.Daemon
ec &ec_dir>make_dir Operator "" 100 s *.Operator
ec &ec_dir>make_dir Terminals "" 10 s *.Terminals
ec &ec_dir>make_dir HFED "" 5000 s *.HFED
&-
change_wdir &(UDD)>Daemon
ec &ec_dir>make_dir Volume_Dumper vld 0
set_acl Volume_Dumper sma *.SysAdmin sma Volume_Dumper.Daemon
&+ sma Volume_Reloader.Daemon sma Volume_Retriever.Daemon s *.Daemon -rp
set_iacl_seg Volume_Dumper rw *.SysAdmin rw Volume_Dumper.Daemon
&+ rw Volume_Reloader.Daemon rw Volume_Retriever.Daemon
&-
change_wdir &(UDD)>Daemon>Volume_Dumper
archive xf &(TOOLS)>asu_data volume_sys_vols.dump
delete sys_vols.dump -force -brief
rename volume_sys_vols.dump sys_vols.dump
set_acl sys_vols.dump [lis] -rp
&-
change_wdir &(UDD)>Operator
ec &ec_dir>make_dir Operator
set_acl Operator sma *.SysAdmin sma *.Operator -rp
&-
change_wdir &(UDD)>Terminals
ec &ec_dir>make_dir anonymous
set_acl anonymous sma *.SysAdmin sma *.Terminals -rp
&-
change_wdir &(UDD)>HFED
ec &ec_dir>make_dir anonymous
set_acl anonymous sma *.SysAdmin sma *.HFED -rp
&-
change_wdir &(UDD)>SysAdmin
ec &ec_dir>make_dir SA1 sa1
set_acl SA1 sma *.SysAdmin -rp
set_iacl_seg SA1 rw *.SysAdmin
&-
ec &ec_dir>make_dir Repair
set_acl Repair sma *.SysAdmin -rp
set_iacl_seg Repair rw *.SysAdmin
&-
change_wdir &(UDD)>SysDaemon
ec &ec_dir>make_dir IO
ec &ec_dir>make_dir Backup
ec &ec_dir>make_dir Dumper
ec &ec_dir>make_dir Retriever
ec &ec_dir>make_dir Repair
ec &ec_dir>make_dir Scavenger
ec &ec_dir>make_dir Salvager
ec &ec_dir>make_dir Utility
&-
copy &(TOOLS)>salvager_start_up.ec Salvager>start_up.ec -force
copy &(TOOLS)>scavenger_start_up.ec Scavenger>start_up.ec -force
copy &(TOOLS)>utility_start_up.ec Utility>start_up.ec -force
&-
cwd Backup
archive xf &(TOOLS)>asu_data hierarchy_sys_dirs.dump
delete sys_dirs.dump -force -brief
rename hierarchy_sys_dirs.dump sys_dirs.dump
set_acl sys_dirs.dump rw *.SysDaemon rw *.SysAdmin -rp
&-
cwd &(SC1)
&-
&if &[equal &(ACTION) reload]
&then &do
	&print (asu.ec): Root reload complete.
	&print (asu.ec): Ready for further reloads by daemons.
	&quit
&end
&-
&- 
&-
&print (asu.ec): Setting up contents of system_control_1
&print (asu.ec): Creating administrative directories in system_control_1
&if &[exists directory pdt]
   &then answer yes -bf  delete pdt>** -force -brief
&if &[exists directory update]
   &then answer yes -bf delete update>** -force -brief
ec &ec_dir>make_dir pdt
ec &ec_dir>make_dir heals_dir
ec &ec_dir>make_dir update
ec &ec_dir>make_dir volume_backup_accounts vba
&-
&- Set up directory for Message Coordinator ACS segments
&-
ec &ec_dir>make_dir mc_acs
&-
&- Set up ACSs for administratively controlled functions
&-
ec &ec_dir>make_dir admin_acs proxy
change_wdir admin_acs
delete ** -force -brief
create absentee_proxy.acs
set_acl absentee_proxy.acs e *.SysDaemon e *.SysAdmin -rp
create tandd.acs
set_acl tandd.acs rw *.SysAdmin -rp
create sat.install.acs
set_acl sat.install.acs rw *.SysAdmin -rp
create cdt.install.acs
set_acl cdt.install.acs rw *.SysAdmin -rp
create rtdt.install.acs
set_acl rtdt.install.acs rw *.SysAdmin -rp
create mgt.install.acs
set_acl mgt.install.acs rw *.SysAdmin -rp
create bump_user.acs
set_acl bump_user.acs rw Data_Management.Daemon -rp
create process_termination_monitor.acs
set_acl process_termination_monitor.acs rw Data_Management.Daemon -rp
create communications.acs
set_acl communications.acs rw *.SysDaemon rw *.SysAdmin -rp
create set_proc_required.acs
set_acl set_proc_required.acs rw *.SysDaemon rw *.SysAdmin rw *.SysMaint -rp
set_max_length **.acs 0
&-
change_wdir &(SC1)
&- copy default start_up.ec from tools
copy &(TOOLS)>start_up.ec -force
set_acl start_up.ec rw *.SysDaemon rw *.SysAdmin rw *.SysMaint r * -rp
srb start_up.ec 4 5 5
&- create segment necessary for running ISOLTS
&if &[not [exists segment opr_query_data]]
   &then create opr_query_data
set_acl opr_query_data rw *.SysDaemon rw *.SysAdmin rw *.HFED -rp
&-
&print (asu.ec): Creating message of the day and login help file
archive xf &(TOOLS)>asu_data message_of_the_day login_help connect_help
add_name message_of_the_day motd
set_acl motd rw *.SysAdmin r *.*.* -rp
&if &[not [exists link <documentation>info_segments>motd.info]]
   &then link motd <documentation>info_segments>motd.info
&if &[not [exists link <documentation>info_segments>connect_help.info]]
   &then link connect_help <documentation>info_segments>connect_help.info
&print (asu.ec): Creating user tables, whotab, and log segments
&if &[not [exists segment answer_table]] &then create answer_table
&if &[not [exists segment daemon_user_table]] &then create daemon_user_table
&if &[not [exists segment absentee_user_table]]
   &then create absentee_user_table
&if &[not [exists segment whotab]]
&then &do
   create whotab
   set_acl whotab rw *.SysDaemon r *.*.* -rp
&end
&if &[not [exists segment log]] &then create log
set_acl log r *.SysAdmin
&-
&- -------------------- installation_parms -------------------
&-
&if &[exists segment installation_parms]
   &then delete installation_parms -force -brief
file_output [pd]>junk_
ed_installation_parms
default
yes
w
q
revert_output
set_acl installation_parms rw *.SysDaemon rw *.SysAdmin r *.*.* -replace
&-
&- -------------------- system_start_up.ec -------------------
&-
&print (asu.ec): Creating system_start_up.ec
copy &(TOOLS)>system_start_up.ec -force
&if &[not [equal &(MC_CHANNEL) otw_]]
   &then exec_com &ec_dir>edit_ssu system_start_up.ec &(MC_CHANNEL)
&-
&- ------------------- admin.ec -----------------------------
&-
&print (asu.ec): Creating admin.ec and admin_1.ec
copy &(TOOLS)>admin.ec -force
copy &(TOOLS)>admin_1.ec -force
&-
&- ---------------------- PNT -------------------------------
&-
&print (asu.ec): Setting up Person Name Table (PNT)
&if &(TEST)
   &then pnt_manager_$test [wd]
&-
&if &[exists entry PNT.pnt]
   &then delete PNT.pnt
create_pnt PNT.pnt -size 1000
set_acl PNT.pnt rw *.SysDaemon rw *.SysAdmin null * -replace
&-
change_wdir &(ROOT)
&-
&print (asu.ec): Setting up administrative library.
exec_com &ec_dir>setup_sysadmin_lib &(ROOT) &(TEST)
&-
&print (asu.ec): Setting up system administration data directory
exec_com &ec_dir>setup_sysadmin_admin &(ROOT) &(TEST)
&-
&print (asu.ec): Setting up SA1.SysAdmin
change_wdir &(UDD)>SysAdmin>SA1
archive xf &(TOOLS)>asu_data SA1_start_up.ec
delete start_up.ec -force -brief
rename SA1_start_up.ec start_up.ec
set_acl start_up.ec rw *.SysAdmin -rp
&-
&if &[not [exists segment SA1.mbx]]
   &then mbcr SA1.mbx
&- Following line commented out because suffix_mbx_$replace_acl
&-   has a bug which blows out the system free area if called.
&-
&- set_acl SA1.mbx adros SA1.SysAdmin aros *.SysAdmin aos *.*.* -rp
&-
&print (asu.ec): Creating links under ldd for the gls command
change_wdir &(ROOT)
change_wdir library_dir_dir
&if &[not &(TEST)]
   &then answer yes ec &(TOOLS)>create_gls_links
&-
change_wdir &(SC1)
&print (asu.ec): Continue with the next step in the Installation Instructions.
&print
&quit
&- 
&-
&- This section completes the accounting startup, by setting access for 
&- all users on the various segments created by the answering service 
&- when "multics" was typed, and installing the SAT and some PDT's, now
&- that "install" is turned on.  Your environment should be in admin mode
&- on the initializer process in ring 4, with your working directory set 
&- to >system_control_1.
&-
&label part2
&label cold2
&print (asu.ec): Now setting all access.
&if &[not [exists directory rcp]] &then create_dir rcp
set_acl rcp sma *.SysAdmin
&-
set_acl as_logs sma *.SysAdmin
set_iacl_seg as_logs r *.SysAdmin
set_acl as_logs>** r *.SysAdmin -brief
&-
move_quota syserr_log 1000
set_acl syserr_log sma *.SysAdmin
set_iacl_seg syserr_log r *.SysAdmin
set_acl syserr_log>** r *.SysAdmin -brief
&-
set_acl admin_acs sma *.SysAdmin
&-
&- Next line sets access to all directories under the ROOT for *.SysAdmin
set_acl <([dirs <**]) sma *.SysAdmin
&-
&if &[exists segment login_help] &then set_acl login_help r *.*.*
&if &[exists segment connect_help] &then set_acl connect_help r *.*.*
&if &[exists segment whotab] &then set_acl whotab r *.*.*
&if &[exists segment motd] &then set_acl motd r *.*.*
&if &[exists segment ttt]
&then &do
   lsa ttt r *.*.*
   srb ttt 4 5 5
&end
&if &[exists segment rtdt]
&then &do
  set_acl rtdt r *.*.*
  set_ring_brackets rtdt 4 5 5
&end
&- now to get the HEALS stuff going
set_acl heals_dir sma *.SysDaemon.* sma *.SysAdmin.* s *.HFED.*
&- in test mode the following will fail so skip if test
&if &[not &(TEST)]
&then &do
   update_heals_log
   set_acl heals_dir>heals_log rw *.SysDaemon.* rw *.SysAdmin.* r *.HFED.*
   set_acl heals_dir>heals_log_info rw *.SysDaemon.* rw *.SysAdmin.* r *.HFED.*
&end
&-
&- Data_Management.Daemon needs access to several tables:
&-
set_acl >sc1>(answer_table absentee_user_table daemon_user_table)
&+	r Data_Management.Daemon
&-
change_wdir &(UDD)>SysAdmin>admin
&-
&print (asu.ec): Now running daily_summary
daily_summary -nosum -nocutr
&-
&print (asu.ec): Now installing SAT
install smf.cur.sat
&print (asu.ec): Pausing 10 seconds to allow completeion of SAT installation
pause 10
&print (asu.ec): End of pause
&-
cwd &(SC1)
&-
&- set zero max length on the acs segments
set_max_length rcp>**.acs 0
&-
set_special_password operator_admin_mode -none
&print (asu.ec): Entering admin mode currently does not require a password.
&print (asu.ec): To set one, type the following command line which will prompt
&print (asu.ec): for the password:
&print
&print (asu.ec): set_special_password operator_admin_mode
&print
&print (asu.ec): End of accounting cold start part 2.
&quit
&-
&label setup_sysadmin_lib
&trace off
&default &undefined false
&-
&- Arguments: 	&1 = root directory
&-		&2 = test flag
&if &[not &[exists argument &1]]
&then &do
	&print (asu.ec (setup_sysadmin_lib.ec)): Argument 1 not supplied.
	&quit
&end
&-
&set ROOT &1
&if &[equal &(ROOT) >]
&then &do
	&set TOOLS >system_library_tools
	&set UDD >user_dir_dir
&end
&else &do
	&set TOOLS &(ROOT)>system_library_tools
	&set UDD &(ROOT)>user_dir_dir
&end
&set WDIR &[wd]
&-
cwd &(UDD)>SysAdmin
ec &ec_dir>make_dir library lib
add_name library l
cwd library
&-
&print (asu.ec): Creating sys_admin_data.
&if &[not [exists segment sys_admin_data]]
   &then create sys_admin_data
&-
admin_util set b1 "INTER"
admin_util set b2 "DEPARTMENT"
admin_util set b3 "MAIL"
admin_util set user_accts "User Accounts Office"
admin_util set user_accts_addr "(address)"
admin_util set user_accts_phone "(phone)"
admin_util set attributes "anonymous,bumping,brief,vinitproc,vhomedir,
&+nostartup,^no_primary,^no_secondary,^no_edit_only,^daemon"
admin_util set group Other
admin_util set grace 2880
admin_util set init_ring 4
admin_util set max_ring 5
&-
&print (asu.ec): Creating sys_admin.value.
answer yes -brief value_set -pn sys_admin accounting_start_up_time [clock calendar_clock]
&-
&- The values specified below are schedule dependent and can be
&- changed to conform to local operations.
&-
value_set -pn sys_admin crank_time 0300.
&- NOTE that disk_time should be before crank_time
value_set -pn sys_admin disk_time 0230.
value_set -pn sys_admin admin_online "SA1.SysAdmin"
value_set -pn sys_admin log_number 0
value_set -pn sys_admin abort_crank false
&-
&- The value command/active function allows an arbitrary set of named values
&- to be defined by value_set -pn sys_admin and later retrieved by [value_get -pn sys_admin ...].
&- The settings of the following values, used to address dprinted reports
&- to administrators and system programmers, are commented out to avoid
&- the printing of many copies of reports addressed to fictitious people
&- at a new installation. (Reports addressed to undefined values are not 
&- printed.)
&-
&- The installation is advised to examine the following, and the usage
&- of these named values in master.ec (crank and disk_auto sections) and 
&- biller.ec,
&- and set up values with appropriate names, defining the proper
&- recipients of the various reports, at this installation.
&-
&- By default, one copy of every report produced by the above ecs
&- will be dprinted addressed to "SYSTEM ADMINISTRATOR".
&-
value_set -pn sys_admin default_dest "SYSTEM"
value_set -pn sys_admin default_addr "ADMINISTRATOR"
&- value_set -pn sys_admin admin(0 1)_dest """ADMINISTRATOR"""
&- value_set -pn sys_admin admin(0 1)_addr "[long_date]"
&- value_set -pn sys_admin accts0_dest """USER ACCOUNTS"""
&- value_set -pn sys_admin accts0_addr "[long_date]"
&- value_set -pn sys_admin assurance(0 1)_dest """SYSTEM ASSURANCE"""
&- value_set -pn sys_admin assurance(0 1)_addr "[long_date]"
&- value_set -pn sys_admin sysprg(0 1 2)_dest """SYSTEM PROGRAMMING"""
&- value_set -pn sys_admin sysprg(0 1 2)_addr "[long_date]"
&- value_set -pn sys_admin director(0 1 2 3 4 5 6 7)_dest """DIRECTOR"""
&- value_set -pn sys_admin director(0 1 2 3 4 5 6 7)_addr "[long_date]"
&-
&print (asu.ec): Creating prototype pmf for all normal projects
archive xf &(TOOLS)>asu_data prototype.pmf
archive xf &(TOOLS)>asu_data prototype_pmf
&-
&print (asu.ec): Copying master.ec, biller.ec, err.ec, and util.ec
copy &(TOOLS)>(master biller err util).ec -force
&-
&print (asu.ec): Copying crank.absin
copy &(TOOLS)>crank.absin -force
add_name crank.absin dodrp.absin run.absin weekly.absin
&-
archive xf &(TOOLS)>asu_data daily_report.control
&-
&print (asu.ec): Copying other miscellaneous segments
archive xf &(TOOLS)>asu_data accounts.info starname_list
copy &(TOOLS)>(dds.absin *.ssl) -force
&quit
&-
&label setup_sysadmin_admin
&trace off
&default &undefined false
&-
&- Arguments:	&1 = root directory
&-		&2 = test flag
&if &[not [exists argument &1]]
&then &do
	&print (asu.ec (setup_sysadmin_admin.ec)): Argument 1 not supplied.
	&quit
&end
&-
&set ROOT &(1)
&if &[exists argument &(2)]
   &then &set TEST &(2)
   &else &set TEST false
&-
&if &[equal &(ROOT) >]
&then &do
	&set TOOLS >system_library_tools
	&set UDD >user_dir_dir
	&set SC1 >system_control_1
	&set SITE >site
&end
&else &do
	&set TOOLS &(ROOT)>system_library_tools
	&set UDD &(ROOT)>user_dir_dir
	&set SC1 &(ROOT)>system_control_1
	&set SITE &(ROOT)>site
&end
&set WDIR &[wd]
&-
cwd &(UDD)>SysAdmin
ec &ec_dir>make_dir admin a 2000
change_wdir admin
&-
&- Link to sys_admin_data, value_seg, prototype.pmf, prototype_pmf, master.ec
&-    biller.ec, err.ec, util.ec, crank.absin, daily_report.control, 
&-    accounts.info, syserr_select_file, log_select_file, starname_list,
&-    dds.absin
&-
&- Following line can be replaced with unlink ** -brief -force when available
discard_output -osw error_output unlink ** -force
&-
link <lib>** -cpnm
ec &ec_dir>make_dir history h
ec &ec_dir>make_dir safe_pdts
ec &ec_dir>make_dir safe_registries
ec &ec_dir>make_dir HF
&-
&- -------------------- SAT -------------------
&-
&print (asu.ec): Creating working copy of the System Administrator Table (SAT)
delete smf.cur.sat -force -brief
create_sat smf.cur.sat
set_acl smf.cur.sat rw *.SysDaemon rw *.SysAdmin null * -replace
&-
admin_util set uwt 10 process_overseer_
admin_util set uwt 10 project_start_up_
admin_util set uwt 10 >system_library_tools>iod_overseer_
&-
admin_util set administrator1 *.SysAdmin
admin_util set administrator2 *.SysDaemon
&-
&print (asu.ec): Generating empty files for billing programs
&if &[not [exists segment miscfile]]
   &then create miscfile
&-
delete projfile -force -brief
create_projfile projfile
&-
delete reqfile -force -brief
create_reqfile reqfile
&-
&- - - - - - - - - - - - - MGT - - - - - - - - - - - - -
&-
&print (asu.ec): Creating Master Group Table (MGT)
&if &[exists segment MGT.mgt]
   &then delete MGT.mgt -force
file_output [pd]>junk_
&attach
ed_mgt MGT
a System 4.0
w
q
&detach
revert_output
&-
copy MGT.mgt &(SC1)>mgt -force
set_acl &(SC1)>mgt rw Initializer.SysDaemon r *.SysAdmin -replace
&if &[not [exists entry &(SC1)>master_group_table]]
&then add_name &(SC1)>mgt master_group_table
&-
&- Create various projects
&if &(TEST)
&then &do
   pnt_manager_$test [wd]
   new_proj$test &(SC1) &(UDD)
   link &(SC1)>PNT.pnt
&end
&-
&print (asu.ec): Creating SysAdmin, SysDaemon, Daemon, Operator, HFED, 
&print (asu.ec):    and Terminals project
&-
file_output [pd]>junk_ -ssw user_i/o
exec_com &ec_dir>add_project SysAdmin sa "System Administration" 3000
&+ nobump,guaranteed_login,multip,nolist,dialok 1
&-
exec_com &ec_dir>add_project SysDaemon sd "Privileged System Daemons" 1000
&+ nobump,guaranteed_login,multip,nolist,daemon,dialok 1
&-
exec_com &ec_dir>add_project Daemon dmn "System Daemons" 1000
&+ nobump,guaranteed_login,multip,nolist,daemon,dialok 4
&-
exec_com &ec_dir>add_project Operator opr "System Operators" 100 "" 4
exec_com &ec_dir>add_project HFED hfed "Honeywell Field Engineering" 100 "" 4
exec_com &ec_dir>add_project Terminals terms "Terminal Repair" 100 "" 4
&-
revert_output -ssw user_i/o
&-
archive xf &(TOOLS)>asu_data SysAdmin.pmf SysDaemon.pmf Daemon.pmf
&+ Operator.pmf HFED.pmf Terminals.pmf
&-
&print (asu.ec): Installing SAT to define projects
copy smf.cur.sat &(SC1)>sat -force
set_acl &(SC1)>sat rw Initializer.SysDaemon rw *.SysAdmin -no_sysdaemon
&+ -replace
&-
&print (asu.ec): Converting PMFs to PDTs for SysAdmin, SysDaemon and Daemon
cv_pmf (SysAdmin SysDaemon Daemon).pmf
&-
&print (asu.ec): Installing PDTs for SysAdmin, SysDaemon, and Daemon
copy (SysAdmin SysDaemon Daemon).pdt &(SC1)>pdt>== -force
&-
&print (asu.ec): Putting PMFs away into pmf.archive
&if &[exists segment pmf.archive] &then delete pmf.archive -force
&-
archive ad pmf SysAdmin.pmf SysDaemon.pmf Daemon.pmf
&-
&- ------------ URF, MAIL_TABLE -----------
&-
&print (asu.ec): Creating URF, MAIL_TABLE with capacity of 1000 users
&if &(TEST) &then new_user$new_user_test [wd]
&if &(TEST) &then mail_table_priv_$test [path &(SITE)>mail_system_dir]
&if &[exists entry URF]
   &then delete URF -force
create_urf URF -size 1000
&if &[exists entry &(SITE)>mail_system_dir>MAIL_TABLE]
   &then l_rename &(SITE)>mail_system_dir>MAIL_TABLE MAIL_TABLE.[unique]
create_mail_table
&-
&print (asu.ec): Registering Initial Users
&-
file_output [pd]>junk_
ec &ec_dir>add_person Backup SysDaemon "System, Incremental Backup"
ec &ec_dir>add_person Data_Management Daemon "System, Data Management Daemon"
ec &ec_dir>add_person Dumper SysDaemon "System, Complete Dump"
ec &ec_dir>add_person IO SysDaemon "System, Bulk IO"
ec &ec_dir>add_person Operator Operator "System, Operator"
ec &ec_dir>add_person Repair SysAdmin "System, Repair" repair
ec &ec_dir>add_person Retriever SysDaemon "System, Retrievals"
ec &ec_dir>add_person SA1 SysAdmin "System, Restricted Administrator"
ec &ec_dir>add_person Salvager SysDaemon "System, Salvager"
ec &ec_dir>add_person Scavenger SysDaemon "System, Scavenger"
ec &ec_dir>add_person Utility SysDaemon "System, Monitor cleanup"
ec &ec_dir>add_person Volume_Dumper Daemon "System, Volume Backup"
ec &ec_dir>add_person Volume_Reloader Daemon "System, Volume Reload"
ec &ec_dir>add_person Volume_Retriever Daemon "System, Volume Retrieve"
&-
&- Set must_change flag on for Repair since set a password for it
&-   Also give Repair the operator attribute so that it can execute
&-   operator commands.
&-
&attach
new_user$cga Repair flags
must_change,operator
&detach
&-
revert_output
delete [pd]>junk_
&-
&- -------------------- today.use_totals -------------------
&-
&print (asu.ec): Creating use_totals segments
reset_use_totals today.use_totals daily_report.control
reset_use_totals yesterday.use_totals daily_report.control
reset_use_totals last_month.use_totals daily_report.control
&-
&- -------------------- Terminal Type File --------------------
&-
&print (asu.ec): Creating and installing Terminal Type File (TTF)
copy &(TOOLS)>TTF.ttf -force
cv_ttf TTF.ttf
copy TTF.ttt &(SC1)>ttt -force
set_acl &(SC1)>ttt rw Initializer.SysDaemon r * -replace
srb &(SC1)>ttt 4 5 5
&-
&- -------------------- Channel Master File --------------------
&-
&print (asu.ec): Creating and installing Channel Master File (CMF)
copy &(TOOLS)>CMF.cmf -force
cv_cmf CMF.cmf
copy CMF.cdt &(SC1)>cdt -force
set_acl &(SC1)>cdt rw Initializer.SysDaemon r *.SysAdmin -replace
&-
&- ------------- Resource Type Master File -------------
&-
&print (asu.ec): Creating and installing Resource Type Master File (RTMF)
copy &(TOOLS)>RTMF.rtmf -force
cv_rtmf RTMF.rtmf
copy RTMF.rtdt &(SC1)>rtdt -force
set_acl &(SC1)>rtdt rw Initializer.SysDaemon r * -replace
srb &(SC1)>rtdt 4 5 5
&-
&quit
&-
&- ***** END OF asu.ec *****
&-
&label &(1)
&print (asu.ec): Illegal argument &(1)
&quit
