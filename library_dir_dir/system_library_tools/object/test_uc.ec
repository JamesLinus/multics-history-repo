& testing user control
&
& this ec contains sequences of commands for setting up tests of
& user control and for a standard test.
&
& thvv 1/71
&
& ------------------------------------
&
&goto &ec_name
& - - - - - - - - - - - - - - - - - - - - - - 
&label test_uc
&print Instructions^/
&print first, addname test_uc.ec regenerate_test_environment.ec warm.ec standard_test.ec end_uctest.ec
&print then do "ec func"^/
&print regenerate_test_environment - makes new test bed.
&print warm - used to reset test bed before running a test.
&rpint standard_test - runs standard test of user control
&print end_uctest - destroys test bed
&quit
&
& - - - - - - - - - - - - - - - - - - - - - - 
&label regenerate_test_environment
&attach
&input_line off
&
createdir pdt update
createdir Proj(1 2 3 4 5 6)
createdir SysAdmin
createdir Multics
qedx
a
/* System Master File (SMF) for User/System control test environment */

Maxunits:		60;	/* six users */
Maxusers:		9;	/* nine slots in table */
Maxprim:		10000;
Uwt:		special_listener, 5;
Uwt:		process_overseer_, 10;
 
Administrator:	VanVleck.SysAdmin;
Administrator:	*.SysAdmin;
Administrator:	*.Multics;

Group:		Other;
Grace:		2880;
Ring:		4, 7;
Attributes:	brief, vinitproc, vhomedir, anonymous, bumping, nostartup;


projectid:	SysAdmin;	group:	System;
projectdir:	>user_dir_dir>SysAdmin>tudd>SysAdmin;
maxprim:		2;
attributes:	nobump, guaranteed_login;

projectid:	Proj1;	group:	Group1;
projectdir:	>user_dir_dir>SysAdmin>tudd>Proj1;
maxprim:		2;

projectid:	Proj2;	group:	Group1;
projectdir:	>user_dir_dir>SysAdmin>tudd>Proj2;
maxprim:		1;

projectid:	Proj3;	group:	Group1;
projectdir:	>user_dir_dir>SysAdmin>tudd>Proj3;
maxprim:		3;

projectid:	Proj4;	group:	Group2;
projectdir:	>user_dir_dir>SysAdmin>tudd>Proj4;
maxprim:		3;

projectid:	Proj5;	group:	Other;
projectdir:	>user_dir_dir>SysAdmin>tudd>Proj5;
maxprim:		3;

projectid:	Proj6;	group:	Other;
projectdir:	>user_dir_dir>SysAdmin>tudd>Proj6;
maxprim:	3;

end;

wSMF
q
cv_smf SMF; rn SMF.sat sat
&
& generate initial person master file and person name table
&
qedx
a
/* Person Master File (PERSMF) for User/System control test environment */

personid: Repair; password: repair; projectid: SysAdmin; 
personid: VanVleck; password: tvv; projectid: SysAdmin; alias: vv;

personid: User1; password: 1; projectid: Proj1; alias: u1;
personid: User2; password: 2; projectid: Proj2; alias: u2;
personid: User3; password: 3; projectid: Proj3; alias: u3;
personid: User4; password: 4; projectid: Proj4; alias: u4;
personid: User5; password: 5; projectid: Proj5; alias: u5;
personid: User6; password: 6; projectid: Proj6; alias: u6;
personid: User7; password: 7; projectid: Proj7; alias: u7;
personid: User8; password: 8; projectid: Proj8; alias: u8;
personid: User9; password: 9;                   alias: u9;
personid: User11; password: 11; projectid: Proj1; alias: u11;
personid: User12; password: 12; projectid: Proj1; alias: u12;
personid: User13; password: 13; projectid: Proj1; alias: u13;
personid: User21; password: 21; projectid: Proj2; alias: u21;
personid: User22; password: 22; projectid: Proj2; alias: u22;
personid: User23; password: 23; projectid: Proj2; alias: u23;
personid: User31; password: 31; projectid: Proj3; alias: u31;
personid: User32; password: 32; projectid: Proj3; alias: u32;
personid: User33; password: 33; projectid: Proj3; alias: u33;
personid: User41; password: 41; projectid: Proj4; alias: u41;
personid: User42; password: 42; projectid: Proj4; alias: u42;
personid: User43; password: 43; projectid: Proj4; alias: u43;
personid: User51; password: 51; projectid: Proj5; alias: u51;
personid: User52; password: 52; projectid: Proj5; alias: u52;
personid: User53; password: 53; projectid: Proj5; alias: u53;
personid: User61; password: 61; projectid: Proj6; alias: u61;
personid: User62; password: 62; projectid: Proj6; alias: u62;
personid: User63; password: 63; projectid: Proj6; alias: u63;

end;

wPERSMF
q
cv_persmf PERSMF; rn PERSMF.pnt pnt
&
& now generate pmf's and pdt's for all projects. note proj3 has no pmf or pdt
&
qedx
a
/* Project Master file (PMF) for testing user control. */

Projectid:	Proj1;
Attributes:	dialok, bumping;
Grace:		1;
Homedir:		>udd>sa>tudd>Proj1;
Accountid:	Proj1$account;
Initproc:		process_overseer_;

personid:		User1;
personid:		User11;
personid:		User12;
personid:		User13;

end;

wProj1.pmf
q
qedx
a
/* Project Master file (PMF) for testing user control. */

Projectid:	Proj2;
Homedir:		>udd>sa>tudd>Proj2;
Accountid:	Proj2$account;
Initproc:		process_overseer_;
Attributes:	vhomedir, bumping;
Grace:		1;

personid:		User2;
personid:		User21;
personid:		User22;
personid:		User23;

end;

wProj2.pmf
q
qedx
a
/* Project Master file (PMF) for testing user control. */

Projectid:	Proj4;
Homedir:		>udd>sa>tudd>Proj4;
Accountid:	Proj4$account;
Initproc:		process_overseer_;
Attributes:	vinitproc, vhomedir;
Grace:		1;

personid:		User4;
personid:		User41;	attributes: bumping;	grace: 2880;
personid:		User42;	attributes: bumping;
personid:		User43;

personid:		*;
initproc:		special_listener;
homedir:		>udd>sa>tudd>Proj4;
password:		anon;

end;

wProj4.pmf
q
qedx
a
/* Project Master file (PMF) for testing user control. */

Projectid:	Proj5;
Homedir:		>udd>sa>tudd>Proj5;
Accountid:	Proj5$account;
Initproc:		process_overseer_;
Attributes:	vinitproc;
Grace:		1;

personid:		User5;
personid:		User51;
personid:		User52;
personid:		User53;
personid:		*;
homedir:		>udd>sa>tudd>Proj5;
initproc:		special_listener;

end;

wProj5.pmf
q
qedx
a
/* Project Master file (PMF) for testing user control. */

Projectid:	Proj6;
Homedir:		>udd>sa>tudd>Proj6;
Accountid:	Proj6$account;
Initproc:		process_overseer_;
Attributes:	vinitproc, vhomedir;
Grace:		1;

personid:		User6;	attributes:	brief;
personid:		User61;
personid:		User62;
personid:		User63;

end;

wProj6.pmf
q
qedx
a
/* Project Master file (PMF) for testing user control. */

Projectid:	SysAdmin;
Accountid:	SysAdmin$account;
Initproc:		process_overseer_;
Attributes:	guaranteed_login, nobump, vinitproc, vhomedir, nostartup;
Grace:		2880;

personid:		Repair;
personid:		VanVleck;

end;

wSysAdmin.pmf
q
cv_pmf Proj(1 2 4 5 6).pmf; move Proj(1 2 4 5 6).pmf.pdt pdt>Proj(1 2 4 5 6).pdt
cv_pmf SysAdmin.pmf; move SysAdmin.pmf.pdt pdt>SysAdmin.pdt
&
create master_group_table; addname master_group_table mgt
ed_mgt mgt
System 1
a Group1 2 c abs 3 *
a Group2 1 c abs 3 *
a Other -1
w
q
&
qedx
a
Examples of correct login:
   login Person_name Projectid
   enterp Special_name Projectid
   enter Special_name Projectid
Upper and lower case letters are different.

wlogin_help
q
&
create communications
db
/communications/0="secr"
1="et  "
2=1000
3=1000
4=1000
5=1000
.q
&
qedx
a
* test "lines" file for User/System Control test environment

tty111
tty222
tty333
tty444
tty555
tty666
tty777
tty888
tty999

wlines
q
&
create installation_parms
ed_installation_parms installation_parms
r all
User Control Test Environment
Multics Development
MIT
M u l t i c s   D e v e l o p m e n t
M I T
3600
1
1800
900
2
0 0 0 0
480 1 0 0
360 1 0 0
150 1 0 0
240 1 0 0
0 0 0 0
0 0 0 0
0 0 0 0
.00000038580241
10
360 1 2
240 1 1.8
150 1 1.5
150 1 1.5
16000000
16000000
16000000
16000000
0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0
x
y
X n Your account is out of funds.
T n Your account is past its termination date.
W y Your account is nearly out of funds.
R y Your account is near its termination date.
Y y Your account is out of funds
S y Your account is past its termination date.
.
4 16 7 10 30 6 3 3
0
w
q
&
& get fresh copy of bound components archive
&
cp >ldd>tools>bc>bound_user_control_.archive buc.archive
&print $$$ done
&quit
&
& - - - - - - - - - - - - - - - - - - - - - - 
&
&label end_uctest
&
& clean out after a test
&
answer yes deletedir pdt
answer yes deletedir update
delete pnt pnt.ht sat
answer yes deletedir Proj(1 2 3 4 5 6)
answer yes deletedir SysAdmin
delete PERSMF SMF *.pmf lines login_help mgt answer_table log accounting installation_parms
delete communications whotab
&print $$$ done
&quit
&
& - - - - - - - - - - - - - - - - - - - - - - 
&
&label warm
&
& warmstart after having a bound version
&
delete log accounting answer_table whotab
create log accounting
&attach
debug
/accounting/0=2000;.q
&detach
&print $$$now do a "new_proc" and a "test_dialup"
&quit
&
& - - - - - - - - - - - - - - - - - - - - - - 
&
&label standard_test
&
&print $$$ standard test of user control
&
&attach
test_dialup &1
dialup tty111
login User1 Proj1; plain-vanilla login (1)
1
.lcs$test [wd]
dialup tty222
l User2; default proj and bad password and "l"
zzz
l User2; default proj, good password (2)
2
dialup tty333
l User3; pdt missing for proj 3 on purpose
3
enterp Foo Proj4; anonymous user (2.5)
anon
dialup tty444
l u4; alias (3.5)
4
dialup tty555
l u2; already logged in
2
dialup tty555
enterp Foo Proj1; no anon user
zzz
l User1 Proj4; wrong proj
1
new_proc tty111
terminate tty222
dialup tty555
login Garbage; unknown name
zzz
enterp Foo Proj5; give pass when none required (4)
zzz
dialup tty666
junk User1; incorrect login word
login User9; no default proj
9
wait (allow grace to expire)
dialup tty666
login; no user name
xxx
l u11 -bf; Group1 full, shd bump u1 (4)
11
.lcs
dialup tty777
l User4 Garbage; bad project id
4
l u12 -np; could bump user2 but no-preempt option
12
dialup tty777
l u6; user locked in brief mode in pdt (5)
6
dialup tty111
l u61; fills system (6)
61
dialup tty888
l u62; should be system full because ^bumping
62
dialup tty888
l u22; should bump user2
22
dialup tty999
l Repair; overload system
repair
.lcs
logout tty111
dialup tty111
l User1; check last login - bumps user11 (7)
1
who
logout tty999
lh tty111
login u13 -po special_listener; try special initproc
13
who
&print $$$ now a test of installations
.qedx
rProj5.pmf
$i
personid:		New_fellow;

wtemp
q
.cv_pmf temp
.install temp.pdt
.qedx
rPERSMF
$i
personid: New_fellow; alias: nf; password: new; projectid: Proj5;

wtemp
q
.cv_persmf temp
.install temp.pnt
.admin$word login "Test dialup message buffer."
logout tty888
logout tty111
dialup tty111
wuggawuggawugga; bad login word
l New_fellow
new
.admin$word login
.cv_pmf Proj5.pmf
&print $$$ this should bump the guy...
.install Proj5.pmf.pdt
who
.cv_persmf PERSMF
.install PERSMF.pnt
.dl temp.pnt temp.pdt
.qx
rSMF
/Proj4/;/^$/d
wtemp
q
.cv_smf temp
&print $$$ should bump Foo.Proj4
.install temp.sat
.cv_smf SMF
.install SMF.sat
.dl temp.sat
&print $$$ test of limits
logout tty111
dialup tty111
l u1
1
.qx
rProj1.pmf
/User1/a
 limit:	0;

wtemp
q
.cv_pmf temp
.install temp.pdt
.act_ctl_$update
&print $$$ user1 should be bumped
wait
d
l u1; shd not be able to get in either
1
.cv_pmf Proj1.pmf; install Proj1.pmf.pdt
&print $$$ now test password changing
dialup tty888
l u11 -cpw
11
xxx
logout tty888
dialup tty888
l u11
xxx
logout tty888
dialup tty888
l u11 -cpw -bf -pf
xxx
11
&print $$$ test of help, etc, then shutown
d
hoohah
help
e
logout tty444
logout tty555
.admin$stop
&print $$$ now will check accounting
.ap * * accounting
.print_log log -a
&print $$$ now wait for all bumps
wait
.admin$stop
.act_ctl_$act_ctl_close
quit
&print &quit
&quit
&
