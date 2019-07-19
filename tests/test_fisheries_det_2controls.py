# Copyright 2019 Alastair Pharo
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import pytest
import numpy
import os
import scipy
from numpy.testing import assert_allclose
from infsocsol.helpers import matrix

@pytest.fixture(scope="module", params=[
    # engine    states time_step start       steps  steady steady_accuracy optim_accuracy
    ( 'matlab', 10,    1,        (100, 0.5), 100,   True,  3e-6,           0.011 ),
    ( 'matlab', 20,    0.5,      (600, 0.6), 200,   True,  6e-9,           0.03  ),
    ( 'matlab', 40,    0.25,     (60, 0.1),  300,   True,  4e-7,           0.011 ),
    ( 'matlab', 10,    1,        (600, 1.0), 200,   False, 0.001,          None  ),
    ( 'octave', 10,    1,        (100, 0.5), 100,   True,  3e-6,           0.011 ),
    ( 'octave', 20,    0.5,      (600, 0.6), 200,   True,  6e-9,           0.03  )
])
def fisheries_scenario(request):
    return request.param

def test_fisheries_det_2controls(engines, fisheries_scenario):
    _engine, states, time_step, _start, steps, steady, steady_accuracy, optim_accuracy = fisheries_scenario
    engine = engines[_engine]
    start = matrix(engine, _start)
    engine.cd(os.path.join(os.path.dirname(__file__), "fisheries_det_2controls"))

    engine.solve(float(states), float(time_step), nargout=0)
    final = numpy.array(engine.sim_final(start, steps))

    # This is determined by setting x\dot = 0, which solves to 1 = b/L + q/r e
    steady_one = numpy.dot(final, [1/500, 5/4])

    if steady:
        assert_allclose(steady_one, 1, atol=steady_accuracy)

        # This is the most profitable steady state -- b = L/2 + c/2pq
        profit_max_steady = numpy.array([[252.5, 0.396]])
        assert_allclose(final, profit_max_steady, rtol=optim_accuracy)
    else:
        assert steady_one > 1 + steady_accuracy
