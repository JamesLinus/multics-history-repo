&  ***********************************************************
&  *                                                         *
&  * Copyright, (C) Honeywell Information Systems Inc., 1983 *
&  *                                                         *
&  ***********************************************************
&if [exists argument &1] &then &goto doit.1
&else &print You must supply a pathname argument from which to
&print start mailbox canonicalization.
&print Usage: ec canonicalize_mailbox <pathname>
&quit
&label doit.1
&if [exists directory "&1"] &then &goto doit.2
&print canonicalize_mailbox.ec: "&1" is not an existent directory.
&quit
&label doit.2
set_system_priv dir
ws &1 "canonicalize_mailbox **.sv -force -privilege" -brief 
set_system_priv ^dir
&quit
