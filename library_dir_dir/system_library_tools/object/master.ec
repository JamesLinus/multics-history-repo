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
&- -
&- -	Multics administrative operations
&- -
&- -	this exec_com does most of the
&- -	day-to-day stuff of adding and deleting users
&- -
&- -	Modified September 1977 by T. Casey for MR6.0
&- -	Modified August 1979 by C. Hornig for MR8.0
&- -	Modified July 1981 by T. Casey for MR9.0
&- -	Modified March 1982 by E. N. Kittlitz for qedx -pathname -no_rw_path.
&- -	Modified September 1982 by E. N. Kittlitz for pmf suffixes.
&- -	Modified February 1984 by Jim Lippard to use the segments command
&- -	instead of check_info_segs.
&-  	Modified 1984-09-04 by E. Swenson for Version 2 PNTs.
&-        Modified 1984-12-11, BIM:  summarize_sys_log, version 2, new value.
&-	Modified 1985-01-10, Keith Loepere, to move dir_quota into new_proj.
&- -					         
&- ---------------------------------------------
&trace &command off
&trace &input off
&goto &1
&- - - - - - - - - - - - - - - - - - - - - - 
&-
&- DO NOT DELETE new_smf. Even though the command has been undocumented,
&- "install sat" or "install smf.cur.sat" will goto new_smf.
&-
&label new_smf
admin_util lock
daily_summary -nosum -nocutr
install smf.cur.sat
admin_util unlock
&quit
&- - - - - - - - - - - - - - - - - - - - - - 
&label pmf
&if &[not [exists argument &2]] &then exec_com err noarg Projectid
admin_util lock
archive x pmf &2.pmf
&if &[not [exists segment &2.pmf]] &then exec_com err no_pmf &2
&print Edit.
qedx -pathname &2.pmf -no_rw_path
cv_pmf &2.pmf
&if &[ngreater [severity cv_pmf] 2] &then delete &2.pmf; exec_com err try_again
archive rd pmf &2.pmf
install &2.pdt
delete &2.pdt
admin_util unlock
&quit
&- - - - - - - - - - - - - - - - - - - - - - 
&label install
&if &[equal &2 sat] &then &goto new_smf
&if &[equal &2 smf.cur.sat] &then &goto new_smf
install &2
&quit
&- - - - - - - - - - - - - - - - - - - - - - 
&label misc
misc
&quit
&label charge
misc$charge
&quit
&label credit
misc$credit
&quit
&label dmisc
misc$dmisc
&quit
&- - - - - - - - - - - - - - - - - - - -
&label new_proj
&if &[not [exists argument &2]] &then exec_com err noarg Projectid
admin_util lock
new_proj &2
cv_pmf &2.pmf
&if &[ngreater [severity cv_pmf] 2] &then exec_com err bad_pmf
daily_summary -nosum -nocutr
install smf.cur.sat
install &2.pdt
delete &2.pdt
&if &[exists segment >udd>&2>&2.pmf]
&then delete &2.pmf
&else archive rd pmf &2.pmf
admin_util unlock
&quit
&- - - - - - - - - - - - - - - - - - - - - - 
&label cu
&- Adding new user &2 on project &3.
&if &[not [exists argument &3]] &then exec_com err noarg Projectid
&if &[not [is_legal_proj &3]] &then exec_com err bad_proj &3
create_dir >user_dir_dir>&3>&2
set_iacl_dir >user_dir_dir>&3>&2 sma *.SysDaemon.*
set_iacl_seg >user_dir_dir>&3>&2 rew *.SysDaemon.*
set_acl >user_dir_dir>&3>&2 sma &2.&3.*
&quit
&- - - - - - - - - - - - - - - - - - - - - - 
&label setdisk
enter_abs_request dodrp -rt -tm [value_get -pn sys_admin disk_time] -queue 1
&quit
&- - - - - - - - - - - - - - - - - - - - - - 
&label disk_auto
&label disk_report
&label drp
&if &[exists segment diskreport] &then truncate diskreport
&print $ Following figure is total quota / current use.
sweep
&label findisk
admin_util lock 1800
value_set -pn sys_admin last_diskreport [clock calendar_clock]
charge_disk
admin_util unlock
file_output diskreport
print_disk
disk_stat_print
ioa_ "^|"
ioa_ "^/Projects 90% or <20"
disklow
ioa_ "^/Projects 80%"
disklow 0 80
ioa_ "^/Projects <40"
disklow 40 100
get_quota > >user_dir_dir >dumps
list_vols
revert_output
&goto &1_end
&label disk_auto_end
exec_com util dp diskreport accts0 2
exec_com util dp diskreport admin0 2
exec_com util dp diskreport admin1 2
exec_com util dp diskreport default 1
enter_abs_request dodrp -rt -tm [value_get -pn sys_admin disk_time] -queue 1
&quit
&-
&label disk_report_end
&label findisk_end
&label drp_end
&quit
&- - - - - - - - - - - - - - - - - - - - - - 
&label rqm
&- Request copies of "&2" for the Multics distribution
&if &[not [exists argument &2]] &then exec_com err noarg file_name
&if &[not [exists file &2]] &then exec_com err nofile &2
exec_com util dp &2 admin0 &3
exec_com util dp &2 admin1 &3
exec_com util dp &2 assurance0 &3
exec_com util dp &2 assurance1 &3
exec_com util dp &2 director0 &3
exec_com util dp &2 director1 &3
exec_com util dp &2 director2 &3
exec_com util dp &2 director3 &3
exec_com util dp &2 director4 &3
exec_com util dp &2 director5 &3
exec_com util dp &2 director6 &3
exec_com util dp &2 director7 &3
exec_com util dp &2 sysprg0 &3
exec_com util dp &2 sysprg2 &3
exec_com util dp &2 default &3
&quit
&- - - - - - - - - - - - - - - - - - - - - - 
&label upmf
admin_util lock
&if &[not [exists argument &3]] &then exec_com err noarg Personid
&- add single user "arg-3" to project "arg-2"
archive x pmf &2.pmf
&if &[not [exists segment &2.pmf]] &then exec_com err no_pmf &2
&attach
qedx -pathname &2.pmf -no_rw_path
$i personid:		&3;
\f
w
q
&detach
cv_pmf &2.pmf
&if &[ngreater [severity cv_pmf] 2] &then delete &2.pmf; exec_com err try_again
install &2.pdt
archive rd pmf &2.pmf
delete &2.pdt
&if &[not [is_he_user &3]] &then &print Warning: &3 not registered.
admin_util unlock
&quit
&- - - - - - - - - - - - - - - - - - - - - - 
&label register
new_user
&quit
&label reg
new_user$nu
&quit
&- - - - - - - - - - - - - - - - - - - - - - 
&label undelegate
&if &[not [exists argument &2]] &then exec_com err noarg Projectid
&if &[exists entry >udd>&2>&2.pmf] &then &else &goto und_not_in_proj_dir
copy >udd>&2>&2.pmf ===.pj
&if &[exists segment &2.pmf.pj] &then &print A copy of >udd>&2>&2.pmf has been saved in [wd]>&2.pmf.pj
&label und_not_in_proj_dir
archive x pmf &2.pmf
&if &[exists segment &2.pmf] &then &else &goto und_not_in_archive
rename &2.pmf &2.pmf.ac
&print A copy of &2.pmf from pmf.archive has been saved in [wd]>&2.pmf.ac
&label und_not_in_archive
exec_com master recov &2
&goto undelegate1
&-
&label delegate
&label add_admin
&if &[exists argument &2] &then &else exec_com err noarg Projectid
&if &[exists argument &3] &then &else &goto delegate_no_pmf_dir
archive x pmf &3>&2.pmf
&if &[exists segment &3>&2.pmf] &then &else &goto delegate_not_pmf_archive_1
&print &2.pmf extracted from pmf.archive into &3 and deleted from archive
archive d pmf &2.pmf
&goto undelegate1
&label delegate_not_pmf_archive_1
exec_com master recov &2 &3
&goto undelegate1
&label delegate_no_pmf_dir
archive x pmf &2.pmf
&if &[exists segment &2.pmf] &then &else &goto delegate_not_pmf_archive
delete &2.pmf
&print &2 remains in pmf.archive. No pmf directory specified.
&goto undelegate1
&label delegate_not_pmf_archive
exec_com master recov &2
&label undelegate1
edit_proj &2 administrator
daily_summary -nosum -nocutr
install smf.cur.sat
&quit
&- - - - - - - - - - - - - - - - - - - - - - 
&label dproj
&if &[not [exists argument &2]] &then exec_com err noarg Projectid
admin_util lock
safety_sw_off >udd>&2
delete_proj &2
daily_summary -nosum -nocutr
install smf.cur.sat
archive d pmf &2.pmf
get_quota >user_dir_dir>&2 >user_dir_dir>&2>**
delete_dir >user_dir_dir>&2
admin_util unlock
&quit
&- - - - - - - - - - - - - - - - - - - - - -
&label pmisc
&- print the miscfile.
misc$print_misc
&quit
&- - - - - - - - - - - - - - - - - - - - - -
&label who_delg
&- see if the given project is delegated and if so to whom.
list_delegated_projects >system_control_1>sat &2
&quit
&- - - - - - - - - - - - - - - - - - - - - - 
&label ison
&if &[not [exists argument &2]] &then exec_com err noarg Person
ioa_ [is_he_user &2]
get_uid_with_lastname &2
&quit
&- - - - - - - - - - - - - - - - - - - - - - 
&label change
new_user$change &f2
&quit
&- - - - - - - - - - - - - - - - - - - - - - 
&label dpmf
admin_util lock
&if &[not [exists argument &3]] &then exec_com err noarg Personid
&- deleting "&3" from proj "&2"
archive x pmf &2.pmf
&if &[not [exists segment &2.pmf]] &then exec_com err no_pmf &2
&attach
qedx -pathname &2.pmf -no_rw_path
$ipersonid:
\f
/^	* *personid:	* *&3;/;/^	* *personid:/-1d
$-1d
w
q
&detach
cv_pmf &2.pmf
install &2.pdt
archive rd pmf &2.pmf
delete &2.pdt
admin_util unlock
&quit
&- - - - - - - - - - - - - - - - - - - - - - 
&label add_anon
&- add anonymous user to proj &2, initpr &3, hdir &4, pass &5 optional
admin_util lock
&if &[not [exists argument &4]] &then exec_com err noarg >user_dir_dir>&2>homedir
archive x pmf &2.pmf
&if &[not [exists segment &2.pmf]] &then exec_com err no_pmf &2
&attach
qedx -pathname &2.pmf -no_rw_path
$i personid:		*;
attributes:	^vinitproc, ^vhomedir, ^nostartup;
homedir:		&4;
initproc:		&3;
&if &[exists argument &5] &then password:	&5;
\f
w
q
&detach
cv_pmf &2.pmf
&if &[ngreater [severity cv_pmf] 2] &then delete &2.pmf; exec_com err try_again
install &2.pdt
delete &2.pdt
archive rd pmf &2.pmf
admin_util unlock
&quit
&- - - - - - - - - - - - - - - - - - - - - - - - -
&label chname
&if &[exists argument &4] &then exec_com err quote_arg
&if &[not [exists argument &2]] &then exec_com err noarg Personid
new_user$change &2 name &3
&quit
&- - - - - - - - - - - - - - - - - - - - - - - - - -
&label chaddr
&if &[exists argument &4] &then exec_com err quote_arg
&if &[not [exists argument &2]] &then exec_com err noarg Personid
&if &[not [is_he_user &2]] &then exec_com err not_user &2
new_user$change &2 addr &3
&quit
&- - - - - - - - - - - - - - - - - - - - - - - - - -
&label chpass
&if &[not [exists argument &2]] &then exec_com err noarg Personid
&if &[not [is_he_user &2]] &then exec_com err not_user &2
new_user$change &2 pass
&quit
&- - - - - - - - - - - - - - - - - - - - -
&label chcpass
&if &[not [exists argument &2]] &then exec_com err noarg_nolock Personid
&if &[not [is_he_user &2]] &then exec_com err not_user &2
new_user$change &2 cpass
&quit
&- - - - - - - - - - - - - - - - - - - - -
&label chalias
&if &[not [exists argument &2]] &then exec_com err noarg Personid
new_user$cga &2 alias &3
&quit
&- - - - - - - - - - - - - - - - - - - - -
&label chdf_proj
&if &[not [exists argument &3]] &then exec_com err noarg Projectid
&if &[not [is_he_user &2]] &then exec_com err not_user &2
new_user$change &2 proj &3
&quit
&- - - - - - - - - - - - - - - - - - - - -
&label chprog
&if &[not [exists argument &2]] &then exec_com err noarg Personid
new_user$change &2 progn &3
&quit
&- - - - - - - - - - - - - - - - - - - - -
&label edit_projfile
&label edit_proj
&label epro
&label edit_reqfile
&label erf
edit_proj &f2 -long
daily_summary -nosum -nocutr
install smf.cur.sat
&quit
&- - - - - - - - - - - - - - - - - - - - -
&label labels
labl1
&quit
&- - - - - - - - - - - - - - - - - - - - -
&label recov
&if &[not [exists argument &2]] &then exec_com err noarg Projectid
&if &[not [is_legal_proj &2]] &then exec_com err noproj &2
admin_util lock
delete &2.pmf -bf
file_output &2.pmf;print_pdt >sc1>pdt>&2.pdt -pmf;revert_output
&if &[exists argument &3] &then &else &goto recov_no_pmf_dir
move &2.pmf &3>==
&print &2.pmf recovered from &2.pdt moved into &3.
&goto recov_unlock
&label recov_no_pmf_dir
archive rd pmf &2.pmf
&print &2.pmf recovered from &2.pdt replaced in pmf.archive.
&label recov_unlock
admin_util unlock
&quit
&- - - - - - - - - - - - - - - - - - - - -
&label bill
admin_util lock
exec_com biller &2 &3 &4 &5 &6 &7 &8 &9
admin_util unlock
&quit
&- - - - - - - - - - - - - - - - - - - - -
&label check_log
print_sys_log -as -nhe -match &2
&quit
&- - - - - - - - - - - - - - - - - - - - -
&label day
&attach
admin_util lock
&if &[not [exists segment crank.absout]] &then exec_com err crank_absout_missing
ioa_ "^/'day' last done ^a ^a ^a ^a^/" [value_get -pn sys_admin crank_absout_read]
value_set -pn sys_admin crank_absout_read [clock calendar_clock]
qedx -pathname crank.absout -no_rw_path
gd/ device detached/
gd/ at end of file/
gd/^summarize_sys_log:/
b1a
b0$-1m7
i \c\b7\c\f
b7
/logged out/;"
b01,$p
q
\f
b2a
\c\b1
eioa_ "^/^/************* ERROR IN CRANK ********^/^/"
b01,$p
eioa_ "^/^/************* ERROR IN CRANK ********^/^/"
eexec_com err crank_abort
Q
\f
\b2
&detach
&label gd_day
admin_util lock
&if &[query Delete?] &then delete crank.absout
admin_util unlock
&quit
&- - - - - - - - - - - - -
&label setcrank
enter_abs_request crank -tm [value_get -pn sys_admin crank_time] -queue 1
&quit
&- - - - - - - - - - - - -
&label crank_fail
cancel_abs_request crank
value_set -pn sys_admin abort_crank false
&goto crank1
&- - - - - - - - - - - - -
&label crank
admin_util lock 1800
enter_abs_request crank -tm [value_get -pn sys_admin crank_time] -queue 1
&if &[value_get -pn sys_admin abort_crank] &then exec_com err crank_abort
&label crank1
value_set -pn sys_admin abort_crank true
value_set -pn sys_admin last_crank [clock calendar_clock]
admin_util lock
&- Clean out volume backup accounting files, if any are present. They are not yet used for accounting.
&if &[exists directory >sc1>vba] &then date_deleter >sc1>vba 7
exec_com util del (yesterday.projfile yesterday.reqfile)
&if &[exists segment sumry] &then truncate sumry
&if &[exists segment cutrpt] &then truncate cutrpt
exec_com util del PNT.safe.pnt
copy >system_control_1>PNT.pnt PNT.safe.pnt -brief
pdt_copy >system_control_dir >system_control_dir>pdt safe_pdts
compute_bill safe_pdts>sat safe_pdts
compute_bill$update_pdts_from_reqfile safe_pdts>sat >sc1>pdt
rename projfile yesterday.projfile
copy yesterday.projfile projfile
rename reqfile yesterday.reqfile
copy yesterday.reqfile reqfile
sort_reqfile reqfile
sort_projfile projfile
iocall attach sumry file_ sumry w
iocall attach cutrpt file_ cutrpt w
daily_summary
iocall detach sumry
iocall detach cutrpt
install smf.cur.sat
value_set -pn sys_admin abort_crank false
exec_com util del daily_log_(0 1 2)
exec_com util del system_logprint
exec_com util del io_logprint
truncate system.report
delete yesterday.use_totals
copy today.use_totals yesterday.use_totals
copy_as_meters meter_data -ri
system_total meter_data today.use_totals
usage_total safe_pdts>sat safe_pdts projfile today.use_totals
&- CREATE usage_and_revenue.control before un-commenting the following line
&- file_output usage_and_revenue.report;usage_and_revenue usage_and_revenue.control today.use_totals yesterday.use_totals;revert_output
&-  ALSO, add a line below to "ec util dp usage_and_revenue.report"
file_output system.report; system_daily_report today.use_totals yesterday.use_totals; revert_output
copy system.report daily_log_0
file_output daily_log_0
get_quota > >user_dir_dir >dumps
ioa_ "Last disk report was ^a ^a ^a ^a^/" [value_get -pn sys_admin last_diskreport]
revert_output
&-  
&label test_log_reporting
&- First attach one switch for each actual printed.
&- 
do "io_call attach &&1 vfile_ &&1;io_call open &&1 stream_output"
&+          (daily_log_0 daily_log_1 daily_log_2 system_logprint io_logprint)
&- Then use syn_ to attach many switches, one per log per type of message
&-    This allows the .ssl control files to be more self-explanatory.

do "io_call attach [do &&&&1 &&1] syn_ [do &&&&2 &&1]"
&+ (
&+  "complete_as          system_logprint"     &- the entire AS log
&+  "complete_as_sv2      system_logprint"     &- all sv2 and above
&+  "as_user_errors	      daily_log_0"	       &- 
&+  "as_events	      daily_log_1"         &- 
&+  "as_important_events  daily_log_2"	       &- things to take special note 
&+  "syserr_non_io	      system_logprint"     &- the entire syserr log
&+  "syserr_user_events   daily_log_0"	       &- syserr events that concern users
&+  "syserr_events	      daily_log_1"	       &- non-routine 
&+  "syserr_errors	      daily_log_2"	       &- really non routine
&+  "io_all	      io_logprint"         &- the io log
&+  "operator_sac	      system_logprint"     &- the admin log
&+  )
&set NOW &[clock calendar_clock]
&set START &[clock calendar_clock [value_get -pn sys_admin last_log_time] +1usec]
value_set -pn sys_admin last_log_time &(NOW)
summarize_sys_log -answering_service -control daily_as_log -from &(START) -to &(NOW)
summarize_sys_log -syserr -control daily_syserr_log -from &(START) -to &(NOW)
summarize_sys_log -admin -control daily_admin_log -from &(START) -to &(NOW)
summarize_sys_log -mc_log iolog -control daily_io_log -from &(START) -to &(NOW)
&- Detach the syn_ switches.
io_call detach (
&+       complete_as
&+       complete_as_sv2
&+       as_user_errors
&+       as_events
&+       as_important_events
&+       syserr_non_io
&+       syserr_user_events
&+       syserr_events
&+       syserr_errors
&+       io_all
&+       operator_sac
&+   )
&- Detach the report switches.
do "io_call close &&1;io_call detach &&1"
&+          (daily_log_0 daily_log_1 daily_log_2 system_logprint io_logprint)

&- specialized reports
&- system_full_report and console_report
&- 
&if &[equal &1 test_log_reporting] &then &quit
&- 
&- delete old junk from the history department
&-
date_deleter history  10 &- that is DAYS
&-
&- move old things to the history department
&- 
move_log_segments syserr_log >sc1>syserr_log history 1day
move_log_segments log >sc1>as_logs history 1day
move_log_segments admin_log >sc1>as_logs history 1day
move_log_segments iolog >sc1>as_logs history 1day
&- add other lines for other logs defined
&- 
update_heals_log
truncate_heals_log 30
remove_registry safe_registries>**
delete_registry safe_registries>**
copy_registry >sc1>rcp>** safe_registries>== -reset
truncate meter_data.print
truncate bwchart.print
file_output meter_data.print; print_meters meter_data; revert_output
file_output bwchart.print; b_and_w today.use_totals last_month.use_totals; revert_output
&- delete yesterday's asdump segments.
do "if [exists argument &&(1)] -then ""exec_com util del &&(1)""" ([segments >system_control_dir>delete.** -absp])
&- snatch today's asdump segments.
do "if [exists argument &&(1)] -then ""entry &&(1);exec_com master grabdump &&(1)""" ([segments >system_control_dir>asdump.** -absp])
&-
&- dprint the reports
&- exec_com util dp system.report director0
exec_com util dp system.report director1
&- exec_com util dp (system.report meter_data.print) director2
exec_com util dp system.report director3
&- exec_com util dp system.report director4
exec_com util dp system.report director5
exec_com util dp (system.report bwchart.print) director6
&- exec_com util dp daily_log_2 assurance0 2
exec_com util dp (daily_log_2 bwchart.print) assurance1 2
exec_com util dp (sumry cutrpt daily_log_0 crank.absout) accts0 2
exec_com util dp (daily_log_1 bwchart.print) admin0 2
exec_com util dp daily_log_2 sysprg2
exec_com util dp (daily_log_0 bwchart.print sumry crank.absout) admin1 2
exec_com util dp (daily_log_0 daily_log_1 daily_log_2 system.report bwchart.print sumry cutrpt meter_data.print crank.absout) default 1
exec_com util dp (system_logprint io_logprint) admin0
exec_com util dp (system_logprint io_logprint) default 1
sms [value_get -pn sys_admin admin_online] "crank ran"
admin_util unlock
&quit
&- - - - - - - - - - - - - - - - - - - - -
&label later
enter_abs_request run -ag &f2
&quit
&- - - - - - - - - - - - - - - - - - - - -
&label proj_mtd
proj_mtd &2
&quit
&- - - - - - - - - - - - - - - - - - - - - - 
&label grabdump
sa &2 rw
abc &2
copy &2 [entry &2]
exec_com util dp [entry &2] admin0
exec_com util dp [entry &2] default 1
add_name [entry &2] delete.[entry &2]
delete &2
&quit
&- - - - - - - - - - - - - - - - - - - - -
&label rename_proj
admin_util lock
&if &[not [exists argument &3]] &then exec_com err noarg New_projectid
rename_proj &2 &3
daily_summary -nosum -nocutr
install smf.cur.sat
archive x pmf &2.pmf
&if &[not [exists segment &2.pmf]] &then &goto rename_ok
rename &2.pmf &3.pmf
&attach
qedx -pathname &3.pmf -no_rw_path
1,$s/&2/&3/
w
q
archive ad pmf &3.pmf
archive d pmf &2.pmf
&label rename_ok
admin_util unlock
&quit
&- - - - - - - - - - - - - - - - - - - - -
&label info
&label help
&attach
qedx -pathname accounts.info -no_rw_path
&if &[exists argument &2] &then /&2/;/^$/p &else 1,$p
q
&quit
&- - - - - - - - - - - - - - - - - - - - -
&label exec_com
&label ec
exec_com >user_dir_dir>SysAdmin>admin>&2 &f3
&quit
&- - - - - - - - - - - - - - - - - - - - -
&label remove_user
remove_user
&quit
&- - - - - - - - - - - - - - - - - - - - -
&label weekly
enter_abs_request weekly -rt -q 1 -tm [value_get -pn sys_admin weekly_time]
&if &[exists segment weekly.report] &then delete weekly.report
&if &[exists segment week_bwchart.list] &then delete week_bwchart.list
file_output week_bwchart.list; b_and_w today.use_totals last_month.use_totals -week; co
&- ec master rqm week_bwchart.list
exec_com util dp week_bwchart.list default 1
file_output weekly.report
list_delegated_projects >system_control_1>sat
print_reqfile
print_projfile
ioa_ ^|
ioa_ "Listing of sys_admin.value^/"
value_list -pn sys_admin
save_dir_info >udd>SysAdmin>admin
comp_dir_info old.admin admin -lg
delete old.admin.dir_info; rename admin.dir_info old.admin.dir_info
list_acl; list_iacl_seg; list_iacl_dir
list -dtm -a
save_dir_info >udd>SysAdmin>lib
comp_dir_info old.lib lib
delete old.lib.dir_info; rename lib.dir_info old.lib.dir_info
list_acl >udd>SysAdmin>lib; list_iacl_seg >udd>SysAdmin>lib; list_iacl_dir >udd>SysAdmin>lib
list -pn >udd>SysAdmin>lib
save_dir_info >system_control_1
comp_dir_info old.system_control_1 system_control_1 -lg
delete old.system_control_1.dir_info; rename system_control_1.dir_info old.system_control_1.dir_info
list_acl >system_control_1; list_iacl_seg >system_control_1; list_iacl_dir >system_control_1
list -pn >system_control_1 -dtm -a
save_dir_info >system_control_1>pdt
comp_dir_info old.pdt pdt -lg
delete old.pdt.dir_info; rename pdt.dir_info old.pdt.dir_info
revert_output
exec_com util dp weekly.report accts0
exec_com util dp weekly.report admin0
exec_com util dp weekly.report admin1
exec_com util dp weekly.report default 1
answer yes -brief copy >system_control_1>rate_structure_* -name -brief
answer yes -bf copy >system_control_1>master_group_table -bf
answer yes -bf copy projfile safe_projfile
answer yes -bf copy reqfile safe_reqfile
answer yes -bf copy >system_control_1>system_start_up.ec -bf
sms [value_get -pn sys_admin admin_online] weekly ran.
exec_com util dp weekly.absout admin1
exec_com util dp weekly.absout default 1
&quit
&- - - - - - - - - - - - - - - - - - - - -
&label change_wdir
change_wdir >user_dir_dir>SysAdmin>admin
&quit
&- - - - - - - - - - - - - - - - - - - - -
&label &1
exec_com err badcom &1
&- - - - - - - - - - - - - - - - - - - - - - - - - -
&- end
