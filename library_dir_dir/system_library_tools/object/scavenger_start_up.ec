&version 2
&------------------------------------------------------------------------------
&-
&-	Scavenger.SysDaemon start_up.ec
&-
&-	Executes scavenge_vol with arguments passed in as login args,
&-	then logs out.
&-
&------------------------------------------------------------------------------
&trace &all off
&if [nequal [login_args -count] 0] &then scavenge_vol -all -auto -nopt
&else scavenge_vol [login_args -from 1 -requote]
logout

&quit
