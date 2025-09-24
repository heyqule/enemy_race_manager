### UAT TESTS

The following steps are required to pass before this mod and its race mod is ready to publish.

- Run test suite to make sure mandatory tests passes.
- Create a new freeplay game without crash.
- Create a new general debug game, using 4 race split, set Gamespeed to 1000, start artillery and wait for 10 mins to
  check other crashes.
- Load an existing non-ERM game with ERM mods without crash.
- Load an existing ERM game without crash.
- Check whether GetRaceSettings data are up to date.
    - /c remote.call('enemyracemanager_debug', 'print_global')
    - Check the data in script-output/enemyracemanager/erm-global.json

