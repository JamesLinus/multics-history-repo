&version 2
&ready_proc off
&-
&-  ***********************************************************
&-  *                                                         *
&-  * Copyright, (C) Honeywell Information Systems Inc., 1982 *
&-  *                                                         *
&-  ***********************************************************
&-
&- Compare two PL/I programs ignoring most formatting.  First remove all
&- format_pl1 control comments from both programs.  Secondly, format_pl1 both
&- programs into a canonical style.  Finally, use compare_ascii to see how they
&- differ.  The line numbers in the compare_ascii output will not be accurate.
&- Vertical white space inserted or deleted between statements isn't ignored.
&-
&- Written 3 September 1980 by M. N. Davidoff.
&- Modified 16 March 1981 by M. N. Davidoff for format_pl1 version 6.0.
&- Modified 28 April 1981 by M. N. Davidoff to delete temporary segments.
&- Modified 1 May 1981 by M. N. Davidoff to format using indcomtxt mode.
&- Modified 22 May 1981 by M. N. Davidoff to not initiate >exl>o>format_pl1.
&- Modified May 1982 by B. Braun to use shriek names in the [pd] for seg names,
&- to support archive component names, to not use >exl>exec_coms, to add a cleanup handler
&- Modified September 1983 by E. N. Kittlitz for ready_proc off, 0j in teco.
&-
&trace &command off
&goto &ec_name
&-
&label compare_pl1
&label cpp
on cleanup  "exec_com &ec_dir>cpp_cleanup_" -bf exec_com  &ec_dir>&ec_name_ &rf1
&quit
&-
&label compare_pl1_
&label cpp_
&-
&if &[value_defined cpp.ec.already_invoked -perprocess]
&then &goto check_value &else &goto set_value
&-
&label check_value
&if &[value_get cpp.ec.already_invoked -perprocess] &then &goto already_invoked
&-
&label set_value
value_set cpp.ec.already_invoked true -perprocess
&-
&label cpp_check_usage
&-
&if &[nless &n 2] &then &do
   &print compare_pl1.ec: Wrong number of arguments.
   &print Usage: ec cpp path1 path2
   &goto cpp_cleanup_
&end
&-
&if &[ngreater [search &1 *?] 0] &then &do
   &print compare_pl1.ec: Star convention is not allowed. &1
   &goto cpp_cleanup_
&end
&if &[ngreater [search &2 *?] 0] &then &do
   &print compare_pl1.ec: Star convention is not allowed. &2
   &goto cpp_cleanup_
&end
&goto compare_pl1_usage_ok
&-
&label do_continue
&print compare_pl1.ec: The previous cpp invocation cannot be restarted.
value_set cpp.ec.already_invoked false -perprocess
&goto cpp_check_usage
&-
&label already_invoked
&if &[query "A previous invocation of cpp is in effect. This will be overridden if you continue. Do you wish to continue?"]
&then &goto do_continue &else &goto do_not_continue
&-
&label do_not_continue
value_set cpp.ec.already_invoked true -perprocess
&print compare_pl1.ec: Current invocation aborted. Previous cpp can be restarted.
&quit
&-
&label compare_pl1_usage_ok
&-
value_set cpp.ec.expanded_path1 [path [strip &1 pl1].pl1] -perprocess
value_set cpp.ec.seg_path1 [entry_path [path [strip &1 pl1].pl1]] -perprocess
&-
&if &[exists segment [value_get cpp.ec.seg_path1 -perprocess] -chase] &then &do
   &if &[ngreater [index [status [value_get cpp.ec.seg_path1 -perprocess] -mode -chase] "r"] 0] &then &do
      &if &[ngreater [index [status [directory &1] -directory -mode -chase] "s"] 0] &then &do
         &if &[is_component_pathname &1] &then &do
            &if &[exists component [strip &1 pl1].pl1 -chase] &then &do
               answer yes -bf archive x [entry_path &1] [process_dir]>[strip_component &1 pl1].pl1
	     value_set cpp.ec.component1 [process_dir]>[unique].component1.pl1 -perprocess
	     rename [process_dir]>[strip_component &1 pl1].pl1 [entry [value_get cpp.ec.component1 -perprocess]]
            &end
            &else &do
               &print compare_pl1.ec: Archive component not found. &[strip &1 pl1].pl1
	     &goto cpp_cleanup_
	     &end
         &end
         &else &do &end
      &end
      &else &do
         &print compare_pl1.ec: Status permission missing on directory. &[strip &1 pl1].pl1
         &goto cpp_cleanup_
      &end
   &end
   &else &do
      &print compare_pl1.ec: Incorrect access on entry. &[value_get cpp.ec.seg_path1 -perprocess]
      &goto cpp_cleanup_
   &end
&end
&else &do
   &print compare_pl1.ec: Segment not found. &[value_get cpp.ec.seg_path1 -perprocess]
   &goto cpp_cleanup_
&end
&-
value_set cpp.ec.expanded_path2 [path [strip [equal_name &1 &2] pl1].pl1] -perprocess
value_set cpp.ec.seg_path2 [entry_path [path [strip [equal_name &1 &2] pl1].pl1]] -perprocess
&-
&if &[exists segment [value_get cpp.ec.seg_path2 -perprocess] -chase] &then &do
   &if &[ngreater [index [status [value_get cpp.ec.seg_path2 -perprocess] -mode -chase] "r"] 0] &then &do
      &if &[ngreater [index [status [directory &2] -directory -mode -chase] "s"] 0] &then &do
         &if &[is_component_pathname &2] &then &do
            &if &[exists component [value_get cpp.ec.expanded_path2 -perprocess] -chase] &then &do
               answer yes -bf archive x [value_get cpp.ec.seg_path2 -perprocess] [process_dir]>[strip_component [value_get cpp.ec.expanded_path2] pl1].pl1
	     value_set cpp.ec.component2 [process_dir]>[unique].component2.pl1 -perprocess
	     rename [process_dir]>[strip_component [value_get cpp.ec.expanded_path2] pl1].pl1 [entry [value_get cpp.ec.component2 -perprocess]]
            &end
            &else &do
               &print compare_pl1.ec: Archive component not found. &[strip [equal_name &1 &2] pl1].pl1
	     &goto cpp_cleanup_
	  &end
         &end
         &else &do &end
      &end
      &else &do
         &print compare_pl1.ec: Status permission missing on directory. &[value_get cpp.ec.expanded_path2 -perprocess]
         &goto cpp_cleanup_
      &end
   &end
   &else &do
      &print compare_pl1.ec: Incorrect access on entry. &[value_get cpp.ec.seg_path1 -perprocess]
      &goto cpp_cleanup_
   &end
&end
&else &do
   &print compare_pl1.ec: Segment not found. &[value_get cpp.ec.seg_path2 -perprocess]
   &goto cpp_cleanup_
&end
&-
value_set cpp.ec.path1 [process_dir]>[unique].1.pl1 -perprocess
value_set cpp.ec.path2 [process_dir]>[unique].2.pl1 -perprocess
&-
&if &[is_component_pathname &1]
&then exec_com &ec_dir>cpp_dl_ctl_comments_ [value_get cpp.ec.component1 -perprocess] [value_get cpp.ec.path1 -perprocess]
&else exec_com &ec_dir>cpp_dl_ctl_comments_ [strip &1 pl1].pl1  [value_get cpp.ec.path1 -perprocess]
&-
&if &[is_component_pathname &2]
&then exec_com &ec_dir>cpp_dl_ctl_comments_ [value_get cpp.ec.component2 -perprocess] [value_get cpp.ec.path2 -perprocess]
&else exec_com &ec_dir>cpp_dl_ctl_comments_ [strip [equal_name [component &1] &2] pl1].pl1 [value_get cpp.ec.path2 -perprocess]
&-
format_pl1 [value_get cpp.ec.path1 -perprocess] -output_file [process_dir]>== -modes style3,^indattr,ifthenstmt,ifthendo,ifthen,indcomtxt,ind0,initcol1,declareind8,dclind4
&-
format_pl1 [value_get cpp.ec.path2 -perprocess] -output_file [process_dir]>== -modes style3,^indattr,ifthenstmt,ifthendo,ifthen,indcomtxt,ind0,initcol1,declareind8,dclind4
&-
compare_ascii [value_get cpp.ec.path1 -perprocess] [value_get cpp.ec.path2 -perprocess] 
&-
&label cpp_cleanup_
&-
&if &[value_defined cpp.ec.path1 -perprocess]
&then delete [value_get cpp.ec.path1  -perprocess] -bf;value_delete cpp.ec.path1 -perprocess
&-
&if &[value_defined cpp.ec.path2 -perprocess]
&then delete [value_get cpp.ec.path2  -perprocess] -bf;value_delete cpp.ec.path2 -perprocess
&-
&if &[value_defined cpp.ec.expanded_path1 -perprocess]
&then value_delete cpp.ec.expanded_path1 -perprocess
&-
&if &[value_defined cpp.ec.seg_path1 -perprocess]
&then value_delete cpp.ec.seg_path1 -perprocess
&-
&if &[value_defined cpp.ec.component1 -perprocess]
&then delete [value_get cpp.ec.component1 -perprocess] -bf;value_delete cpp.ec.component1 -perprocess
&-
&if &[value_defined cpp.ec.expanded_path2 -perprocess]
&then value_delete cpp.ec.expanded_path2 -perprocess
&-
&if &[value_defined cpp.ec.seg_path2 -perprocess]
&then value_delete cpp.ec.seg_path2 -perprocess
&-
&if &[value_defined cpp.ec.component2 -perprocess]
&then delete [value_get cpp.ec.component2  -perprocess] -bf;value_delete cpp.ec.component2 -perprocess
&-
&if &[value_defined cpp.ec.already_invoked -perprocess]
&then value_delete cpp.ec.already_invoked -perprocess
&-
&quit
&-
&label cpp_dl_ctl_comments_
&-
&if &[ not [nequal &n 2]] &then &do
   &print Usage: ec &ec_name path1 path2
   &goto cpp_cleanup_
&end
&-
&if &[not [exists segment [strip &1 pl1].pl1 -chase]] &then &do
   &print compare_pl1.ec: Segment not found. &[strip &1 pl1].pl1
   &goto cpp_cleanup_
&end
&-
&attach
&trace &input off
discard_output >tools>teco
ei/&1/0j
:is|<1a,32"n 1a,9"n 1;'' c>|		! qs = macro to skip over SP and HT !
:iq|"|				! qq = double quote !
<.u1				! q1 = point before searching !
&SP(3):sqq "n .u2 :' zu2' q1j		! q2 = start of quoted string !
&SP(3):s|/*|"n .u3 :' zu3' q1j		! q3 = start of comment text !

&SP(3)q2,q3"e 1;'			! q2 = q3: no quote or comment, exit !
&SP(3)q2,q3"l			! q2 lt q3: found quote first !
&SP(6)q2j :sqq "e 1;''		! find matching quote, exit if none !
&SP(3)q2,q3"g			! q2 gt q3: found comment first !
&SP(6)q3j :s|*/| "e 1;'		! find matching */, exit if none !
&SP(6).-2u4			! q4 = end of comment text !
&SP(6)q3j ms			! skip leading white space !
&SP(6)1<"m/format:/			! check for format: !
&SP(9)s/format:/ ms		! skip format: and white space !
&SP(9)<1a,32"e 1;' 1a,9"e 1;' .,q4"e 1;' c>
&HT(4)! skip until ws or end of comment !
&SP(9)ms			! skip white space after modes string !
&SP(9).,q4"e q3-2,q4+2k 1;'	! if at end of comment, it is a control
&HT(4)&SP(2)comment, so delete it !
&SP(6)' q4+2j>			! not a control comment, skip it !
&SP(3)'>

eo/&2/ eq
$
&detach
&trace &input off
&quit
