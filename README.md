# Multics History Repository

This repository is intended as a convenient way of browsing the revision
history of the [Multics](http://multicians.org/) operating system.
It's generated from a subset of the source files in several releases of
Multics, with the *history comments* in the files automatically
converted to individual Git commits.

It includes the following releases:

* The MR12.6 series is actively maintained by the developers of the
  [dps8m project](https://sourceforge.net/projects/dps8m/); they also
  provide an emulator capable of running Multics on modern machines.
  (These releases are available on the `master` branch.)

* Bull HN and MIT released Multics under a BSD-style license in 2007;
  see the [Multics History](http://web.mit.edu/multics-history/) site
  and COPYING. The version they released is based on MR12.5 with some
  additional bug fixes -- in particular, to repair various Y2K problems.
  (This release is available on the `mit` branch.)

* Release tapes for MR12.3, MR12.4 and MR12.5, collected by the Computer
  History Museum, were imaged by Al Kossow and are available from
  [Bitsavers](http://bitsavers.org/bits/Honeywell/multics/).
  MR12.4 is missing its source tapes, but I've reconstructed nearly all
  of the corresponding changesets in this repository.
  (Both branches start with these releases.)

If you're aware of any more surviving Multics source versions, please
let me know so I can integrate them into this repository.

You should expect this repository to be rebased when the extraction
process is improved; please don't rely on commit IDs being stable.

This project was inspired by Diomidis Spinellis'
[Unix History Repo](https://github.com/dspinellis/unix-history-repo).

-- Adam Sampson (<ats@offog.org>)
