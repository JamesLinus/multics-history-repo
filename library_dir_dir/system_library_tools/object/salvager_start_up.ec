&  ***********************************************************
&  *                                                         *
&  * Copyright, (C) Honeywell Information Systems Inc., 1982 *
&  *                                                         *
&  ***********************************************************
&
&	start_up.ec for Salvager.SysDaemon
&	B. Greenberg 9/13/77
&
do -absentee
&goto &1
&label login
&if [equal [user device_channel] s99] &then &goto mpabort
&command_line off
delete [user device_channel].fileout -brief
rdf
&if [equal [user device_channel] s0] &then date_deleter -wd 14 salv_output.* salv_online.*
io attach user_fileout vfile_ [user device_channel].fileout
io open user_fileout stream_output
iocall attach broadcast broadcast_ user_fileout
iocall attach broadcast broadcast_ user_i/o
syn_output user_fileout -ssw error_output
syn_output broadcast
&if [equal [user device_channel] s0] &then [io get_line user_input -nq]
&else do_subtree -slave
&
ro;ro -ssw error_output
io close user_fileout
io detach user_fileout
&if [equal [user device_channel] s0] &then &else logout
&
&	Collate the output
&
adjust_bit_count ([segs *.salvout] [segs *.fileout]) -ch
io attach salv_output vfile_ salv_output.[date].[time];io open salv_output so
io put_chars salv_output -sm ([segs *.salvout])
io close salv_output
io attach online_output vfile_ online_salvout.[date].[time];io open online_output so
io put_chars online_output -sm ([segs *.fileout])
io close online_output

ec &ec_dir>&ec_name sortout [io attach_desc online_output -nq]
do "dprint -he ""SALV OUTPUT"" &(2)" [io attach_desc salv_output -nq]
do "dprint -he ""SALV ONLINE"" &(2)" [io attach_desc online_output -nq]
io detach online_output;io detach salv_output
delete *.salvout *.fileout -brief
logout

&label mpabort
&command_line off
do_subtree$abort
logout
&label new_proc
&quit          & leave ec on new proc
&
&     Recursive entry to sort cumulated salv output, if not
&     msf. Called with spread attach description, as in..
&     ec start_up sortout vfile_ salv_output.09/14/77.12:53
&                 &1      &2     &3
&
&label sortout
&if [exists segment &3] &then &else &quit
&if [nequal [status &3 -bit_count] 0] &then &quit
&command_line off
&input_line off
&attach
qedx
r&3
1,$s/^$//
$a

\f
w
q
&detach
dco -osw error_output sort_seg &3 -dm "" -replace
&quit
