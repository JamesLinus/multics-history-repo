&  ***********************************************************
&  *                                                         *
&  * Copyright, (C) Honeywell Information Systems Inc., 1982 *
&  *                                                         *
&  ***********************************************************

& 
& 
&  HISTORY COMMENTS:
&   1) change(86-12-18,Fawcett), approve(86-12-18,PBF7517),
&      audit(86-12-18,GDixon), install(87-01-05,MR12.0-1257):
&      Remove BOS for MR12.0.
&                                                       END HISTORY COMMENTS
& 
& 
&
&  Modified 85 May 7 by Art Beattie to remove add_name commands that referenced
&    languages and network libraries.
&
&command_line off
link >system_library_tools>unbundled.object.control
link >system_library_tools>unbundled.control
link >system_library_tools>tools.object.control
link >system_library_tools>tools.control
link >system_library_tools>standard.object.control
link >system_library_tools>standard.control
link >system_library_tools>online_systems.object.control
link >system_library_tools>online_systems.control
link >system_library_tools>info_files.control
link >system_library_tools>include.control
link >system_library_tools>hardcore.control
link >system_library_tools>hardcore.object.control
link >system_library_tools>communications.object.control
link >system_library_tools>communications.control
add_name unbundled.object.control unb.o.control
add_name unbundled.control unb.control
add_name tools.object.control t.o.control
add_name tools.control t.control
add_name standard.object.control sss.o.control
add_name standard.control sss.control
add_name online_systems.object.control os.o.control
add_name online_systems.control os.control
add_name info_files.control info.control
add_name include.control incl.control
add_name hardcore.control hard.control h.control
add_name hardcore.object.control hard.o.control h.o.control
add_name communications.object.control com.o.control
add_name communications.control com.control
&quit
