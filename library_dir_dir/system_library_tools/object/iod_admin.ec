& iod_admin.ec - extended IO daemon operator commands.
&
& This exec_com is invoked when the IO daemon operator sends the command line,
&	x function {arg1 arg2 ...}
&
&    where in this exec_com,
&	&1 = function
&	&2 = arg1
&	&3 = arg2
&	etc
&
& Notes:
&
&      1. This iod_admin.ec is only a template and may be modified by system administrative personel
&	to fit the site's needs.
&
&      2. It has been primarily designed for use by remote job entry station operators and is not applicable to
&	single device daemons (usually driving on-site peripherals).
&
&      3. Refer to the help facility portion of this exec_com for information on the syntax of the commands.
&
&      4. This exec_com assumes that printer and punch minor device names in the iod_tables start with "prt" and "pun", respectively.
&
& **************************************************************************************************************
&
& Set up default values for remote driver's use of the iod_admin.ec
&
&command_line off
&if [exists segment [pd]>value_seg] &then &else cr [pd]>value_seg; value$set_seg [pd]>value_seg
&
&goto &1_command




& **************************************************************************************************************
&
&	This group of entries is the absentee facility.
&	It allows the operator to manipulate or list only those absentee jobs that were sent in by his station.
&
&label car_command
&
& For: canceling absentee requests
&
&if [exists argument &2] &then &goto car_command_arg
value$set help_arg car
&goto help_car_command

&label car_command_arg
car -sender [iod_val station_id] &f2
&quit

& --------------------------------------------------
&label lar_command
&
& For: list absentee requests
&
&if [exists argument &2] &then &goto lar_anything
lar -sender [iod_val station_id] -a -psn
&quit

& --------------------
&label lar_anything
&
lar -sender [iod_val station_id] &f2
&quit

& --------------------------------------------------
&label mar_command
&
& For: move absentee requests
&
&if [exists argument &2] &then &goto mar_command_arg
value$set help_arg mar
&goto help_mar_command

&label mar_command_arg
mar -sender [iod_val station_id] &f2
&quit




& **************************************************************************************************************
&
&	This group of entries is the daemon facility.
&	It allows the operator to list any queue of any request type known to the system.
&	The operator may only delete or move those requests that are in the queues currently being processed
&	  by his driver.
&
&label cdr_command
&
& For: canceling daemon requests
&
&if [exists argument &2] &then &goto cdr_args
value$set help_arg cdr
&goto help_cdr_command

& --------------------
&label cdr_args
&
&if [nequal [index &2 %] 0] &then &else &goto %char_error
&if [nequal [index %channel%device%pun_rqt%request_type%rqt_string%station_id% %&2%] 0] &then &else &goto bad_arg
&if [equal [iod_val &2] undefined!] &then &goto cdr_by_rqt
cdr -rqt [iod_val &2] &f3
&quit

& --------------------
&label cdr_by_rqt
&
&if [nequal [index %[translate [string [iod_val rqt_string]] % " "]% %&2%] 0] &then &goto rqt_error
cdr -rqt &2 &f3
&quit


& --------------------------------------------------
&label ldr_command
&
& For: list daemon requests
&
&if [exists argument &2] &then &goto ldr_specific
do "ioa_ ""Requests in ^a are;"" &(1); ldr -rqt &(1) -a -admin -psn" ([iod_val rqt_string])
&quit

& --------------------
&label ldr_specific
&
&if [nequal [index &2 %] 0] &then &else &goto %char_error
&if [nequal [index %channel%device%pun_rqt%request_type%rqt_string%station_id% %&2%] 0] &then &else &goto bad_arg
&if [equal [iod_val &2] undefined!] &then &goto ldr_any_rqt
ioa_ "Requests in ^a are;" [iod_val &2]
ldr -rqt [iod_val &2] -a -admin -psn &f3
&quit

& --------------------
&label ldr_any_rqt
&
&print Requests in &2 are;
ldr -rqt &2 -a -admin -psn &f3
&quit

& --------------------------------------------------
&label mdr_command
&
& For: move daemon requests
&
&if [exists argument &2] &then &goto mdr_args
value$set help_arg mdr
&goto help_mdr_command

& ----------
&label mdr_args
&
&if [nequal [index &2 %] 0] &then &else &goto %char_error
&if [nequal [index %channel%device%pun_rqt%request_type%rqt_string%station_id% %&2%] 0] &then &else &goto bad_arg
&if [equal [iod_val &2] undefined!] &then &goto mdr_by_rqt
mdr -rqt [iod_val &2] &f3
&quit

& --------------------
&label mdr_by_rqt
&if [nequal [index %[translate [string [iod_val rqt_string]] % " "]% %&2%] 0] &then &goto rqt_error
mdr -rqt &2 &f3
&quit




& **************************************************************************************************************
&
&	This group of entries is the help facility.
&	It explains the syntax of each entry in the iod_admin.ec in a language similar to
&	  that used in the standard driver help command.
&
&label help_command
&
&if [exists argument &2] &then &else &goto help_no_arg
value$set help_arg &2
&goto help_&2_command

& --------------------
&label help_no_arg
&
&print The "x" command allows the daemon operator to perform site defined functions.
&print The format is,
&print ^-x function {arg1 arg2 ...}
value$set help_arg all
&if [query "Do you want help for a specific x function? "] &then &else &goto help_all_command
value$set help_arg [response "Which x function? " -non_null]
&print
&if [equal [value help_arg] am] &then &goto help_am_command
&if [equal [value help_arg] car] &then &goto help_car_command
&if [equal [value help_arg] cdr] &then &goto help_cdr_command
&if [equal [value help_arg] help] &then &goto help_help_command
&if [equal [value help_arg] lar] &then &goto help_lar_command
&if [equal [value help_arg] ldr] &then &goto help_ldr_command
&if [equal [value help_arg] mar] &then &goto help_mar_command
&if [equal [value help_arg] mdr] &then &goto help_mdr_command
&if [equal [value help_arg] pm] &then &goto help_pm_command
&if [equal [value help_arg] sm] &then &goto help_sm_command
ioa_ "Unknown command, ^a" [value help_arg]
&quit


& --------------------
&label help_all_command
&print

& --------------------
&label help_am_command
&
&print x am
&print ^2xNeeds no arguments.  Sets up driver's mailbox to receive messages and defers them.
&if [equal [value help_arg] all] &then &else &quit


& --------------------
&label help_car_command
&
&print x car <car arguments>
&print ^2xControl argument supplied; -sender <station ident>
&if [equal [value help_arg] all] &then &else &quit


& --------------------
&label help_cdr_command
&
&print cdr (<minor device name> | <current driver request type>) <cdr arguments>
&print ^2xControl argument supplied; -rqt <current print/punch request type>
&if [equal [value help_arg] all] &then &else &quit


& --------------------
&label help_help_command
&
&print x help {all | am | car | cdr | help | lar | ldr | mar | mdr | pm | sm}
&if [equal [value help_arg] all] &then &else &quit


& --------------------
&label help_lar_command
&
&print x lar {<lar arguments>}
&print ^2xControl argument supplied: -sender <station ident>
&print ^2xIf no arguments given, control arguments supplied: -a -psn -sender <station ident>
&if [equal [value help_arg] all] &then &else &quit

& --------------------
&label help_ldr_command
&
&print x ldr {(<minor device name> | <any request type>) {<ldr arguments>}}
&print ^2xControl arguments supplied are; -a -admin -psn -rqt <current print/punch request type or specified rqt>
&print ^2xIf no arguments are given, current request queues for all minor devices are listed.
&if [equal [value help_arg] all] &then &else &quit

& --------------------
&label help_mar_command
&
&print x mar <mar arguments>
&print ^2xControl argument supplied; -sender <station ident>
&if [equal [value help_arg] all] &then &else &quit

& --------------------
&label help_mdr_command
&
&print x mdr (<minor device name> | <current driver request type>) <mdr arguments>
&print ^2xControl argument supplied; -rqt <current print/punch request type>
&if [equal [value help_arg] all] &then &else &quit

& --------------------
&label help_pm_command
&
&print x pm
&print ^2xNeeds no arguments.  Prints messages or mail in driver's mailbox.
&if [equal [value help_arg] all] &then &else &quit

& --------------------
&label help_sm_command
&
&print x sm <to station ident> {<message>}
&print ^2xSends messages to another RJE station.
&print ^2xMessages can be sent conversationally by not supplying the message on the "x sm" command line.
&quit




& **************************************************************************************************************
&
&	This group of entries is the message facility.
&	It allows the operator to initialize his mailbox for receiving messages, printing messages
&	  and sending messages to other daemon drivers (either with one line messages or conversationally).
&
&label am_command
&
& For:  accepting messages
&
am -pn >ddd>io_msg_dir>[iod_val station_id] -print -call iod_driver_message

&  The following two command lines may be removed or disabled if this exec_com is used exclusively by L6/G115 remotes.
&
dm -pn >ddd>io_msg_dir>[iod_val station_id]
&print Use the "x pm" command line to receive messages.
&quit

& --------------------------------------------------------------------------------
&label pm_command
&
& For: print messages
&
pm -pn >ddd>io_msg_dir>[iod_val station_id] -call iod_driver_message
&quit

& --------------------------------------------------
&label sm_command
&
& For: send message supplied or conversationally
&
&if [exists argument &2] &then &else &goto missing_arg
&if [exists argument &3] &then &else &goto sm_conversational
sm -pn >ddd>io_msg_dir>&2 from driver [iod_val station_id]: &f3
&quit

& --------------------
&label sm_conversational
&print Enter your station_id as the first message line.
&print Send a line containing only a "." to exit send message.
sm -pn >ddd>io_msg_dir>&2
&quit




& --------------------------------------------------
&label rqt_error
&
& The operator made a mistake specifying a request type.
&
ioa_ "x: Request type argument of ""&1"" function must be ""^a""^( or ""^a""^)." [iod_val rqt_string]
&quit

& --------------------------------------------------------------------------------
&label %char_error
&
&print x: Illegal character "%" found in argument.

& --------------------------------------------------------------------------------
&label bad_arg
&
&print x: **** Illegal or missing argument to "x &1" command. ****
&quit

& --------------------------------------------------------------------------------
&label missing_arg
&
& Notify the operator that an expected argument is missing.
&
&print <<<< Missing argument to "x &1" command. >>>>
&quit

& --------------------------------------------------------------------------------
& An unknown function has been given to the x command.
&
&label &1_command
&
&print >>>> Undefined "x" command function, &1 <<<<
&quit

& --------------------------------------------------------------------------------
