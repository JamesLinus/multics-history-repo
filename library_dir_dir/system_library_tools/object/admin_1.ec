&version 2
&trace &all off
&goto &1
&-  ******************************************************
&-  *                                                    *
&-  *                                                    *
&-  * Copyright (c) 1972 by Massachusetts Institute of   *
&-  * Technology and Honeywell Information Systems, Inc. *
&-  *                                                    *
&-  *                                                    *
&-  ******************************************************
&-
&- ADMIN_1.EC - extended operator commands. An extension of admin.ec,
&-              written in version 2 exec_com. It is called from admin.ec
&-	        and invoked with the same arguments.
&-
&------------------------------------------------------------------------------
&-
&-	x scav {scavenge_vol args}
&-
&------------------------------------------------------------------------------
&label scav
&if &[nequal &n 1] &then scavenge_vol
&else scavenge_vol &rf2 -check
&if &[not [nequal [severity scavenge_vol] 0]] &then &quit

&set scav_chan &[before [string [do "[if [equal [string [as_who -chn &&1]] """"] -then &&1 -else """"]" scav([index_set 1 10]) ]] " "]
&if [not [equal &(scav_chan) ""]] &then &goto scav_01
&print No login channel available
&quit

&label scav_01
sc_command login Scavenger SysDaemon &(scav_chan) -ag &rf2
&quit
