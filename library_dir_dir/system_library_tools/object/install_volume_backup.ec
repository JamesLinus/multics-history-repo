& Modified August 1981 by F. W. Martinson for MR9.0
& ec to install changes of directory structure and file
& organization for new MR9 volume backup subsystem
&command_line off
&if [equal [user name] Volume_Dumper] &then &else &goto err1
&if  [not [exists dir >daemon_dir_dir>volume_retriever]] &then  goto err
cd >daemon_dir_dir>volume_backup
cd >daemon_dir_dir>volume_backup>contents
cd >daemon_dir_dir>volume_backup>pvolog
sis >daemon_dir_dir>volume_backup rew *.SysDaemon rew *.Daemon rew *.SysAdmin rew *.SysMaint
sis >daemon_dir_dir>volume_backup>contents rew *.SysDaemon rew *.Daemon rew *.SysAdmin rew *.SysMaint
sis >daemon_dir_dir>volume_backup>pvolog rew *.SysDaemon rew *.Daemon rew *.SysAdmin rew *.SysMaint
mv *.contents >daemon_dir_dir>volume_backup>contents>==
mv *.pvolog >daemon_dir_dir>volume_backup>pvolog>==
mv *.volog >daemon_dir_dir>volume_backup>==
mv *.volumes >daemon_dir_dir>volume_backup>==
&quit
&label err
&print ">daemon_dir_dir>volume_retriever" does not exist"
&quit
&label err1
&print This exec_com must be executed by Volume_Dumper personid
&print from the Volume_Dumper home_dir.
&quit
