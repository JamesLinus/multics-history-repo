&version 2
&trace off
&-
&- Re-written 1985-03-21 by E. Swenson.
&-
&- This exec_com is used to enable RCP Resource Management.  It is intended
&- to be executed by a system administrator (preferably on the SysAdmin
&- project).  
&-
&- First check to see if there are any registries in >sc1>rcp.  If so,
&- abort, since this most likely means that RM has already been enabled.
&- If it hasn't, there will be errors later on attempting to install the
&- RTDT anyway, so we've better give the administrator a change to delete
&- these registries.
&-
&set ME rcprm_start_up.ec
&-
&- If we're debugging, first argument specifies the location of the
&- ">system_control_1" directory.
&-
&if &[exists argument &1]
&then &set SC1 &1
&else &set SC1 >system_control_1
&-
&- If we're debugging, second argument specifies the location of the
&- ">udd>SysAdmin>admin" directory.
&-
&if &[exists argument &2]
&then &set ADMIN &2
&else &set ADMIN >user_dir_dir>SysAdmin>admin
&-
&- If we're debugging, third argument specifies the location of the
&- ">tools" directory.
&-
&if &[exists argument &3]
&then &set TOOLS &3
&else &set TOOLS >system_library_tools
&-
&- Save working directory so we can restore it at end.
&-
&set WORKING_DIR &[wd]
&-
&- Check to see if registries already present.  If so, abort.
&-
&if &[exists entry &(SC1)>rcp>**.rcpr]
&then &do
   &print (&(ME))  Registries already exist in &(SC1)>rcp.
   &print (&(ME))  This usually results from Resource Management's
   &print (&(ME))    already being enabled.
   &quit
&end
&-
&- Now create the exec_com, register.ec, which contains the commands
&- necessary to register all the devices with RM.
&-
change_wdir &(ADMIN)
&-
&print (&(ME))  Creating &(ADMIN)>register.ec which will be used
&print (&(ME))  later to register all the peripheral devices.
&-
qedx &(TOOLS)>make_rgr_commands
&-
&- Now check to see if there is an rtdt to install.
&-
&if &[not [exists entry RTMF.rtdt]]
&then &do
   &if &[not [exists entry RTMF.rtmf]]
   &then &do
      &if &[not [exists entry >tools>RTMF.rtmf]]
      &then &do
         &print (&(ME))  Cannot locate RTMF.rtmf in >tools or
         &print (&(ME))  or in &(ADMIN)
         &goto CLEANUP
      &end
      copy >tools>RTMF.rtmf
   &end
   cv_rtmf RTMF
   &if &[ngreater [severity cv_rtmf] 0]
   &then &do
      &print (&(ME))  Errors converting &(ADMIN)>RTMF.rtmf.
      &goto CLEANUP
   &end
&end      
&-
&- Now enable RM.
&-
change_wdir &(SC1)
&print (&(ME)) Enabling RM in the installation parameters.
&attach
ed_installation_parms
c rsc_ on
w
q
&detach
&print (&(ME)) Enabled RM in the installation parameters.
&-
&- Now install the new RTDT under RM
&-
change_wdir &(ADMIN)
&-
&print (&(ME)) Now installing RTDT (which will create the
&print (&(ME)) registries).
install RTMF.rtdt
&print (&(ME)) Pausing for 60 seconds to allow RTDT to
&print (&(ME)) be installed and registeries to be created.
pause 60
&if &[query "(rcprm_start_up.ec):  Did the RTDT get installed ok?"]
&then &do
   &print (&(ME))  Executing &(ADMIN)>register.ec
   &print (&(ME))  to register all devices in the registries.
   exec_com register
   &print (&(ME))  Enabling of RCP/RM complete.
&end
&else &print (&(ME)) Aborting.  Manual intervention required.
&label CLEANUP
change_wdir &(WORKING_DIR)
&quit
