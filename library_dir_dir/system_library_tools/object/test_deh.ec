&  ******************************************************
&  *                                                    *
&  *                                                    *
&  * Copyright (c) 1972 by Massachusetts Institute of   *
&  * Technology and Honeywell Information Systems, Inc. *
&  *                                                    *
&  *                                                    *
&  ******************************************************
&
&command_line off
ioa_ ^|
&command_line on
deh_test_admin  deh_test1$simfault

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  call_deh_test_gate$sf

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  deh_test1$gate_error

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  call_deh_test_gate$ge

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  deh_test1$out_of_bounds

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  call_deh_test_gate$ob

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  "delete gupazkq"

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  deh_test1$pl1_op2

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  call_deh_test_gate$plop2

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  deh_test_gate_$gplop2

&command_line off
ioa_  "*********************************************************************"
&command_line on

deh_test_admin  deh_test5$pl1_op1

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  deh_test1$fixedoverflow

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  call_deh_test_gate$fo

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  deh_test_gate_$gfo

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  deh_test8

&command_line off
ioa_  "*********************************************************************"
&command_line on


copy  &1>deh_test7 deh_test7_copy_


setacl  deh_test7_copy_ n


deh_test_admin  deh_test8

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  deh_test7_copy_$def

&command_line off
ioa_  "*********************************************************************"
&command_line on


setacl  deh_test7_copy_ w


deh_test_admin  deh_test8

&command_line off
ioa_  "*********************************************************************"
&command_line on


setacl  deh_test7_copy_ r


deh_test_admin  deh_test8

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin deh_test7_copy_$def

&command_line off
ioa_  "*********************************************************************"
&command_line on


setacl deh_test7_copy_  re


deh_test_admin  deh_test8


setacl deh_test7_copy_ rewa


deh_test_admin  deh_test1$seg_fault_error

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  deh_test1$bound_call

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  call_deh_test_gate$bc

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  deh_test1$fault_tag_1

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  call_deh_test_gate$ft1

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  deh_test_gate_$gft1

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  ioa_ [get_pathname gloppppp]"

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  deh_test1$oncode_error

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  deh_test1$conversion_error

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  deh_test4

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  deh_test5$conv_err1

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  deh_test5$fault_tag_1

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  deh_test9

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  deh_test1$zerodivide

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  call_deh_test_gate$zd

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  deh_test1$overflow

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  call_deh_test_gate$of

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  deh_test1$underflow

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  call_deh_test_gate$uf

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  deh_test1$trap_before_link

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  call_deh_test_gate$tbl

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  deh_test2$illegal_mod

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  deh_test2$crt

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  deh_test2$lockup

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  deh_test2$illegal_op

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  call_deh_test_gate$iop

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  deh_test2$privileged

&command_line off
ioa_  "*********************************************************************"
&command_line on


deh_test_admin  call_deh_test_gate$pv

&command_line off
ioa_  "*********************************************************************"
&command_line on
