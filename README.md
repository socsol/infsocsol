InfSOCSol3
==========

A suite of MATLAB routines devised to provide an approximately optimal
solution to an infinite-horizon stochastic optimal control problem.
Its routines implement a policy improvement algorithm to optimise a
Markov decision chain approximating the original control problem.


## Work in progress

InfSOCSol is currently a work in progress and may not produce accurate
results.  If you want to test the software you can
[download a zip file of the latest revision][latest]
or checkout the code using git.

Any issues can be reported to the authors via email, or you can
[lodge an error report in GitHub][issues].

[latest]: https://github.com/socsol/infsocsol/zipball/master
[issues]: https://github.com/socsol/infsocsol/issues/new

## The manual

Download the InfSOCSol manual in PDF format [here][manual].

[manual]: https://socsol.github.io/infsocsol/ISSManual.pdf


## Testing

InfSOCSol uses [Clojure][clj] and [cljlab][cljlab] for testing.  There
are two different sets of tests:

 1. Tests to check that InfSOCSol is producing correct results.  These
    tests are written using [midje][mdj].

 2. Tests to check the performance of InfSOCSol.  These tests use
    [thunknyc/profile][prof] for
    profiling and [Incanter][inc] for visualising the results.

[clj]: http://clojure.org/
[mdj]: https://github.com/marick/Midje
[inc]: http://incanter.org/
[prof]: https://github.com/thunknyc/profile/
[cljlab]: https://clojars.org/cljlab/


### Setting up Clojure

It is recommended to use Leiningen.  See http://leiningen.org/
for details on how to install it.


### Running correctness tests

Assuming Leiningen is set up, you only need to navigate to a folder
where you have the InfSOCSol code and type `lein test`.  Leiningen
will then handle dependencies and run the test suite.

It is important to note that the test suite expects both MATLAB and
Octave to be installed and present in the system path.  Otherwise you
will see a lot of failed tests.

If you are only interested in a particular platform, you can edit the
test cases.  They can be foun in `test/infsocsol/core.clj`.  As
mentioned, the tests use Midje, which is a clojure-based DSL
(domain-specific language) for writing test cases.  Currently the
tests consist of running various versions of the example problems
outlined in the manual.


### Running the speed tests

The speed tests run `iss_solve` over problems of various sizes in
order to check:

 1. whether performance matches that of InfSOCSol2
 2. whether the number of iterations needed to find a solution stays
    steady as the problem size increases
 3. whether the overall time taken remains proportional to the number
    of states.

Currently speed tests can be run on two different problems:

 - `profile-example-a` will run speed tests on the "simple example"
   outlined in Appendix A of the manual.

 - `profile-fisheries-det-basic` will run speed tests on the fisheries
   example from Appendix B of the manual.

The way to run the speed tests is to launch a Clojure REPL (i.e. an
interactive session).  Using Leiningen this can be done by typing
`lein repl` after navigating to the folder containing InfSOCSol.  From
the `=>` prompt, type the following to run a speed test:

~~~ clojure
=> (use 'infsocsol.speed-test) ;; Load the speed tests.
=> (profile-example-a 3 4)     ;; Run the tests  (3 samples; 4 CPUs).
=> (def results *1)            ;; Store the results to a variable.
~~~

The first parameter to `profile-example-a` is the number of `States`
samples to take from the sequence [51, 201, 351 ...].  The second
parameter gives the number of CPUs on the machine running the tests.
The return value is an Incanter dataset (i.e. a table).  An example of
the output produced is given in the following table:

| :platform | :version | :cpus | :states | :iterations |         :time |
|-----------+----------+-------+---------+-------------+---------------|
|   :matlab |      :v2 |     1 |      51 |           7 |   5.207104145 |
|   :matlab | :current |     1 |      51 |           6 |   3.907713917 |
|   :matlab | :current |     2 |      51 |           6 |  12.419206545 |
|   :octave | :current |     1 |      51 |           6 |  13.071235641 |
|   :octave | :current |     2 |      51 |           6 |    7.17819733 |
|   :matlab |      :v2 |     1 |     201 |          11 |  28.034113868 |
|   :matlab | :current |     1 |     201 |           6 |  13.927962437 |
|   :matlab | :current |     2 |     201 |           6 |  15.810110641 |
|   :octave | :current |     1 |     201 |           6 |  51.030606245 |
|   :octave | :current |     2 |     201 |           6 |  27.106062606 |
|   :matlab |      :v2 |     1 |     351 |          10 |  46.797340215 |
|   :matlab | :current |     1 |     351 |           7 |  28.704807972 |
|   :matlab | :current |     2 |     351 |           7 |  24.197437885 |
|   :octave | :current |     1 |     351 |           7 | 104.151060712 |
|   :octave | :current |     2 |     351 |           7 |  54.457939861 |

The columns are:

Platform
: The platform that the speed test ran on.  Either "matlab" or
  "octave".

Version
: The version of InfSOCSol that was used "v2" indicates that the
  previous version of the code was used ([see here][v2]).  "current"
  indicates the version in the current working directory.

CPUs
: The number of concurrent processes used (see Section 8 of the
  manual).

States
: The number of state-space points considered (see Section 2.2.2 of
  the manual).

Iterations
: The number of iteratons needed by `iss_solve` in order to converge
  on a solution.  This is described in Section 3 of the manual.  Note
  that these speed tests use the default setting of for
  `PolicyIterations` (25).  Hence, if 25 iterations are seen anywhere
  in the results, this most likely indicates that convergence did not
  occur.

Time
: The number of seconds taken for `iss_solve` to finish.  It is
  expected that this number will be proportional to the number of CPUs
  used, and the number of states.  Note however the caveats concerning
  MATLAB pool startup times, mentioned in Section 8 of the manual.

You can use [functions from Incanter][inc-api] to produce additional
columns (e.g. time per iteration).

Running `profile-fisheries-det-basic` can be done in the same way
using the REPL, e.g.

~~~ clojure
=> (use 'infsocsol.speed-test)       ;; Load the speed tests.
=> (profile-fisheries-det-basic 3 4) ;; Run the tests (3 samples; 4 CPUs).
=> (def fisheries-results *1)        ;; Store the results to a variable.
~~~

The only difference is that the fisheries example is two-dimensional,
and the second parameter specifies the number of states from the
sequence [10, 20, 40, ...] *in each dimension*.  This means that the
time results should be proportional to the square of the number of
states shown in the dataset, as this will be the actual number of
states considered.

[v2]: https://github.com/socsol/infsocsol/tree/v2
[inc-api]: http://liebke.github.io/incanter/core-api.html


### Visualising the speed test data

You can use Incanter to plot some line graphs of the datasets produced
by the speed tests.  From the REPL type:

~~~ clojure
=> (use 'infsocsol.speed-test) ;; Load the speed tests.
=> (use 'incanter.core) ;; Load Incanter functions.
;;
;; ... run speed tests and store the dataset in the "results" variable ...
;;
=> (view (plot-profiles :states :time results)) ;; states vs. time
=> (view (plot-profiles :time :iterations results)) ;; time vs. iterations
~~~


## See also

### VIKAASA

**Vi**abaility **K**ernel **A**pproximation, **A**nalysis and
**S**imulation **A**pplication.  This is a MATLAB/Octave program which
uses InfSOCSol under the hood to produce viability kernels.  Find
out more about VIKAASA at its [Google Code page][vikaasa].

[vikaasa]: https://code.google.com/p/vikaasa/


## Authors

Jacek B. Krawczyk
: Faculty of Commerce and Administration, Victoria University of
  Wellington, PO Box 600, Wellington, New Zealand.

: **Fax:** +64-4-4635014  
  **Email:** J *dot* Krawczyk *at* vuw *dot* ac *dot* nz  
  **Webpage:** [http://www.vuw.ac.nz/staff/jacek_krawczyk](http://www.vuw.ac.nz/staff/jacek_krawczyk)

[Alastair S. Pharo](https://github.com/asppsa)
: **Email:** alastair *dot* pharo *at* gmail *dot* com


## License

Copyright 2014 Jacek B. Krawczyk and Alastair Pharo.  Distributed
under [the Apache License, Version 2.0][apache].

[apache]: http://www.apache.org/licenses/LICENSE-2.0
