&command_line off
&goto &ec_name
&label meter
abs_control &2
&if [equal [index "&2" " "] 0] &then &goto onearg
ec meter2 &1 &3 ([index_set [substr "&2" 1 [minus [index "&2" " "] 1]]]) "&4"
&quit
&label onearg
ec meter2 &1 &3 ([index_set &2]) "&4"
&quit
&label meter2
&if [equal [substr &1 [index &1 .] 3] .ec] &then &goto ectype
ear &1 -q &2 -of &1.&3.absout -ag &4
&quit
&label ectype
ear meter3 -q &2 -of &1.&3.absout -ag &1 "&4"
&quit
&label meter3
acceptance_test$init
ec &1 &2
acceptance_test$terminate
logout
&quit
&label reset_meters
fo trash;(tcm fsm ttm pmlm) -all -rs;dvm -rs;co;dl trash
&quit
&label print_meters
fsm -all;tcm -all;ttm -all;pmlm -all;dvm
