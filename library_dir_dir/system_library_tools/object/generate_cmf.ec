& exec_com to convert "lines" file into Channel Master File
&
&input_line off
&command_line off
&attach
qedx
r &1
w CMF
1,$s/^/-/
1,$s|^-\c*.*$|/* & */|
1,$s/-\c*//
1,$s/^-$//
1,$s|^/\c*  \c*/||
1,$s/^-.*$/& x/
1,$s//&";/
1,$s/^-.*	/&!/
1,$s/	!/ /
1,$s/^-.* /&; comment: "/
1,$s/^-/name: /
$a
end;
\f
1i
/* Channel Master File generated from the "lines" file */
\f
1,$s/ comment: "x";//
1,$s/ x";$/";/
1,$s/ ;/;/
1,$s/name: net...;/& line_type: Network; charge: network;/
1,$s/^name: caa...;/& charge: caa;/
w
q
& end
