& create three directories with access, s *.*.*
cd >sc1>prelink_dir_dir
an >sc1>prelink_dir_dir  pldd
sa >sc1>pldd s *.*.*
cd >sc1>pldd>dfast
sa >sc1>pldd>dfast  s *.*.*
cd >sc1>pldd>fast
sa >sc1>pldd>fast s *.*.*

& setup links for DFAST
link >tools>dfast.pldt >sc1>pldd>dfast>pldt

& setup links for FAST
link >tools>fast.pldt >sc1>pldd>fast>pldt
