&  *****************************************************
&  *                                                   *
&  * Copyright (C) 1986 by Massachusetts Institute of  *
&  * Technology and Honeywell Information Systems Inc. *
&  *                                                   *
&  *****************************************************

& 
&  HISTORY COMMENTS:
&   1) change(86-08-19,JSLove), approve(86-08-19,MCR7518),
&      audit(86-09-14,Parisek), install(86-10-02,MR12.0-1175):
&      Created as a tool to verify the correctness of the check_star_name_ and
&      match_star_name_ implementation.
&                                                       END HISTORY COMMENTS
& 
&command_line off
&-
&- This exec_com is used to test new versions of match_star_name_, which also
&- includes the entrypoints check_star_name_, check_star_name_$entry, and
&- check_star_name_$path.  It does this by using the command
&- test_match_star_name.  This command takes a keyword as its first argument,
&- a star name as its second argument, and optional additional arguments which
&- are matched against the star name.  The keyword specifies what the
&- acceptable error codes are from the various tests that are made.  If the
&- results of the calls are not correctly predicted by the keyword, and error
&- message is printed.  In addition, it further tests the check_star_name_
&- entrypoint using the test_check_star_name comment.  This command takes a
&- starname to be tested as its first argument, a comma separated list of
&- keywords as its second argument which is used to construct the control
&- mask, a keyword or digit as its third argument which is the expected star
&- type, and a keyword or "0" as its fourth argument which is the expected
&- error code.  An error message is printed if the actual star type or error
&- code is not correctly predicted by the arguments.
&-
&- test_match_star_name makes calls in the following order:
&-
&- 1)  Call check_star_name_ (starname, CHECK_STAR_IGNORE_ALL, star_type, code);
&- 2)  Call check_star_name_$entry (starname, code);
&- 3)  Call check_star_name_$path (starname, code);
&- 4)  Call match_star_name_ (starname, starname, code);
&- 5+) Call match_star_name_ (matchname, starname, code);
&-
&- Possible keywords:
&-
&-   0	All tests return 0.
&-   1	All check entries return 1, matches return 0.
&-   2	All check entries return 2, matches return 0.
&-   b	All entries return badstar.
&-   0b	$entry returns badstar, all others 0.
&-   0bb	$entry and $path return badstar, others 0.
&-   1b	$entry returns badstar, checks 1, matches 0.
&-   1b0	$entry returns badstar, $path 0, check 1, matches 0.
&-   1b2	$entry returns badstar, $path 2, check 1, matches 0.
&-   1bb	$entry and $path return badstar, check 1, matches 0.
&-   2b	$entry returns badstar, checks 2, matches 0.
&-   bb0	$entry returns badstar, $path 0, others badstar.
&-   bb1	$entry returns badstar, $path 1, others badstar.
&-   bb2	$entry returns badstar, $path 2, others badstar.
&-
&- Appending an "n" to any keyword specifies that tests 5+ will return
&- error_table_$nomatch.  This is possible even when the starname is bad
&- because the mismatch may occur before the invalidity is discovered.
&- Test 4, matching the starname against itself, must always return
&- either 0 or error_table_$badstar.  It returns badstar in exactly
&- the same cases that check_star_name_ does.

&print Demonstrate star name tester (8 errors must follow):
&command_line on
test_match_star_name  1	***
test_match_star_name  2	xx	yy
&command_line off
&print No errors may follow this point.

&- Test constants with and without dots.  These constants are identified as
&- type zero star names and matched with a single PL/I comparison.

test_match_star_name  0n	xxxxxx	""  .  x  xx  xxx  xxxx  xxxxx  xxxxxxx  xxxxxxxx  xxxxxxxxx  xxxxxy  x.x  x.x.x.x
test_match_star_name  0n	x.x.x.x	""  .  x  xxxxxx  xxxxxxx  xxxxxxxx  x.x  x.x.x  x.x.x.x.x  .x.x.  x...x  xx.xx.xx.xx

&- Now lets try lots of type 2 star names.  Every one with only doublestar
&- components and with a single star component up to 22 chars long.

test_match_star_name  2	**	**.*  *.**  ""  .  x  x.x  x.x.x  x.x.x.x.  ?.?  ??  xx  xxx  xxxxxxxxx
test_match_star_name  2	**.*	**.*  *.**  ""  .  x  x.x  x.x.x  x.x.x.x.  ?.?  ??  xx  xxx  xxxxxxxxx
test_match_star_name  2	*.**	**.*  *.**  ""  .  x  x.x  x.x.x  x.x.x.x.  ?.?  ??  xx  xxx  xxxxxxxxx
test_match_star_name  2	**.**	**.*  *.**  ""  .  x  x.x  x.x.x  x.x.x.x.  ?.?  ??  xx  xxx  xxxxxxxxx
test_match_star_name  2	*.**.**	**.*  *.**  ""  .  x  x.x  x.x.x  x.x.x.x.  ?.?  ??  xx  xxx  xxxxxxxxx
test_match_star_name  2	**.*.**	**.*  *.**  ""  .  x  x.x  x.x.x  x.x.x.x.  ?.?  ??  xx  xxx  xxxxxxxxx
test_match_star_name  2	**.**.*	**.*  *.**  ""  .  x  x.x  x.x.x  x.x.x.x.  ?.?  ??  xx  xxx  xxxxxxxxx
test_match_star_name  2	**.**.**	**.*  *.**  ""  .  x  x.x  x.x.x  x.x.x.x.  ?.?  ??  xx  xxx  xxxxxxxxx

test_match_star_name  2	(**.**.**.**  **.**.**.**.**  **.**.**.**.**.**  **.**.**.**.**.**.**  **.**.**.**.**.**.**.**)
test_match_star_name  2	(**.**.**.**.**.**.**.**.**  **.**.**.**.**.**.**.**.**.**  **.**.**.**.**.**.**.**.**.**.**)

test_match_star_name  2	(*.**.**.**.**.**.**.**  *.**.**.**.**.**.**  *.**.**.**.**.**  *.**.**.**.**  *.**.**.**)
test_match_star_name  2	(**.*.**.**.**.**.**.**  **.*.**.**.**.**.**  **.*.**.**.**.**  **.*.**.**.**  **.*.**.**)
test_match_star_name  2	(**.**.*.**.**.**.**.**  **.**.*.**.**.**.**  **.**.*.**.**.**  **.**.*.**.**  **.**.*.**)
test_match_star_name  2	(**.**.**.*.**.**.**.**  **.**.**.*.**.**.**  **.**.**.*.**.**  **.**.**.*.**  **.**.**.*)
test_match_star_name  2	(**.**.**.**.*.**.**.**  **.**.**.**.*.**.**  **.**.**.**.*.**  **.**.**.**.*)
test_match_star_name  2	(**.**.**.**.**.*.**.**  **.**.**.**.**.*.**  **.**.**.**.**.*)
test_match_star_name  2	(**.**.**.**.**.**.*.**  **.**.**.**.**.**.*)
test_match_star_name  2	(**.**.**.**.**.**.**.*)

&- Out and out BAD star names (Multics spank).

test_match_star_name  b	(***  ****  ***.*  *.***  foo***  ***foo  *..***  **..***  *.**.*.***  foo***bar)

test_match_star_name  bn	*.*foo***		""  .  ..  ...  foo  foo.fo
test_match_star_name  bn	*.*foo.***	""  .  ..  ...  foo  foo.fo

&- Test that overlength names are detected and rejected by
&- check_star_name_$entry, but are OK for other entrypoints.
&- First try constants.

test_match_star_name  0bn	xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx	"" x x.x xxx .x. yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
test_match_star_name  0bn	xxxxxxxxxx.xxxxxxxxxxx.xxxxxxxxxx	"" x x.x xxx .x. yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy

&- Make sure that trailing spaces are not counted in this check.

test_match_star_name  0	"xxxxxxxx                                "  xxxxxxxx
test_match_star_name  0n	"xxxxxxxx                                "  ""  xxxxx  xxxx.xxx  xxxxxxxxxx
test_match_star_name  2	"**.*                                    "
test_match_star_name  1	"foo*bar                                 "  foobar  fooxxxbar

&- Make sure that leading and embedded spaces work.

test_match_star_name  0n	"   foo   bar"	foobar   "foo   bar"  "   foobar"
test_match_star_name  1	"   *.   *"	"   foo.   bar"
test_match_star_name  1n	"   *.   *"	foo.bar  "   foo.bar"   "foo.   bar"

&- Next try overlength star names.

test_match_star_name  1b	abcdefghijklmnopqrstuvwxyz012346.**	abcdefghijklmnopqrstuvwxyz012346
test_match_star_name  1b	abcdefghijklmnopqrstuvwxyz012346.**	abcdefghijklmnopqrstuvwxyz012346.abcdefghijklmnopqrstuvwxyz
test_match_star_name  1bn	abcdefghijklmnopqrstuvwxyz012346.**	abcdefghijklmnopqrstuvwxyz012346abcdefghijklmnopqrstuvwxyz

&- Finally, try overlength names of type two (matches anything).  First,
&- try a length of exactly 32, which must be accepted.  Then try longer ones.

test_match_star_name  2	**.**.**.**.**.**.**.**.**.**.**	"" x x.x xxx .x. yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
test_match_star_name  2b	**.**.**.**.**.**.**.**.**.**.**.**	"" x x.x xxx .x. yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
test_match_star_name  2b	*.**.**.**.**.**.**.**.**.**.**.**	"" x x.x xxx .x. yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
test_match_star_name  2b	**.*.**.**.**.**.**.**.**.**.**.**	"" x x.x xxx .x. yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
test_match_star_name  2b	**.**.*.**.**.**.**.**.**.**.**.**	"" x x.x xxx .x. yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
test_match_star_name  2b	**.**.**.*.**.**.**.**.**.**.**.**	"" x x.x xxx .x. yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
test_match_star_name  2b	**.**.**.**.*.**.**.**.**.**.**.**	"" x x.x xxx .x. yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
test_match_star_name  2b	**.**.**.**.**.*.**.**.**.**.**.**	"" x x.x xxx .x. yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
test_match_star_name  2b	**.**.**.**.**.**.*.**.**.**.**.**	"" x x.x xxx .x. yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
test_match_star_name  2b	**.**.**.**.**.**.**.*.**.**.**.**	"" x x.x xxx .x. yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
test_match_star_name  2b	**.**.**.**.**.**.**.**.*.**.**.**	"" x x.x xxx .x. yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
test_match_star_name  2b	**.**.**.**.**.**.**.**.**.*.**.**	"" x x.x xxx .x. yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
test_match_star_name  2b	**.**.**.**.**.**.**.**.**.**.*.**	"" x x.x xxx .x. yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
test_match_star_name  2b	**.**.**.**.**.**.**.**.**.**.**.*	"" x x.x xxx .x. yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy

&- Now we have an exhaustive check of simple star names which contain
&- various reserved characters or sequences.  First, "::", which is
&- supposed to be rejected by check_star_name_$entry but otherwise OK.
&- This section is contains many test cases which detect all kinds of
&- interactions of colons and star name parsing because an earlier
&- version of match_star_name_ (never installed) detected double colons
&- in the main parser.  When the requirement that the inner loop
&- match_star_name_ entrypoint reject "::" was dropped, a simpler
&- implementation which has only check_star_name_$entry checking using
&- the PL/I index builtin was adopted.  The test cases are retained
&- in case they are needed in the future.

test_match_star_name  0bbn	::	foo  ""  .  ..  ...  ::x  x:: x::x
test_match_star_name  0bbn	x::	foo  ""  .  ..  ...  ::  ::x  x::x
test_match_star_name  0bbn	::x	foo  ""  .  ..  ...  ::  x::  x::x
test_match_star_name  0bn	x::x	foo  ""  .  ..  ...  xx::x xxxx  xx:x x:xx
test_match_star_name  1b	*::*	::  x::  ::x  x::x  xxx::xxx
test_match_star_name  1bn	*::*	""  .  ..  ...  foo  xx  :  x:x:  .::.  x::.  .::x  :x:x  :x:
test_match_star_name  1b	?::?	x::x  ::::
test_match_star_name  1bn	?::?	""  .  ..  ...  foo  :: x:: ::x  xx::x  x::xx
test_match_star_name  1b	??::??	xx::xx  ::::::
test_match_star_name  1bn	??::??	""  .  ..  ...  foo  :: x:: ::x  xx::x  x::xx  xxx::xx  xx::xxx
test_match_star_name  1b	*::?	::x  x::x  xx::x  xxx::x  :::  ::::  :::::
test_match_star_name  1bn	*::?	""  .  ..  ...  ::  ::xx  x::  x::xx  xxx::  xxx::xx
test_match_star_name  1b	*::??	::xx  x::xx  xx::xx  xxx::xx  ::::  :::::  ::::::
test_match_star_name  1bn	*::??	""  .  ..  ...  ::  ::x  ::xxx  x::  x::x  x::xxx  xxx::  xxx::x  xxx::xxx
test_match_star_name  1b	?::*	x::  x::x  x::xx  x::xxx  :::  ::::  :::::
test_match_star_name  1bn	?::*	""  .  ..  ...  ::  xx::  xxx::  xxxx::  ::x  ::xxx  xx::x
test_match_star_name  1b	??::*	xx::  xx::x  xx::xx  xx::xxx  ::::  :::::  ::::::
test_match_star_name  1bn	??::*	""  .  ..  ...  ::  x::  x::x  xxx::  xxxx::  ::x  ::xxx

test_match_star_name  0n	:x:	foo  ""  .  ..  ...  :x:x  x:x: x:x:x
test_match_star_name  0n	x:x:	foo  ""  .  ..  ...  :x:  :x:x  x:x:x
test_match_star_name  0n	:x:x	foo  ""  .  ..  ...  :x:  x:x:  x:x:x
test_match_star_name  0n	x:x:x	foo  ""  .  ..  ...  xx:x:x xxxx  xx:x x:xx
test_match_star_name  1	*:x:*	:x:  x:x:  :x:x  x:x:x  xxx:x:xxx
test_match_star_name  1n	*:x:*	""  .  ..  ...  foo  xx  :  .:x:.  x:x:.  .:x:x
test_match_star_name  1	?:x:?	x:x:x
test_match_star_name  1n	?:x:?	""  .  ..  ...  foo  :x: x:x: :x:x  xx:x:x  x:x:xx

&- Now test for pathname delimiters embedded in the star name.  These
&- should be rejected by check_star_name_$entry.  They are treated
&- specially by check_star_name_$path, in that only the part of the
&- name following the last pathname delimiter is checked, and if it is
&- null, then zero is returned.  The check_star_name_ and match_star_name_
&- entrypoints ignore them.  First, less than:

test_match_star_name  0bn	<	foo  ""  .  ..  ...  <x  x< x<x
test_match_star_name  0bn	x<	foo  ""  .  ..  ...  <  <x  x<x
test_match_star_name  0bn	<x	foo  ""  .  ..  ...  <  x<  x<x
test_match_star_name  0bn	x<x	foo  ""  .  ..  ...  xx<x xxxx  xx:x x:xx
test_match_star_name  1b	*<*	<  x<  <x  x<x  xxx<xxx
test_match_star_name  1bn	*<*	""  .  ..  ...  foo  xx  :  x:x:  .<.  x<.  .<x  :x:x  :x:
test_match_star_name  1b	?<?	x<x
test_match_star_name  1bn	?<?	""  .  ..  ...  foo  < x< <x  xx<x  x<xx
test_match_star_name  1b0	*<x	<x  foo<x
test_match_star_name  1b0n	*<x	""  <  x<  <xx  xx<xx  foo
test_match_star_name  bb0	(***<  <***<xxx  *.***<x.x)
test_match_star_name  bb1	(***<*  <***<*.*  *.***<**foo)
test_match_star_name  1b2	*<**	<foo.bar  foo<bar  <
test_match_star_name  1b2n	*<**	""  foo.bar  foo.bar<quux  xxx  .  .<
test_match_star_name  bb2	(***<**  ***<*.**  *.***.*<**.*  *.**.***<**.**)

&- Now test greater than.

test_match_star_name  0bn	>	foo  ""  .  ..  ...  >x  x> x>x
test_match_star_name  0bn	x>	foo  ""  .  ..  ...  >  >x  x>x
test_match_star_name  0bn	>x	foo  ""  .  ..  ...  >  x>  x>x
test_match_star_name  0bn	x>x	foo  ""  .  ..  ...  xx>x xxxx  xx:x x:xx
test_match_star_name  1b	*>*	>  x>  >x  x>x  xxx>xxx
test_match_star_name  1bn	*>*	""  .  ..  ...  foo  xx  :  x:x:  .>.  x>.  .>x  :x:x  :x:
test_match_star_name  1b	?>?	x>x
test_match_star_name  1bn	?>?	""  .  ..  ...  foo  > x> >x  xx>x  x>xx
test_match_star_name  bb0	(***>  >***>xxx  *.***>x.x)
test_match_star_name  bb1	(***>*  >***>*.*  *.***>**foo)
test_match_star_name  1b2	*>**	>foo.bar  foo>bar  >
test_match_star_name  1b2n	*>**	""  foo.bar  foo.bar>quux  xxx  .  .>
test_match_star_name  bb2	(***>**  ***>*.**  *.***.*>**.*  *.**.***>**.**)

&- Now test both together:

test_match_star_name  0bn	<foo>	""  .  ..  foo
test_match_star_name  0bn	<<a>b	""  .  ..  a  b
test_match_star_name  1b	<a>*	<a>foo
test_match_star_name  1bn	<a>*	""  .  ..  a  foo
test_match_star_name  1b0n	<*>a	<.>a

&- The entrypoints for validating file system names, check_star_name_$entry
&- and check_star_name_$path, must reject names which contain null components.
&- The more general entrypoints ignore null components.
&- Here we give that feature a systematic workout.  First, constants.

test_match_star_name  0bbn	""	.  ?  *  x  xx  ??  xxx  x.x  .x  x.  x.x  x.x.  x.x.  x..x
test_match_star_name  0bbn	.x	""  .  x.x  ..x  x..  xx  x  x.x.x.x  x.x.x.  .x.x.x
test_match_star_name  0bbn	.x.x.x	""  .  x.x  ..x  x..  xx  x  x.x.x.x  x.x.x.
test_match_star_name  0bbn	x.	""  .  x.x  ..x  x..  xx  x  x.x.x.x  x.x.x.  .x.x.x
test_match_star_name  0bbn	x.x.x.	""  .  x.x  ..x  x..  xx  x  x.x.x.x  .x.x.x
test_match_star_name  0bbn	x..x	""  .  x.x  ..x  x..  xx  x  x.x.x.x  x.x.x.  .x.x.x
test_match_star_name  0bbn	.	""  ..  x.x  ..x  x..  xx  x  x.x.x.x  x.x.x.  .x.x.x
test_match_star_name  0bbn	..	""  .  ...  x.x  ..x  x..  xx  x  x.x.x.x  x.x.x.  .x.x.x
test_match_star_name  0bbn	x..	""  ...  x.x.x  x.x.  x..x  .x.x  ..x
test_match_star_name  0bbn	..x	""  ...  x.x.x  x.x.  x..x  .x.x  x..

&- We test the legality and type checking for null components in names
&- which contain stars.  Later we will test matching, but for now I have
&- thrown in a couple of cases where the match must be successful.

test_match_star_name  1bb	(.*  .*.  .*.*  .*.*.  .*.*.*  .*.*.*.  .*.*.*.*  .*.*.*.*.  .*.*.*.*.*)
test_match_star_name  1bb	(*.  *.*.  *.*.*.  *.*.*.*.  *.*.*.*.*.)
test_match_star_name  1bb	(.**  .**.**  .**.**.**  .**.**.**.**)  ""
test_match_star_name  1bb	(.**.  .**.*  .**.**.  .**.**.*  .**.**.**.  .**.**.**.*  .**.**.**.**.)
test_match_star_name  1bb	(**.  **.*.  **.*.*.  **.*.*.*.  **.*.*.*.*.)
test_match_star_name  1bb	(*.**.  *.*.**.  *.*.*.**.  *.*.*.*.**.  *.**.*.  *.*.**.*.  *.*.**.*.*.)
test_match_star_name  1bb	(**.**.  **.**.**.  **.**.**.**.  **.**.**.**.**.)  ""
test_match_star_name  1bb	(.*.**  .*.*.**  .*.*.*.**  .*.*.*.*.**  .*.**.*  .*.**.*.*  .*.**.*.*.*  .*.*.**.*  .*.*.*.**.*  .*.*.**.*)

test_match_star_name  1bb	(*..*  **..*  *..**  **..**  *.*..*  *..*.*  **..*.*  **..**.*  *.*..*)
test_match_star_name  1bb	(**.*..*  *.*..**  *.**..*  **.*..**)

test_match_star_name  1bb	(*...*  **...*  *...**  **...**  *.*...*  *.**...*  **.*...*  **.**...*)
test_match_star_name  1bb	(*.*...**  *.**...**  **.*...**  **.**...**  .*.*...*  *.*...*.)

&- We now know that type 0 and type 2 star names work, and we have already
&- tested several other constructs in passing, but now we exhaustively test
&- all the comparison routines.  First we test routines which handle the END
&- (i.e., terminal comparison) of a type one star name without a terminal
&- literal (i.e., the final character must be star or query).

test_match_star_name  1	?	x  *
test_match_star_name  1n	?	""  .  ..  ...  xx  x.x  .x  x.  ??  **  ?*  *?  ?.?  ?.*  *.?  *.*

test_match_star_name  1	??	xx  **  xy  ?x  x?
test_match_star_name  1n	??	""  .  ..  ...  x  x.x  x..x  xxx  xxxxxxx  xx.x  x.xx

test_match_star_name  1	*	""  x  xx  xxx  ?  ??  *  **  xxxxxxxxxx
test_match_star_name  1n	*	.  ..  ...  x.x  x.x.x  x..x  .x  x.  xxx.  xxx.x

test_match_star_name  1bb	*.	.  foo.  ?.  foobarbazquux.
test_match_star_name  1bbn	*.	""  xxx  .foo  foo.bar  foo.bar.  .foo.  ..  ...

test_match_star_name  1	*.*	.  foo.  .bar  foo.bar
test_match_star_name  1n	*.*	""  xxx  foo.bar.  .foo.  ..  ...

test_match_star_name  1	*.*.*	..  foo..  .bar.  ..quux  foo.bar.  foo..quux  .bar.quux  foo.bar.quux
test_match_star_name  1n	*.*.*	""  .  ...  foo  foo.bar  foo.bar.baz.quux  foo..bar.baz  "this is a.test"

test_match_star_name  1bb	*.**.	.  foo.  foo.bar.  foo..  foo.bar.baz.  *.*.
test_match_star_name  1bbn	*.**.	""  .foo  foo.bar  foo.bar.baz  foo..baz  *.*  *.*.*

test_match_star_name  1bb	**.*.	.  foo.  foo.bar.  foo..  foo.bar.baz.  *.*.
test_match_star_name  1bbn	**.*.	""  .foo  foo.bar  foo.bar.baz  foo..baz  *.*  *.*.*

test_match_star_name  1	*.**.*	.  ..  ...  foo.bar  foo.  .bar  foo.bar.baz  foo.bar.baz.quux
test_match_star_name  1n	*.**.*	""  foo  "this is a test"

test_match_star_name  1bb	**.	""  .  foo.  foo.bar.  foo.bar.baz.  foo..
test_match_star_name  1bbn	**.	x  .foo  foo.bar  foo.bar.bax  foo..bar  ...foo

test_match_star_name  1	**.?	x  foo.x  foo.bar.x  .x  ..x
test_match_star_name  1n	**.?	""  .  ...  xx  .xx  ..xx  xxx  foo.bar

test_match_star_name  1	**.??	xx  foo.xx  foo.bar.xx  .xx  ..xx
test_match_star_name  1n	**.??	""  .  ..  ...  ....  x  foo  foo.x  foo.bar

test_match_star_name  1	**?	x  xx  xxx  xxxxxxxx  .x  .xxx  foo.x
test_match_star_name  1n	**?	""  x.  foo.  foo.bar.  .  ..  ...

test_match_star_name  1	**??	xx  xxx  xxxx  foo.xx  x.xx  x.x.x.xxx
test_match_star_name  1n	**??	""  x  foo.x  foo.bar.bax.x  .  ..  ...  ....

test_match_star_name  1	**?*	x  xx  xxx  xxxxxxxx  .x  .xxx  foo.x
test_match_star_name  1n	**?*	""  x.  foo.  foo.bar.  .  ..  ...

test_match_star_name  1	**??*	xx  xxx  xxxx  foo.xx  x.xx  x.x.x.xxx
test_match_star_name  1n	**??*	""  x  foo.x  foo.bar.bax.x  .  ..  ...  ....

test_match_star_name  1	**?*?	xx  xxx  xxxx  foo.xx  x.xx  x.x.x.xxx
test_match_star_name  1n	**?*?	""  x  foo.x  foo.bar.bax.x  .  ..  ...  ....

test_match_star_name  1	**?**	x  x.  .x  .x.  x.x  foo.bar
test_match_star_name  1n	**?**	""  .  ..  ...  ....

test_match_star_name  1	**??**	xx  x.xx  xx.x  .xx.  foo.bar
test_match_star_name  1n	**??**	""  .  ..  ...  ....  x  x.x  x.x.x.x  x.x.  .x  x.  .x.  .x.x

test_match_star_name  1	**?**?**	x.x  xx  xx.x  x.xx  xxx
test_match_star_name  1n	**?**?**	""  .  ..  ...  ....  x  .x  x.  x..  ..x  .x.

test_match_star_name  1	*?	x  xx  xxxx
test_match_star_name  1n	*?	""  .x  x.  x.x  x.x.x  .  ..  ...

test_match_star_name  1	?*	x  xx  xxxx
test_match_star_name  1n	?*	""  .x  x.  x.x  x.x.x  .  ..  ...

test_match_star_name  1	*?*	x  xx  xxxx
test_match_star_name  1n	*?*	""  .x  x.  x.x  x.x.x  .  ..  ...

test_match_star_name  1	*??	xx  xxx  xxxx
test_match_star_name  1n	*??	""  x  .x  x.  x.x  .x.  .  ...  .xx  x.xx  xx.x

test_match_star_name  1	?*?	xx  xxx  xxxx
test_match_star_name  1n	?*?	""  x  .x  x.  x.x  .x.  .  ...  .xx  x.xx  xx.x

test_match_star_name  1	*??*	xx  xxx  xxxx
test_match_star_name  1n	*??*	""  x  .x  x.  x.x  .x.  .  ...  .xx  x.xx  xx.x

&- That's all the terminal comparison routines which don't involve terminal
&- literals.  They follow.

test_match_star_name  1	*foo	foo  xfoo  xxfoo  xxxxxxxxxxfoo  foofoofoofoo
test_match_star_name  1n	*foo	fo  foof  fooo  foo.foo  xxfoo.  .  ..  ...  ""

test_match_star_name  1	*.foo	.foo foo.foo  bar.foo
test_match_star_name  1n	*.foo	foo  xfoo  xxfoo  foo.foo.foo  foo.fo

test_match_star_name  1	*.*foo	.foo  foo.foo  foo.foofoo  xfoo.xfoo
test_match_star_name  1n	*.*foo	foo  ""  .  ..  ...  foo.  foo.foo.  a.b.foo

test_match_star_name  1	*.**foo	.foo  .xxxfoo  bar.foo  z.c.x.foo  x.xxxfoo  xxxx.xxx.xfoo
test_match_star_name  1n	*.**foo	foo  ""  .  ..  ...  foo.bar  foo.fo  foo.foo.  foo.foo.fo

test_match_star_name  1	**.*foo	foo  xfoo  .foo  bar.foo  bar.xxxfoo  x.y.z.foo  xy.zfoo
test_match_star_name  1n	**.*foo	foox  ""  .  ..  ...  foo.  foo.bar  x.y.z

test_match_star_name  1	*.**.foo	.foo  ..foo  ...foo  bar.baz.quux.foo  foo.xfoo.foo
test_match_star_name  1n	*.**.foo	""  .  ..  ...  foo  foo.  .foo.  foo.bar  .xfoo  .xxfoo  foo.xfoo.xxfoo

test_match_star_name  1	**.*.foo	.foo  ..foo  ...foo  bar.baz.quux.foo  foo.xfoo.foo
test_match_star_name  1n	**.*.foo	""  .  ..  ...  foo  foo.  .foo.  foo.bar  .xfoo  .xxfoo  foo.xfoo.xxfoo

test_match_star_name  1	**foo	foo  xfoo  .foo  bar.foo  bar.xxxfoo  x.y.z.foo  xy.zfoo
test_match_star_name  1n	**foo	foox  ""  .  ..  ...  foo.  foo.bar  x.y.z

test_match_star_name  1	**.foo	foo  .foo  ..foo  bar.foo  foo.foo
test_match_star_name  1n	**.foo	barfoo  x.barfoo  ""  .  ..  ...

test_match_star_name  1	**.?foo	xfoo  x.xfoo  foo.xfoo
test_match_star_name  1n	**.?foo	foo  foo.foo  xxfoo  foo.xxfoo  ""  .  ..  ...

test_match_star_name  1	**?foo	xfoo  xxfoo x.xfoo
test_match_star_name  1n	**?foo	foo  x.foo  xfoo.  xfoo.foo  ""  .  ..  ...

test_match_star_name  1	*?foo	xfoo  xxfoo  xxxfoo
test_match_star_name  1n	*?foo	foo  xxx  foo.  x.foo  x.x  ""  .  ..  ...

test_match_star_name  1	??*foo	xxfoo  xxxfoo
test_match_star_name  1n	??*foo	foo  xfoo  xxx  foo.  x.foo  x.x  ""  .  ..  ...

test_match_star_name  1	???foo	foofoo  xxxfoo
test_match_star_name  1n	???foo	foo  xfoo  xxfoo  xxxxfoo  xxxxxfoo  foofofoo  x.foo  x..foo  ""  .  ..  ...

&- Now we test some simple null component cases.

test_match_star_name  1bb	.*	.  .foo
test_match_star_name  1bbn	.*	""  ..  ...  foo.  .foo.  foo.bar

test_match_star_name  1bb	.*?	.x  .foo
test_match_star_name  1bbn	.*?	""  .  ..  ...  foo.  foo.bar  foo

test_match_star_name  1bb	.*foo	.foo  .xfoo  .xxxfoo
test_match_star_name  1bbn	.*foo	""  .  ..  ...  foo  foo.  foo.bar  foo.foo.

test_match_star_name  1bb	.**	.  ..  ...  ""  .foo  .foo.bar  .foo.
test_match_star_name  1bbn	.**	foo  foo.bar  foo.  foo..bar

test_match_star_name  1bb	.**.	.  ..  ...  .foo.  .foo.bar.
test_match_star_name  1bbn	.**.	""  foo  foo.bar  foo.  .bar  foo..bar

test_match_star_name  1bb	.**?	.x  .x.x.x.x.x  ......x  .foo.bar
test_match_star_name  1bbn	.**?	""  .  ..  ...  foo  foo.bar  foo..bar  .foo.

test_match_star_name  1bb	.**foo	.foo  .xfoo .x.foo .x.xfoo
test_match_star_name  1bbn	.**foo	foo  foo.foo  foo..foo  foo.

&- The number of singlestar components is not supposed to matter,
&- but depending on the order in which they are encountered,
&- differing amounts of state are stashed away.

test_match_star_name  1	*.*.**	.  ..  ...  x.x  x.  .x  x.x.x  x.x.x.x.x
test_match_star_name  1n	*.*.**	""  foo

test_match_star_name  1	*.*.**.*	..  ...  x.x.x  x.x.  x..x  .x.x  x..  .x.  ..x  foo.bar.baz.quux
test_match_star_name  1n	*.*.**.*  ""  .  foo  foo.bar  .foo  bar.

test_match_star_name  1	*.*.*.**	..  ...  x.x.x  x.x.  x..x  .x.x  x..  .x.  ..x  foo.bar.baz.quux
test_match_star_name  1n	*.*.*.**  ""  .  foo  foo.bar  .foo  bar.

test_match_star_name  1bbn	*.*.	""  .  a.b.c  ..c  a.b.c.  a.b.c.d
test_match_star_name  1bbn	*.**.*.	""  .  a.b  .b  a.b.c  .b.c  ..c  a.b.c.d  ...d
test_match_star_name  1bbn	*.*.**.	""  .  a.b  .b  a.b.c  .b.c  ..c  a.b.c.d  ...d

test_match_star_name  1	*.?	.x  x.x  xx.x  xxx.x
test_match_star_name  1n	*.?	""  .  ..  ...  foo  foo.  foo.fo  foo.bar.x

test_match_star_name  1	*.*?	.x  .xx  x.x  x.xx  xx.x  xx.xx
test_match_star_name  1n	*.*?	""  .  ..  ...  foo  foo.  foo.bar.x

test_match_star_name  1	*.**.*?	.x  .xx  x.x  x.xx  xx.x  xx.xx  x.x.x  x..x  ..x  x.x.x.xx
test_match_star_name  1n	*.**.*?	""  .  ..  ...  ....  foo  foo.  foo.bar.  bar.foo.baz.

test_match_star_name  1	*.*.**?	..x  ...x  ....x  x.x.x  x.x.xx  x.x.x.x
test_match_star_name  1n	*.*.**?	""  .  ..  ...  ....  foo  foo.bar  foo.x  foo.bar.  foo.bar.baz.

test_match_star_name  1	*.**.?	.x  ..x  ...x  x.x  xx.x  xx.xx.x
test_match_star_name  1n	*.**.?	""  .  ..  ...  ....  x.  x.xx  x.x.  x.x.xx  x.x.x.  x.x.x.xx

test_match_star_name  1	**.*.?	.x  ..x  ...x  x.x  xx.x  xx.xx.x	
test_match_star_name  1n	**.*.?	""  .  ..  ...  ....  x.  x.xx  x.x.  x.x.xx  x.x.x.  x.x.x.xx

test_match_star_name  1	*.**?	.x  ..x  ...x  x.x  x.xx  x.xxx  x.x.xxx
test_match_star_name  1n	*.**?	""  .  ..  ...  ....  x.  x.x.  x.x.x.  x.x.x.x.

test_match_star_name  1	?**?	xx  x.x  x.x.x  x..x
test_match_star_name  1n	?**?	""  .  ..  ...  ....  .....  x  x.  .x  .x.  x..  ..x  x...  x.x.  xx.  .x.x  .xx

test_match_star_name  1	**foo?	foo1  xfoo1  x.foo1  x.xfoo1
test_match_star_name  1n	**foo?	foo  fooxx  xfoo  xfooxx  x.foo  x.fooxx  x.xfoo  x.xfooxx

test_match_star_name  1	**.foo?	foo1  x.foo1  x.x.foo1  foo.foo1  foo.foo.foo1
test_match_star_name  1n	**.foo?	foo  xfoo  xfoox  fooxx  foo.foo.foo  foo.foo.fooxx  foo.xfoox  ""  .  ..  ...

test_match_star_name  1bb	**..?	.x  ....x  foo..x
test_match_star_name  1bbn	**..?	""  .  ..  ...  .xx  x.xx  x.  x.x.  x.x.xx  foo.x

test_match_star_name  1bb	**..*	.  .foo  ..  ..xxx  .....xx  foo..x  x..x  foo..
test_match_star_name  1bbn	**..*	""  foo  foo.bar  foo.  foo.bar.

&- Now that all terminal comparison routines have been tortured,
&- We are going to try all the hairy nonterminal comparisons.

test_match_star_name  1	**.?o?o	oooo  oooo.oooo  .oooo  .xoxo  ooo.oooo  o.o.oooo
test_match_star_name  1n	**.?o?o   ooo  ooooo  oooo.ooo  oooo.ooooo

test_match_star_name  1	**.?o.*o	oo.o  o.oo.oo  o.xo.xo
test_match_star_name  1n	**.?o.*o	o.oo  xo.ox  o.o.oo

test_match_star_name  1	**.?.*o	x.o  o.o  oo.o.oo  xx.x.xo
test_match_star_name  1n	**.?.*o	o  oo.o  o.oo.o  o..o

test_match_star_name  1	**?o?o	oooo  xoxo  xxoxo  x.x.xoxo  x.x.oooo  ooooo  oxxxooo
test_match_star_name  1n	**?o?o	ooo  ooxxo  oooox  x.x.xoox

test_match_star_name  1	**?o.*o	oo.o  oo.oo  xo.xo  xxxo.o  xxxxo.ooo
test_match_star_name  1n	**?o.*o	o.o  o  oo  oo.x  oo.xx.o

test_match_star_name  1	**.o?o	ooo  .ooo  x.ooo  ooo.ooo  ooo.oxo
test_match_star_name  1n	**.o?o	ooo.xxx  xxx  oox  xoo  xox  oo  oooo

test_match_star_name  1	**.o.*o	o.o  o.xo  x.o.o  o.o.o.o.x.o.xo
test_match_star_name  1n	**.o.*o	o.o.o.o.x.o  o  oo  x.o.x  x.x.ooo  o.o.x.o

test_match_star_name  1	**o?o	ooo  oxo  xoxo  oooooo  oxoxoxoxoxo
test_match_star_name  1n	**o?o	oo  xoo  oox  xox  oooooox  oooooooxxo

test_match_star_name  1	**o.*o	o.o  xxxxxxxo.o    o.o.o.o.o.o  o.o.o.o.o.xxo
test_match_star_name  1n	**o.*o	o  o.o.o.o.x  o.o.o.o.oooox  o.o.oox.o

test_match_star_name  1	*.**.o?o	foo.ooo  .oxo
test_match_star_name  1n	*.**.o?o	oxo  ooo  ooo.xoo  ooo.oox  ooo.ooo.ooo.o

test_match_star_name  1	*.**.o.*o	foo.o.o  .o.o.xo
test_match_star_name  1n	*.**.o.*o	o  o.o  o.oo.o

test_match_star_name  1	*.**o?o	foo.ooo  oooo.ooooo
test_match_star_name  1n	*.**o?o	ooo  ooooo  oooo.oo  ooo.xoo

test_match_star_name  1	*.**o.*o	foo.o.o  .o.ooo.oo.o
test_match_star_name  1n	*.**o.*o	o  o.o  o.x.o  o.o.ox  o.ox.o

test_match_star_name  1	?o.*o	oo.o  oo.xo  xo.xxo  xo.oo
test_match_star_name  1n	?o.*o	o.o  ooo  ox.o  oo.x

test_match_star_name  1	*.o.*o	x.o.o  o.o.xo
test_match_star_name  1n	*.o.*o	oo  o.o  o.o.x.o

test_match_star_name  1	o.*o	o.o  o.ooooooo
test_match_star_name  1n	o.*o	o  oo  o.ox

test_match_star_name  1	o.*o?o	o.ooo  o.oooooxo
test_match_star_name  1n	o.*o?o	ooo  oo.ooo  o.oxxo

test_match_star_name  1	o.*.o?o	o..ooo  o.oooo.ooo  o.o.oxo
test_match_star_name  1n	o.*.o?o	x..ooo  o.oooo  o.oooo.xoo  ooo  o.ooo

test_match_star_name  1	o.*o.?o	o.ffo.oo
test_match_star_name  1n	o.*o.?o	o..o.oo  o..oo  oo.o.oo  o.o.o  o.o.ooo  o.oo  o.o.o.oo

test_match_star_name  1	o.*o.o?o	o.o.oxo  o.ooo.oxo
test_match_star_name  1n	o.*o.o?o	oo.o.oxo  o..oxo  o.o.oo  o.o.oooo  o.o.o.ooo  o.ooo

test_match_star_name  1	o.*o.*o	o.o.o  o.xxxxo.o  o.o.xxxxo  o.xxxxo.xxxxo
test_match_star_name  1n	o.*o.*o	o..  o..o  o.o.  oo.o.o  o.x.o  o.o.x  o.ox.o  o.o.ox

test_match_star_name  1	o.*.o.*o	o..o.o  o.xxx.o.xxxo
test_match_star_name  1n	o.*.o.*o	.o.o.o  o...o  o...o.o  o.o.o.  o.o.o.o.  o.o.o.ox

test_match_star_name  1	o.*o.o.*o		o.o.o.o  o.xxxo.o.xxxo
test_match_star_name  1n	o.*o.o.*o		o..o.o  o.o.o.  o.o.o.ox  .o.o.o  o.o..o

test_match_star_name  1	?*o?o	xoxo  xxoxo
test_match_star_name  1n	?*o?o	oxox  oxxo  xoox  x.oxo  .oxo  xo.o

test_match_star_name  1	?*o.?o	xo.xo  xxxxo.xo
test_match_star_name  1n	?*o.?o	o.xo  xo.o  xoxo  xoxxo  .o.o  o.o.o

test_match_star_name  1	?*.o?o	x.oxo  oxo.oxo
test_match_star_name  1n	?*.o?o	oxo.xox  oxo.xxo  oxo.oxx  xoxo  xxoxo  x.xoxo x.x.oxo

test_match_star_name  1	?*o.o?o	xo.oxo  xxxxxo.oxo
test_match_star_name  1n	?*o.o?o	o.oxo  oo.oo  oo.xxo  oo.oxx

test_match_star_name  1	?*o.*o	xo.o   xxxxxxo.o  xo.xxxxxxo  xxxxxxo.xxxxxxxxo
test_match_star_name  1n	?*o.*o	o.o  o.o.o  .o.o  oo.x  oo.ox  o.  .o

test_match_star_name  1	?*.o.*o	x.o.o  xxxx.o.o  x.o.xxxxo
test_match_star_name  1n	?*.o.*o	""  .  ..  ...  ooooo  .o.o  o.o.  o.o  o.o.o.o  o.o.ox

test_match_star_name  1	?*o.o.*o	xo.o.o  oooo.o.o  ooo.o.xxxo
test_match_star_name  1n	?*o.o.*o	""  .  ..  ...  oooooo  oo.o  oo.o.  oo.o.x  ox.o.o  oo.o.ox  oo.o.o.o

test_match_star_name  1	*.*o?o	.ooo  xxx.oxo
test_match_star_name  1n	*.*o?o	""  .  ..  ...  oooo  ..ooo  o.oox  o.xoo

test_match_star_name  1	*.*o.?o	o.o.oo  .o.xo  xxx.xxo.oo  xxx.ooo.xo
test_match_star_name  1n	*.*o.?o	""  .  ..  ...  ooooo  o.o  o.o.o  o.o.ooo  o.ox.oo  o.o.ox

test_match_star_name  1	*.*.o?o	..ooo  ..oxo  o.o.ooo  xxx.xxx.oxo
test_match_star_name  1n	*.*.o?o	""  .  ..  ...  oooo  o.o  o.oooo  o.o.o.ooo  o.o.oox  o.o.xoo

test_match_star_name  1	*.*o.o?o	.o.ooo  o.o.oxo  o.xxxo.ooo  xxx.ooo.oxo
test_match_star_name  1n	*.*o.o?o	""  .  ..  ...  .ooooo  .ox.ooo  .o.oox  .o.xoo  o..ooo

test_match_star_name  1	*.*o.*o	.o.o  xxx.ooo.ooo  o.xxo.oxo
test_match_star_name  1n	*.*o.*o	""  .  ..  ...  ooooo  o.o  o.o.o.o  o.ox.o  o.o.ox

test_match_star_name  1	*.*.o.*o	..o.o  xxx.xxx.o.xxxo
test_match_star_name  1n	*.*.o.*o	""  .  ..  ...  ooooo  o.o.oo.o  o.o.o.ox

test_match_star_name  1	*.*o.o.*o		.o.o.o  o.o.o.oo  x.xo.o.xo  ooo.oo.o.xo
test_match_star_name  1n	*.*o.o.*o		""  .  ..  ...  oooo  o.o.o  o.o.o.o.o  o.o.o.ox  o.ox.o.o

test_match_star_name  1	*o?o	oxo  ooooooo  oooooooxo  xxxxxxxoxo  xxxxxxxooo   xxxxxxoooo
test_match_star_name  1n	*o?o	""  .  ..  ...  oo  oox  xoo  oooooox  oooooxoo  o.o  ooo.  .ooo

test_match_star_name  1	*o?o.o	oxo.o  ooooooo.o  oooooooxo.o  xxxxxxxoxo.o  xxxxxxxooo.o   xxxxxxoooo.o
test_match_star_name  1n	*o?o.o	""  .  ..  ...  oo.o  oox.o  xoo.o  oooooox.o  oooooxoo.o  o.o  ooo.  .o  oxo.ooo

test_match_star_name  1	*o.?o	o.xo  xxxxxo.oo
test_match_star_name  1n	*o.?o	""  .  ..  ...  o  ooo  ooooo  o.o  o.ooo  o.ox  .oo  o.

test_match_star_name  1	*.o?o	o.oxo  .ooo  xxxxx.ooo
test_match_star_name  1n	*.o?o	""  .  ..  ...  o  ooo  ooooo  o.oo  o.oooo  oooo.oo

test_match_star_name  1	*o.o?o	o.ooo  ooo.oxo  xxxo.oxo
test_match_star_name  1n	*o.o?o	""  .  ..  ...  o  ooo  ooooo  o.oo  o.oooo  oooo.oo

test_match_star_name  1	*o.*o	o.o  oooo.oooo  xxxxo.o   o.xxxxo
test_match_star_name  1n	*o.*o	""  .  ..  ...  o  o.o.o  o.  .o  ox.o  o.ox

test_match_star_name  1	*.o.*o	.o.o  o.o.o  x.o.xxxxxo   xxxx.o.ooooo
test_match_star_name  1n	*.o.*o	""  .  ..  ...  o  o.o  o.o.o.o  o.o.  o.o.ox

test_match_star_name  1	*o.o.*o	o.o.o  xxxxo.o.o  ooooo.o.ooooo  o.o.xxxxxo
test_match_star_name  1n	*o.o.*o	""  .  ..  ...  o  o.o  o.o.o.o  ox.o.o  o.o.ox  .o.o  o.o.

test_match_star_name  1	o.**.*o	o.o  o.oooo  o.xxxo  o.xxx.o  o.ooo.ooo  o....o
test_match_star_name  1n	o.**.*o	""  .  ..  ...  o  oo  ooo  x.o  o.x  o.ox  oo.o

test_match_star_name  1	o.*?o?o	o.xoxo  o.oooo  o.xxxoxo  o.ooooooooooo
test_match_star_name  1n	o.*?o?o	""  .  ..  ...  .xoxo  x.oooo  o.ooo  o.o.oooo  o.x.xoxo

test_match_star_name  1	o.*.*o	o.o.o  o..o  o..xxxxxxo  o.xxxxxx.o  o.xxxx.xxxxo
test_match_star_name  1n	o.*.*o	""  .  ..  ...  .x.o  ..o  o..  x..o  x..ox  o.o  o.o.o.o

&- And now a few others that are expected to be commonly used but which
&- didn't fall into the crude categories above.

test_match_star_name  1	foo**bar	foobar  foo.bar  foobarbar  foofoobar  foofoobarbar
test_match_star_name  1n	foo**bar	""  foo  bar  foo.ar  foo?ar  fobbar  foobarx

test_match_star_name  1	foo**.bar		foo.bar  foo.bar.bar  foo..bar
test_match_star_name  1n	foo**.bar		""  foobar  bar  .bar  foo.foobar

test_match_star_name  1	foo.**bar		foo.bar  foo.foobar  foo.bar.bar
test_match_star_name  1n	foo.**bar		""  foobar  foobar.bar  foo.  bar

test_match_star_name  1	foo.**.bar	foo.bar  foo.quux.bar  foo..bar  foo...bar
test_match_star_name  1n	foo.**.bar	foobar  foo.  .bar  foo.foobar  foobar.bar

test_match_star_name  1	*a?a.*	aaa.a  aaaaaaaaaa.a  xxxxxxxaxa.  axa.xxxxxxx
test_match_star_name  1n	*a?a.*	""  .  ..  ...  aaa  .aaa  aa.  aax.a  aaaaa  aaa.a.a

& Now test the various selectable syntax checks that check_star_name_
& can do.

test_check_star_name  ::	  ""  0  archive_pathname
test_check_star_name  ::bar	  ""  0  archive_pathname
test_check_star_name  ::*	  ""  0  archive_pathname
test_check_star_name  foo::	  ""  0  archive_pathname
test_check_star_name  **::	  ""  0  archive_pathname
test_check_star_name  foo::bar  ""  0  archive_pathname
test_check_star_name  foo::**	  ""  0  archive_pathname
test_check_star_name  **::bar	  ""  0  archive_pathname
test_check_star_name  **::**	  ""  0  archive_pathname

test_check_star_name  ::	  ignore_archive  0  0
test_check_star_name  ::bar	  ignore_archive  0  0
test_check_star_name  ::**	  ignore_archive  1  0
test_check_star_name  foo::	  ignore_archive  0  0
test_check_star_name  **::	  ignore_archive  1  0
test_check_star_name  foo::bar  ignore_archive  0  0
test_check_star_name  foo::**	  ignore_archive  1  0
test_check_star_name  **::bar	  ignore_archive  1  0
test_check_star_name  **::**	  ignore_archive  1  0

test_check_star_name  ::	  process_archive  0  null_name_component
test_check_star_name  ::bar	  process_archive  0  null_name_component
test_check_star_name  ::**	  process_archive  0  null_name_component
test_check_star_name  foo::	  process_archive  0  bad_file_name
test_check_star_name  **::	  process_archive  0  bad_file_name
test_check_star_name  foo::bar  process_archive  0  0
test_check_star_name  foo::**	  process_archive  1  0
test_check_star_name  **::bar	  process_archive  1  0
test_check_star_name  **::**	  process_archive  1  0

test_check_star_name  $	 ""  0  bad_file_name
test_check_star_name  $bar	 ""  0  bad_file_name
test_check_star_name  $*	 ""  0  bad_file_name
test_check_star_name  foo$	 ""  0  bad_file_name
test_check_star_name  **$	 ""  0  bad_file_name
test_check_star_name  foo$bar	 ""  0  bad_file_name
test_check_star_name  foo$**	 ""  0  bad_file_name
test_check_star_name  **$bar	 ""  0  bad_file_name
test_check_star_name  **$**	 ""  0  bad_file_name

test_check_star_name  $	 ignore_entrypoint  0  0
test_check_star_name  $bar	 ignore_entrypoint  0  0
test_check_star_name  $**	 ignore_entrypoint  1  0
test_check_star_name  foo$	 ignore_entrypoint  0  0
test_check_star_name  **$	 ignore_entrypoint  1  0
test_check_star_name  foo$bar	 ignore_entrypoint  0  0
test_check_star_name  foo$**	 ignore_entrypoint  1  0
test_check_star_name  **$bar	 ignore_entrypoint  1  0
test_check_star_name  **$**	 ignore_entrypoint  1  0

test_check_star_name  $	 process_entrypoint  0  bad_file_name
test_check_star_name  $bar	 process_entrypoint  0  bad_file_name
test_check_star_name  $**	 process_entrypoint  0  bad_file_name
test_check_star_name  foo$	 process_entrypoint  0  0
test_check_star_name  **$	 process_entrypoint  1  0
test_check_star_name  foo$bar	 process_entrypoint  0  0
test_check_star_name  foo$**	 process_entrypoint  1  0
test_check_star_name  **$bar	 process_entrypoint  1  0
test_check_star_name  **$**	 process_entrypoint  1  0

test_check_star_name  |	 ""  0  bad_file_name
test_check_star_name  |bar	 ""  0  bad_file_name
test_check_star_name  |*	 ""  0  bad_file_name
test_check_star_name  foo|	 ""  0  bad_file_name
test_check_star_name  **|	 ""  0  bad_file_name
test_check_star_name  foo|bar	 ""  0  bad_file_name
test_check_star_name  foo|**	 ""  0  bad_file_name
test_check_star_name  **|bar	 ""  0  bad_file_name
test_check_star_name  **|**	 ""  0  bad_file_name

test_check_star_name  |	 ignore_entrypoint  0  0
test_check_star_name  |bar	 ignore_entrypoint  0  0
test_check_star_name  |**	 ignore_entrypoint  1  0
test_check_star_name  foo|	 ignore_entrypoint  0  0
test_check_star_name  **|	 ignore_entrypoint  1  0
test_check_star_name  foo|bar	 ignore_entrypoint  0  0
test_check_star_name  foo|**	 ignore_entrypoint  1  0
test_check_star_name  **|bar	 ignore_entrypoint  1  0
test_check_star_name  **|**	 ignore_entrypoint  1  0

test_check_star_name  |	 process_entrypoint  0  bad_file_name
test_check_star_name  |bar	 process_entrypoint  0  bad_file_name
test_check_star_name  |**	 process_entrypoint  0  bad_file_name
test_check_star_name  foo|	 process_entrypoint  0  0
test_check_star_name  **|	 process_entrypoint  1  0
test_check_star_name  foo|bar	 process_entrypoint  0  0
test_check_star_name  foo|**	 process_entrypoint  1  0
test_check_star_name  **|bar	 process_entrypoint  1  0
test_check_star_name  **|**	 process_entrypoint  1  0

test_check_star_name  =	""  0  badequal
test_check_star_name  =x	""  0  badequal
test_check_star_name  =*	""  0  badequal
test_check_star_name  x=	""  0  badequal
test_check_star_name  *=	""  0  badequal
test_check_star_name  x=x	""  0  badequal
test_check_star_name  *=*	""  0  badequal

test_check_star_name  =	ignore_equal  0  0
test_check_star_name  =x	ignore_equal  0  0
test_check_star_name  =*	ignore_equal  1  0
test_check_star_name  x=	ignore_equal  0  0
test_check_star_name  *=	ignore_equal  1  0
test_check_star_name  x=x	ignore_equal  0  0
test_check_star_name  *=*	ignore_equal  1  0

test_check_star_name  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   ""  0  entlong
test_check_star_name  **.**.**.**.**.**.**.**.**.**.**.*  ""  0  entlong

test_check_star_name  xxx	ignore_archive,process_archive  0  inconsistent
test_check_star_name  xxx	ignore_entrypoint,process_entrypoint  0  inconsistent
test_check_star_name  xxx	ignore_path,process_path  0  inconsistent

test_check_star_name  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx   ignore_length  0  0
test_check_star_name  **.**.**.**.**.**.**.**.**.**.**.*  ignore_length  2  0

test_check_star_name  [	""  0  invalid_ascii
test_check_star_name  [	ignore_nonascii  0  0
test_check_star_name  [>x	process_path  0  badpath
test_check_star_name  [>x	ignore_nonascii,process_path  0  0

test_check_star_name  ""		""  0  null_name_component
test_check_star_name  .		""  0  null_name_component
test_check_star_name  .foo		""  0  null_name_component
test_check_star_name  foo.		""  0  null_name_component
test_check_star_name  foo..bar	""  0  null_name_component
test_check_star_name  ""		ignore_null  0  0
test_check_star_name  .		ignore_null  0  0
test_check_star_name  .foo		ignore_null  0  0
test_check_star_name  foo.		ignore_null  0  0
test_check_star_name  foo..bar	ignore_null  0  0

test_check_star_name  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx    reject_wild  0  0
test_check_star_name  *.*.*.*.*.*.*.*.*.*.*.*	        reject_wild  1  nostars
test_check_star_name  **.**.**.**.**.**.**.**.**.**.*     reject_wild  2  nostars

test_check_star_name  xxx	unimplemented  0  bad_arg
