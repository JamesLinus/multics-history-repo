&  ******************************************************
&  *                                                    *
&  * Copyright, (C) Honeywell Bull Inc., 1987           *
&  *                                                    *
&  * Copyright (c) 1972 by Massachusetts Institute of   *
&  * Technology and Honeywell Information Systems, Inc. *
&  *                                                    *
&  ******************************************************

&
& ADMIN.EC - extended operator commands.
&
& This exec_com is invoked from system_control_ when the operator says
&		x function arg1 arg2 ...
&
& "admin" mode is set so that the console which issued the "x" will get the output.
&
&goto &1
&
& MODIFICATION HISTORY
&
& Modified 1895-03-18, BIM: added complete_dump, wakeup_dump, and end_dump
& Modified 1985-05-08, E. Swenson: fixed  requoting problems as per Gary
&   Dixon's changes.
&
& 
&  HISTORY COMMENTS:
&   1) change(87-07-30,Beattie), approve(87-07-20,MCR7743),
&      audit(87-08-04,Brunelle), install(87-08-06,MR12.1-1068):
&      Add check to look for admin_dsa.ec before complaining about
&      functions unknown to this exec_com.  Pass along arguments if
&      found.
&                                                       END HISTORY COMMENTS
& 
&
& -----------------------------------------------------------------
& I/O daemons
&
&  x io	starts coordinator, prta
&  x io1	starts coordinator, prta, puna
&
&label io
&label io1
sc_command r cord coordinator
pause 10
&label prta
sc_command r prta driver
sc_command r prta prta
sc_command r prta go
&if [equal &r1 io1] &then &goto punch
&quit
&
&label punch
&label puna
sc_command r puna driver
sc_command r puna puna
sc_command r puna go
&quit
&
&label punch_end
&label end_punch
sc_command r puna halt
sc_command r puna new_device
&quit
&
&label punch_restart
sc_command r puna puna
sc_command r puna go
&quit
&
&label read_cards
&label cards
&label rc
clean_card_pool -age 7
& delete all card input over 7 days old
sc_command login IO SysDaemon rdra
pause 10
sc_command r rdra driver
sc_command r rdra rdra
sc_command r rdra read_cards
&quit
&
&
&label reprint
&label rep
&
& exec_com to reprint a file for a user.
&
dprint -q 1 -he REPRINT -ds &r3 &r2
&quit
&
& -----------------------------------------------------------------
&  Commands to control automatic, attended, and unattended modes
&
&label auto
&  USAGE: x auto on OR x auto off
&
&if [nequal &n 2] &then &else &goto auto_error
&if [equal &r2 on] &then &else &goto not_auto_on
set_flagbox auto_reboot true
&quit
&label not_auto_on
&if [equal &r2 off] &then &else &goto auto_error
set_flagbox auto_reboot false
&quit
&
&label auto_error
&print --------->>> ERROR. USAGE: x auto on OR x auto off
&quit
&
&label attend
&label attended
reconfigure_rcp$add_device tape_(01 02 03 04 05 06 07 08)
sc_command word login
& flagbox 5 = "1"b means "unattended"
set_flagbox 5 false
&quit
&
&label unattend
&label unattended
reconfigure_rcp$del_device tape_(01 02 03 04 05 06 07 08)
sc_command word login Unattended service
set_flagbox 5 true
set_flagbox auto_reboot true
set_flagbox rebooted false
&quit
&
& -----------------------------------------------------------------
& Allow the operator to interrogate the state of the IO queues.
&
&label print_queues
&label pq
&
& exec_com to print total requests in the I/O Daemon queues
&
ldr -a -tt &rf2
&
&quit
&
& -----------------------------------------------------------------
& Incremental, Consolidated, and Complete Volume Dumps
&
&label incremental_volume
&label vinc
& usage: exec vinc ARG1 
& ARG1 = the operator's initials
&
&if [not [exists argument &r2]] &then &goto error
sc_command r vinc incremental_volume_dump -control sys_vols -operator &r2  -error_on -auto &rf3
&quit
&
&label consolidated_volume
&label vcons
&
& exec_com to allow the operators to easily run consolidated volume dumping.
&
& ARG1 = the operator's initials
&
&
&if [not [exists argument &r2]] &then &goto error
sc_command login Volume_Dumper Daemon vcons
pause 10
sc_command r vcons consolidated_volume_dump -control sys_vols -operator &r2 -error_on -auto -incr_skip_count 2 &rf3
&quit
&
&label vcomp
&label complete_volume
& usage: exec vcomp ARG1 
& ARG1 = the operator's initials
&
&if [not [exists argument &r2]] &then &goto error
sc_command login Volume_Dumper Daemon vcomp
pause 10
sc_command r vcomp complete_volume_dump -control sys_vols -operator &r2  -error_on -auto &rf3
&quit
&
&
& -----------------------------------------------------------------
& Incremental and Catchup Dumps
&
&label inc
& usage: exec inc ARG1 ARG2
& ARG1 = the operator's initials
& ARG2 = the first tape to be used
&
&if [not [exists argument &r3]] &then &goto error
sc_command r bk start_dump sys_dirs &r2 1 60
sc_command r bk &r3
&quit
&
&label cat
&
& exec_com to allow the operators to easily run catchup dumping.
&
& usage: exec cat ARG1 ARG2 -ARG3 ARG4-
&
& ARG1 = the operator's initials
& ARG2 = the first tape to be used
& ARG3 ARG4 (optional) = the date/time from which to start dumping (03/29/73 0800.0)
&
& example:  exec cat JW CAT21 03/29/73 0800.
&
&if [not [exists argument &r3]] &then &goto error
&if [exists argument &r4] &then sc_command r bk catchup_dump sys_dirs &r2 1 60  [string &r4 &r5]
&else sc_command r bk catchup_dump sys_dirs &r2 1 60
sc_command r bk &r3
&quit
&
& ------------------------------------------------------------
&
& hierarchy complete dumps
&
& USAGE: x comp INITIALS CONTROL_FILE TAPE_REEL
& 
&label complete
&label comp
&
value_set -pp exec.cd_retry_count 0
&if [exists argument &r4] &then &goto .complete_args_ok
&print x complete: USAGE: x comp INITIALS CONTROL_FILE TAPE_REEL
&                                &2       &3           &4
&goto error
&label .complete_args_ok
&if [exists argument [as_who Dumper.SysDaemon -daemon -channel cd]] &then &goto .complete_logged_in
&label .retry_complete_login
&if [nless [value_get -pp exec.cd_retry_count] 3] &then &goto .complete_login
&print x complete: failed 3 tries to login Dumper.SysDaemon cd. 
&goto error
&label .complete_login
value_set -pp exec.cd_retry_count -add 1
sc_command login Dumper.SysDaemon cd
pause 5
&goto .complete_args_ok
&label .complete_logged_in
sc_command r cd complete_dump -control &r3 -operator &r2
sc_command r cd &r4
&quit
&
& ------------------------------------------------------------
&
& WAKEUP_DUMP will wakeup the volume or hierarchy incremental
&
& USAGE: x wakeup_dump MC_SOURCE
&
&label wakeup_dump
&if [exists argument &r2] &then &goto .wakeup_args_ok
&print x wakeup_dump: USAGE: x wakeup_dump vinc|bk
&goto error
&label .wakeup_args_ok
&if [not [equal &r2 bk]] &then &goto .wakeup_not_bk
&if [not [exists argument [as_who -channel bk -daemon]]] &then &goto .wakeup_no_daemon
sc_command r bk wakeup_dump
&quit
&label .wakeup_not_bk
&if [not [equal &r2 vinc]] &then &goto .wakeup_not_vinc
&if [not [exists argument [as_who -channel vinc -daemon]]] &then &goto .wakeup_no_daemon
sc_command r vinc wakeup_volume_dump
&quit
&label .wakeup_not_vinc
&print x wakeup_dump: argument must be vinc or bk, not &r2.
&goto error
&label .wakeup_no_daemon
&print x wakeup_dump: No daemon logged in on source &rf2.
&goto error
& ------------------------------------------------------------
&
& END_DUMP will end the volume or hierarchy incremental
&
& USAGE: x end_dump MC_SOURCE
&
&label end_dump
&if [exists argument &r2] &then &goto .end_args_ok
&print x end_dump: USAGE: x end_dump vinc|bk
&goto error
&label .end_args_ok
&if [not [equal &r2 bk]] &then &goto .end_not_bk
&if [not [exists argument [as_who -channel bk -daemon]]] &then &goto .end_no_daemon
sc_command r bk end_dump
&quit
&label .end_not_bk
&if [not [equal &r2 vinc]] &then &goto .end_not_vinc
&if [not [exists argument [as_who -channel vinc -daemon]]] &then &goto .end_no_daemon
sc_command r vinc end_volume_dump
&quit
&label .end_not_vinc
&print x end_dump: argument must be vinc or bk, not &r2.
&goto error
&label .end_no_daemon
&print x end_dump: No daemon logged in on source &r2.
&goto error
&
& -----------------------------------------------------------------
& Things related to FDUMP processing.
&
&label copy_dump
&
& This exec is used to copy an FDUMP from the dump
& partition into the Multics hierarchy (in >dumps).
& This operation is not needed usually since system_start_up.ec does it.
&
copy_dump
&quit
&
&label set_fdump_number
&label set_fdump
&label sfdn
&
& This exec is used to set the ERF number of the next
& FDUMP to be taken to a specified value.
&
copy_dump$set_fdump_number &r2
&quit
& 
&label delete_dump
&label dd
&
& exec_com to delete a dump
&
&if [exists argument &r2] &then &else &print delete_dump: missing dump_number
&if [exists argument &r2] &then &else &quit
deleteforce >dumps>*.*.*.&r2.**
&quit
&
&
&
& -----------------------------------------------------------------
& Sometimes the tabs on the TN300 get destroyed by an operator
& who types without waiting for the OPER: message.
& This will put the tabs back.
&
&label reset_tabs
&label tabs
&label rt
&
&command_line off
set_tty -terminal_type TN300 -tabs
&quit
&
& -----------------------------------------------------------------
&
&label echoplex
&
& Exec_com to allow operator to switch terminal into full (echoplex) duplex mode.
&
& Usage: x echoplex  (to set the terminal to echoplex mode)
&        x echoplex ^ (to turn off echoplex mode)
&
&
set_tty -modes &r2echoplex
&quit
&
& -----------------------------------------------------------------
& exec_coms to set and reset access on phcs_
&
&label set_phcs_access
&label spa
hpsa >system_library_1>phcs_ re &r2
&quit
&
&label reset_phcs_access
&label rpa
hpda >system_library_1>phcs_ &r2
&quit
&
& -----------------------------------------------------------------
& exec_com to setup the system in preparation for a metering run.
&
&
&label meter
&
sc_command quit nw
sc_command quit ns
sc_command logout IO * *
sc_command r bk logout
sc_command r mt setup
pause 10
& Give time for Network_Daemon and Network_Server to receive the quits
sc_command r nw logout
sc_command r ns logout
sc_command abs start 40 1
&print ********* Make sure all Daemons (except Metering) are logged out and then "r mt run" **********
&quit
&
& ==========================================================================================
&
&         ec to perform salvaging/quota validation
&	B. Greenberg 9/13/76
&
& Usage:  ec admin repair salv      dirname nprocs salvargs   for dir salvage
& Usage:  ec admin repair quota     dirname nprocs            for quota-used correction
& Usage:  ec admin repair salvquota dirname nprocs salvargs   for both.
& Usage:  ec admin repair stop			  kill multiprocessing.
&	         &1     &2        &3      &4     &5
&
&

&label repair
&command_line off
&if [equal &r2 stop] &then &goto repair.stop
&if [or [exists argument &r5] [not [exists argument &r4]]] &then &goto repair.explsalvctl
ec &ec_dir>&ec_name &rf1 -compact
&quit
&label repair.explsalvctl
&if [nless &n 4] &then &goto repair.usage
&if [nequal [verify &r4 0123456789] 0] &then &else &goto repair.badnprocs
&if [nequal &r4 0] &then &goto repair.badnprocs
&if [nless &r4 37] &then &goto repair.nprocsok
&label repair.badnprocs
&print admin.ec Number of processes (&4) is not number from 1 to 36.
&goto repair.usage
&
&label repair.nprocsok
&
&if [equal &r2 salv] &then &goto repair.1
&if [equal &r2 quota] &then &goto repair.1
&if [equal &r2 salvquota] &then &goto repair.1
&print admin.ec: invalid argument &r2 given to x repair
&label repair.usage
&print Usage: x repair salv/quota/salvquota dirname nprocs
&print Or: x repair stop, to log out processes
&quit
&label repair.1
&if [equal &r2 salv]
&then ec &ec_dir>&ec_name repair.2  "salvage_dir &r(1) &r(2).salvout &rf5" ""  &r3 &r4
&if [equal &r2 quota]
&then ec &ec_dir>&ec_name repair.2 "" "fix_quota_used &r(1)" &r3 &r4
&if [equal &r2 salvquota]
&then ec &ec_dir>&ec_name repair.2 "salvage_dir &r(1) &r(2).salvout &rf5" "fix_quota_used &r(1)" &r3 &r4
&quit
&label repair.2
&command_line off
&
&         This is an internal interface used by x repair.
&
& Usage:  ec admin repair.2 topdown_comline bottomup_comline dirname nprocs
&                  &1       &2              &3               &4      &5
&
&
&if [equal &r4 >] &then &goto repair.3
&  exists af doesnt like >.
&if [exists directory &r4] &then &goto repair.3
&print admin.ec: &r4 is not a directory.
&quit

&label repair.3
dl >user_dir_dir>SysDaemon>Salvager>dos_mp_seg -brief
sc_command login Salvager SysDaemon s0 
&if [nequal &r5 1] &then &else sc_command login Salvager SysDaemon s([index_set [minus &r5 1]])
pause 10
& It is illegal for both the top-down and bottom-up command lines to be null.
& If top-down command line is null, do the bottom-up command line.
&if [equal "" &r2]
&then sc_command reply s0 do_subtree """&q4""" -bu """&q3""" -priv -mp
& If bottom-up command line is null, do the top-down command line.
&if [equal "" &r3]
&then sc_command reply s0 do_subtree """&q4""" -td """&q2""" -priv -mp
& If neither is null, do both top-down and bottom-up command lines.
&if [and [not ([equal "" (&r2 &r3)])]]
&then sc_command reply s0 do_subtree """&q4""" -td """&q2""" -bu """&q3""" -priv -mp
& In the three command lines above, the arguments to do_subtree must be
& doubly-quoted to insure that the command lines are seen by do_subtree as
& a single argument, and to prevent the operator from including random
& command fragments in the directory pathname.  Double quotes are required
& because the command_processor_ removes one level of quotes when processing
& the sc_command.  Thus, do_subtree only sees one level of quoting.
& Note that processing of the reply request does NOT remove a level of quotes.
&
&quit
&label repair.stop
sc_command login Salvager SysDaemon s99
&quit
& ================================================================================================
&
&        ec to deny device to a process
&
&label deny
&command_line off
&
& Usage:   x deny <devname>
&
&if [exists argument &r2] &then ur &r2 -am
&else &print admin.ec: no device name given to x deny.
&quit
&
& ==========================================================================================
&
&	ec to authenticate a tape or disk device
&
&label auth
&command_line off
&if [exists argument &r3] &then authenticate_device &rf2
&else &print admin.ec: Usage: x auth devname AUTH
&quit
& =========================================================================================
&
&	ec to give response via the opr_query_response facility
&
&label oqr
&command_line off
&if [exists argument &r2] &then opr_query_response &rf2
&else &print admin.ec: Usage: x oqr response
&quit
& =========================================================================================
&
&
& ===========================================================================================
&   
&   x scav {scavenge_vol args}
&
& ===========================================================================================

&label scav
&command_line off
ec &ec_dir>admin_1 &rf1
&quit
& =========================================================================================
&
& Come here if there is a missing argument.
&
&label error
&print --------->>>> ERROR in &1. Missing argument. <<<<<--------
&quit

& *****************************************************************************
& 
& END OF ADMINISTRATIVE EXEC COM
& The following will catch any call not included above.
&
& This will invoke admin_dsa.ec for all "x FUNCTIONS ..." not found above
& in this exec_com.  It will complain if it doesn't implement the requested
& FUNCTION.  If DSA is not installed, then complain here.
&
&label &1
&if [exists segment >site>dsa>ecs>admin_dsa.ec]
&then exec_com >site>dsa>ecs>admin_dsa &rf1
&else &goto admin.bad_exec_arg
&quit
&
&label admin.bad_exec_arg
&print Invalid argument "&1" given to "exec".
&quit
