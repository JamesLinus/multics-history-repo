&  ***********************************************************
&  *                                                         *
&  * Copyright, (C) Honeywell Information Systems Inc., 1982 *
&  *                                                         *
&  ***********************************************************

& 
& 
&  HISTORY COMMENTS:
&   1) change(86-12-18,Fawcett), approve(86-12-18,PBF7517),
&      audit(86-12-18,GDixon), install(87-01-05,MR12.0-1257):
&      Delete cross reference for BOS.
&                                                       END HISTORY COMMENTS
& 
& 
&goto &ec_name

&	RUNNING A LIBRARY CROSSREFERENCE
& The following exec-com creates an input list for the Multics crossreferencer
& to use in running a crossreference of the system libraries.  The
& crossreference output identifies all those segments which call a given
& segment.  It is useful for checking and integrating system changes, and for
& identifying obsolete segments.

&label crossref
&if [not [exists argument &1]] &then &goto XREF_USAGE

& arguments: one of the following
& hard | sss | tools   |  unbundled  | online | total

& If the "total" arguement is used, total libraries will be 
& crossreferenced together, and a common list produced.
& This is the standard way for library checking.

&attach
&command_line off

&	produces driver file.
exec_com &ec_dir>create_crossref_crl &1

&    if error trying to create driving file, stop here
&if [not [exists segment &1.crl]] &then &quit

cross_reference -include_files -input_file  &1.crl

delete &1.crl -bf
&quit

& This enter will build a driver file for the cross_reference command.
&label create_crossref_crl
&command_line off
delete &1.crl -bf
&goto crl_&1

&label crl_tools
&label crl_unbundled
exec_com &ec_dir>create_crlsub &1 [translate &1 ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz] &1
&goto crl_dl_garbage

&label crl_sss
&label crl_standard
exec_com &ec_dir>create_crlsub standard STANDARD &1
&goto crl_dl_garbage


&label crl_hard
exec_com &ec_dir>create_crlsub hard HARDCORE hard "" -ex bound_*
exec_com &ec_dir>create_crlsub hard HARDCORE hard >library_dir_dir>hard>object -ex bound_*
&goto crl_dl_garbage


&label crl_honeywell
&label crl_total
&label online
&label site_online

exec_com &ec_dir>create_crlsub hard HARDCORE &1 >library_dir_dir>hard>object -ex bound_*
exec_com &ec_dir>create_crlsub standard STANDARD &1
exec_com &ec_dir>create_crlsub unbundled UNBUNDLED &1
exec_com &ec_dir>create_crlsub tools TOOLS &1
&goto crl_dl_garbage

&label crl_&1
&print &ec_name: Can't crossref &1; choices are:
&print           sss, tools, unbundled, online or total.
&quit

&label crl_dl_garbage
&attach
&input_line off
qx
r &1.crl
gd/\c.1$/
gd/\c.2$/
gd/\c.3$/
gd/\c.4$/
gd/\c.absin$/
gd/\c.teco$/
gd/\c.control$/
gd/\c.compin$/
gd/\c.ec$/
gd/\c.mrpg$/
gd/\c.ascii$/
gd/RTMF$/
gd/\c.cmf$/
gd/\c.ttf$/
gd/\c.pnotice$/
gd/\c.dcl$/
gd/ring_zero_meter_limits_ASCII_/
gd/lss_command_list_/
gd/\c.lisp/
gd/\c.dict/
gd/psp_info_/
gd/gm_path_list/
gd/^!..............$/
gd/GTSS.MCFC/
w
q
&detach
sa *.crl r *
&quit


&label create_crlsub
&command_line off
fo &3.crl
&if [equal &1 hard] &then &print -library -all:
&else &print -library:
&if [equal &4x x]
&then &print >library_dir_dir>&1>object &2;
&else &print &4 &2;
&if [equal &4x x]
&then list -p >library_dir_dir>&1>object -bf -sort -nhe -pri &5 &6
&else list -p &4 -bf -sort -nhe -pri &5 &6
&print
ro
set_acl  &3.crl r *
&quit

&label XREF_USAGE
&
& &print Expected argument missing.
&print Argument must be library name.
&
&quit
