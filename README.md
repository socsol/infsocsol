InfSOCSol
=========

A suite of MATLAB routines devised to provide an approximately optimal
solution to an infinite-horizon stochastic optimal control problem.
Its routines implement a policy improvement algorithm to optimise a
Markov decision chain approximating the original control problem.


## Version 3

The latest version of InfSOCSol is 3.0.1.  You can
[download a zip file here][v3].  Alternatively, if you are
interested in testing the latest alterations to the codebase,
[you can download a zip file of the most recent bleeding-edge changes here][latest].

Any issues can be reported to the authors via email, or you can
[lodge an error report in GitHub][issues].

[v3]: https://github.com/socsol/infsocsol/archive/v3.0.1.zip
[latest]: https://github.com/socsol/infsocsol/zipball/master
[issues]: https://github.com/socsol/infsocsol/issues/new

## The manual

Download the InfSOCSol manual in PDF format [here][manual].

[manual]: https://socsol.github.io/infsocsol/ISSManual.pdf


## Testing

Please note that you don't need to worry about any of this unless you
are interested in developing or correcting bugs in InfSOCSol.

InfSOCSol uses [Python][python] for testing.  This works by taking advantage of
[the MATLAB Engine API for Python][matlabpy] to launch and control MATLAB from
Python, and similar support for Octave, provided by the [Oct2Py][oct2py]
package.  Tests have been written to run on both MATLAB and Octave, so you need
both to be installed in order to be able to run the tests.

To get started with testing, you
need to install Python 3 and a number of packages, including
[pytest][pytest] the [SciPy][scipy] 
suite of packages.  The best installation method differs across systems.  If
you are using [pip][pip], you should be able to install most
dependencies (MATLAB engine excepted) by executing the following command from
the InfSOCSol folder:

~~~
pip3 install -e . --user
~~~

The following links provide some more info on installing the various Python
packages required:

- For the MATLAB Engine API for Python, check out [the instructions
  provided by
  MathWorks](https://mathworks.com/help/matlab/matlab_external/install-the-matlab-engine-for-python.html).
- For Oct2Py, check out [their installation
  instructions](http://blink1073.github.io/oct2py/source/installation.html).
- Check [the SciPy website](https://www.scipy.org/install.html) for more
  information on installing SciPy.
- Check [the pytest
  website](https://pytest.readthedocs.io/en/latest/getting-started.html) for
  instructions on installing pytest.

Assuming that you have installed everything, you are ready to run the tests.
These are divided into two categories:

1. Tests to check that InfSOCSol is producing correct results.  These
   tests are written as unit tests using `pytest`.
2. Tests to check the performance characteristics of InfSOCSol.  These tests
   use Python's built-in `timeit` library.

[python]: https://www.python.org/
[matlabpy]: https://mathworks.com/help/matlab/matlab_external/get-started-with-matlab-engine-for-python.html
[oct2py]: http://blink1073.github.io/oct2py/
[pytest]: https://pytest.readthedocs.io/
[scipy]: https://scipy.org/
[pip]: https://pip.pypa.io/en/stable/

### Running unit tests

Assuming you have installed all the necessary software, as described above,
where you have the InfSOCSol code and type `python3 -m pytest`.  This will run
the tests, and print out any warnings or errors.

These tests are all contained in the `tests/test_*.py` files.


### Running the speed tests

The speed tests run `iss_solve` over problems of various sizes in
order to check:

1. whether performance meets or exceeds that of InfSOCSol version 2 ([see
   here][v2]); and
2. whether the overall time taken remains proportional to the number
   of states and CPUs.

Currently speed tests can be run on two different problems:

- `profile_example_a` will run speed tests on the "simple example"
  outlined in Appendix A of the manual.
- `profile_fisheries_det_basic` will run speed tests on the fisheries
  example from Appendix B of the manual.

These are both written as functions in the `tests/profile.py` file, and they
both take a single parameter, which gives the distribution of state sizes that
the speed tests should be run on.  For example, `profile_example_a([51, 101,
151, 201])` will run the "simple example" problem with a state space of 51
states, then again with 101 states, etc.  For each state space size, the
problem will be run in the following environments:

+ on InfSOCSol2, using MATLAB;
+ on the current version, with:
  - Octave and MATLAB with:
    * 1 CPU; and
    * as many CPUs as are present on the machine.

Thus for every state space size, there are 5 different test environments.  Thus
for the above example where four different state space sizes were given,
InfSOCSol is run a total of 20 times.  As such, you may find it takes a
while to complete.

The advised way to run these speed tests is in an
[IPython](ipython) or [Jupyter](jupyter) interactive session:

~~~
$ ipython
Python 3.7.3 (default, Jun 24 2019, 04:54:02) 
Type 'copyright', 'credits' or 'license' for more information
IPython 7.5.0 -- An enhanced Interactive Python. Type '?' for help.

In [1]: from tests.profile import *                                                                                                                                                                                                                                            

In [2]: results = profile_example_a(range(51, 651, 150)) # = [51, 201, ... 501]
~~~

Eventually the above should return a [Pandas][pandas] `DataFrame` table
containing the results.  The columns give the combination of factors which
determine the InfSOCSol environment:

 - **platform**: The platform that the speed test ran on.  Either
  "matlab" or "octave".

 - **version**: The version of InfSOCSol that was used "v2" indicates
  that the previous version of the code was used .
  "current" indicates the version in the current working directory.

 - **cpus**: The number of concurrent processes used (see Section 8 of
  the manual).

Each row of the table represents a state size, and each cell gives the time in
seconds that `iss_solve` took to execute.  Output should look like the
following example:

~~~
In [3]: results                                                                                                                       
Out[3]: 
version     current                                            v2
platform     matlab                 octave                 matlab
cpus              1          4           1           4          1
states                                                           
51        10.181718  15.393319  162.370778   90.659581  12.918385
201       30.418551  38.674121  156.371318   74.482835  53.305833
351       57.859271  70.279733  319.268827  156.313141  84.332884
~~~

The fisheries speed test can be run in a similar way. However, because the
fisheries example is two-dimensional, the list of states provided to the
function is used to give the number of states *in each dimension*.  For example,
`profile_fisheries_det_basic([10, 20, 30, 40])` will run `iss_solve` with state
spaces of 100 states, 400 states, etc.  This in turn means that one should
expect the time results to be proportional to the square of the number of
states shown in the resulting dataset, as this will be the actual number of
states considered.

[v2]: https://github.com/socsol/infsocsol/tree/v2
[ipython]: http://ipython.org/
[jupyter]: https://jupyter.org/


### Visualising the speed test data

You should be able to use the [`.plot()`
method](https://pandas.pydata.org/pandas-docs/stable/user_guide/visualization.html)
to plot graphs of the datasets produced by the speed tests.  Presuming the
table has been stored in the `results` variable (as in the above example), you
should be able to type `results.plot()` to see a line graph.


## See also

### VIKAASA

**Vi**abaility **K**ernel **A**pproximation, **A**nalysis and
**S**imulation **A**pplication.  This is a MATLAB/Octave program which
uses InfSOCSol under the hood to produce viability kernels.

Find out more about VIKAASA at its [GitHub page][vikaasa].

[vikaasa]: https://github.com/socsol/vikaasa


## Authors

 - [Jacek B. Krawczyk](mailto:jacek.krawczyk@flinders.edu.au)
 - [Alastair Pharo](https://asph.dev/)


## License

Copyright 2019 Jacek B. Krawczyk and Alastair Pharo.  Distributed
under [the Apache License, Version 2.0][apache].

[apache]: http://www.apache.org/licenses/LICENSE-2.0
