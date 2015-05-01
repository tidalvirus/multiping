multiping - ping multiple hosts in one terminal display

Basic at the moment.

Some feature ideas in my head at this time:

* statistics (regularly/at the end of the run)
* running tally of how long something has been timed out (useful for failover tests)
* Different output types - e.g. horizontal, and/or curses based - a bit like MTR

Example output:
```
aurora% ./multiping.pl gw dream  8.8.8.8
---------------------------------------------------------------------------
              gw           dream         8.8.8.8
---------------------------------------------------------------------------
         5.63 ms         3.83 ms        93.93 ms
         4.44 ms         4.40 ms        94.36 ms
         4.53 ms         3.85 ms        94.06 ms
         4.75 ms         3.88 ms        93.18 ms
         4.57 ms         3.79 ms        93.24 ms
         4.53 ms         4.12 ms        94.74 ms
         4.61 ms         3.91 ms        93.57 ms
         4.58 ms         3.80 ms        93.53 ms
         4.57 ms         3.81 ms        93.82 ms
^C
aurora%
```
