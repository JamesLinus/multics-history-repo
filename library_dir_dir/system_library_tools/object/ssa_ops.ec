&
& EXEC_COM TO ASSIST THE SYSTEM ADMINISTRATOR AND SYSTEM SECURITY
& ADMINISTRATOR IN ASSIGNING AND CHANGING AUTHORIZATIONS AND AUDIT FLAGS.
&
& Written 750605 by PG
&
&command_line off
&goto &1

&label change_proj_auth
admin_util lock
set_sat_auth &2 "&3"
&goto check_for_install_sat

&label change_pers_auth
admin_util lock
set_pnt_auth &2 "&3"
&goto check_for_install_pnt

&label change_proj_audit
admin_util lock
set_sat_audit &2 "&3"
&goto check_for_install_sat

&label change_pers_audit
admin_util lock
set_pnt_audit &2 "&3"
&goto check_for_install_pnt

&label change_gpw
admin_util lock
set_pnt_gpw &2 &3
&goto check_for_install_pnt

&
& Routines above this point transfer here to ask if the table should be
& installed.
&

&label check_for_install_pnt
&if [equal [query Install?] true] &then install PNT.pnt -auth
admin_util unlock
&quit

&label check_for_install_sat
&if [equal [query Install?] true] &then install smf.cur.sat -auth
admin_util unlock
&quit

&
& These routines require no interlocking, nor installing.
&

&label change_term_class
set_term_class &2 "&3"
&quit

&label change_term_id
set_term_id &2 "&3"
&quit

&label change_term_audit
set_term_audit &2 &3
&quit

&
& This section prints authorizations and audit flags.
&

&label print_pers_auth
&label print_pers_audit
print_pnt >system_control_1>pnt &2
&quit

&label print_proj_auth
&label print_proj_audit
print_sat >system_control_1>sat &2
&quit

&label print_term_class
&label print_term_id
&label print_term_audit
print_term_info &2
&quit

&label &1
&print ERROR: Unknown action "&1". Legal commands are:
&print exec_com ssa_ops change_proj_auth PROJ AUTH
&print exec_com ssa_ops change_pers_auth PERSON AUTH
&print exec_com ssa_ops change_proj_audit PROJ AUDIT
&print exec_com ssa_ops change_pers_audit PERSON AUDIT
&print exec_com ssa_ops change_gpw PERSON on|off
&print exec_com ssa_ops change_term_class TERMINAL ACCESS_CLASS
&print exec_com ssa_ops change_term_id TERMINAL ID
&print exec_com ssa_ops change_term_audit TERMINAL on|off
&print exec_com ssa_ops print_pers_auth PERSON
&print exec_com ssa_ops print_proj_auth PROJECT
&print exec_com ssa_ops print_pers_audit PERSON
&print exec_com ssa_ops print_proj_audit PROJECT
&print exec_com ssa_ops print_term_class TERMINAL
&print exec_com ssa_ops print_term_id TERMINAL
&print exec_com ssa_ops print_term_audit TERMINAL
&quit
