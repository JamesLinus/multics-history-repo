&
&       dir_salvage.ec
&       simple treewalk salvager coordinator
&       B. Greenberg 9/14/77
&
& Usage: ec dir_salvage dirname -salvctlargs
&       dirname optional defaults to root.
&       salvctlargs optional too.
&
&
&command_line off
&if [equal [substr &1. 1 1] >] &then &goto gotdir
ec &ec_dir>&ec_name > &rf1
&quit

&label gotdir
date_deleter -wd 14 salv_output.*.*
delete salvager_out -brief
do_subtree &1 -td "salvage_dir &(1) salvager_out &rf2" -priv
&if [exists segment salvager_out] &then &else &quit
do "rename salvager_out &(1);dprint -he SALV-OUTPUT &(1)" salv_output.[date].[time]
&quit
