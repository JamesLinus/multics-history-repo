&version 2
&- ***********************************************************
&- *                                                         *
&- * Copyright, (C) Honeywell Information Systems Inc., 1984 *
&- *                                                         *
&- * Copyright (c) 1972 by Massachusetts Institute of        *
&- * Technology and Honeywell Information Systems, Inc.      *
&- *                                                         *
&- ***********************************************************
&-
&-  Modification history:
&-  Modified 1984-12-11 BIM for new value segments.
&-
&- Multics billing operations
&- ------------------------------
&-
&trace &command off
&trace &input off
&goto &1
&-
&label prepare
&trace &command on
&-
&- Usage: ec biller prepare access-name-to-run-bills
&default &"" &[user name].&[user project].a
print billing_footnote
&print $$$ if file not up to date, edit it
st -dt disk_stat
&print $$$ if disk report not current, 'ec master drp'
&-
&print Checking access to segments and directories for &2
ec util check_access >sc1>sat rw &2
ec util check_access >sc1>pdt sma &2
ec util check_access ([segs >sc1>pdt>*.pdt -absp]) rw &2
&-
&print $$$ arguments for bill run are mm dd yy bxxxxx
&quit
&-
&- ---------------------------
&-
&label run
&-
&- If this installation requires card output from billing runs, then
&- the following line should be commented out:
&if &[exists argument &4] &then &goto cards_not_required
&if &[not [exists argument &5]] &then exec_com err noarg
&if &[not [or [equal [substr &5 1 1] "B"] [equal [substr &5 1 1] "b"]]]
&then exec_com err badarg &5 not voucher
&label cards_not_required
&print $ now doing billing for &2/&3/&4 (&5)
value_set -pn sys_admin abort_crank true
&print $ crank will abort now until "bill accept" has run
sort_reqfile
sort_projfile
compute_bill safe_pdts>sat safe_pdts
daily_summary -nosum -nocutr
&- above commands make sure got all charges if diskreport ran after crank.
exec_com util del (mailing_copy long_bill short_bill bill msum cards miscs.print)
iocall attach sumry file_ msum w
write_billing_summary &2 &4
iocall detach sumry
&if &[not [exists argument &5]] &then &goto no_cards
iocall attach cards file_ cards w
punch_MIT_deck &2 &3 &4 &5
iocall detach cards
&print $ now dprinting cards and sumry
setacl cards r IO.SysDaemon
&if &[exists file cards]
&then dpn1 -ds "***SPECIAL***" -he [value_get -pn sys_admin accts0_addr] -mcc cards
&label no_cards
exec_com util dp (msum cards) accts0 1
exec_com util dp (msum cards) default 1
iocall attach acct_bill file_ bill w
iocall attach mailing_copy file_ mailing_copy w
iocall attach bill broadcast_ acct_bill w
iocall attach bill broadcast_ mailing_copy w
write_acct_bill &2 &4
iocall detach bill
iocall detach acct_bill
exec_com util dp bill accts0 1
exec_com util dp bill default 1
iocall attach long file_ long_bill w
iocall attach long_bill broadcast_ long w
iocall attach long_bill broadcast_ mailing_copy w
iocall attach short_bill file_ short_bill w
iocall attach both_bills broadcast_ long_bill w
iocall attach both_bills broadcast_ short_bill w
write_user_usage_report safe_pdts>sat safe_pdts reqfile projfile miscfile
iocall detach (both_bills long_bill short_bill mailing_copy long)
file_output miscs.print
 misc$print_all_miscs
revert_output
&print $ now dprinting long bill
exec_com util dp long_bill accts0 1
exec_com util dp long_bill default 1
&-
exec_com util del system_month.report
file_output system_month.report; system_monthly_report today.use_totals last_month.use_totals; revert_output
exec_com util dp system_month.report admin0 2
exec_com util dp system_month.report default 1
&-
&quit
&-
&- ------------------------
&-
&label accept
&-
&if &[not [exists argument &2]] &then exec_com err noarg
copy projfile HF>&2.projfile -brief
copy reqfile HF>&2.reqfile -brief
copy miscfile HF>&2.miscfile -brief
copy today.use_totals HF>&2.use_totals
exec_com util del last_month.use_totals
copy today.use_totals last_month.use_totals
usage_total safe_pdts>sat safe_pdts projfile last_month.use_totals
reset_use_totals today.use_totals daily_report.control
&-
up_ctr
clear_reqfile
clear_projfile
clear_sat smf.cur.sat
reset_usage >system_control_dir>sat >system_control_dir>pdt safe_pdts>sat safe_pdts
misc$reset_misc
&- truncate instead of deleting and creating, to preserve the acl
truncate miscfile
reset_disk_meters
value_set -pn sys_admin abort_crank false
&print $ crank is now free to run
&-
&- Comment this back in when console_report and sys_full_report are ready.
&- exec_com util del system_full.list
&- file_output system_full.list
&- sys_full_report -print
&- revert_output
&- delete sys_full_report_seg

&- exec_com util del console.list
&- console_report -sort
&- file_output console.list
&- console_report -print
&- revert_output
&- console_report -clear
exec_com util dp (console.list system_full.list) admin0 2
exec_com util dp (console.list system_full.list) default 1
&-
&label rqbill
&if &[exists file cards]
&then dpn2 -bf -he [value_get -pn sys_admin accts0_addr] -ds [value_get -pn sys_admin accts0_dest] -mcc cards 
exec_com util dp (mailing_copy bill long_bill msum bill cards diskreport miscs.print) accts0
exec_com util dp system_month.report assurance1
&- exec_com util dp system_month.report director2
exec_com util dp system_month.report director3
exec_com util dp system_month.report director4
exec_com util dp system_month.report director5
exec_com util dp system_month.report director6
exec_com util dp (system_month.report short_bill diskreport bill msum cards miscs.print) director7
&- exec_com util dp (system_month.report short_bill diskreport long_bill msum bill cards miscs.print) admin0
&- exec_com util dp (system_month.report short_bill diskreport long_bill msum bill cards miscs.print) admin1
exec_com util dp system_month.report sysprg0
exec_com util dp system_month.report sysprg1
exec_com util dp system_month.report sysprg2
exec_com util dp (mailing_copy miscs.print short_bill) default 1
&quit
&-
&- ----------------------
&-
&label delete
exec_com util del (mailing_copy long_bill short_bill bill msum cards miscs.print)
&quit
&-
&- -------------------------
&-
&label &1
exec_com err illegal_arg &1
&quit
&- ----
