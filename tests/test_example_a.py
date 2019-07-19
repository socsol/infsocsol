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

@pytest.fixture(scope="module", params=[
    # engine    state_step time_step max_fun_evals tol_fun accuracy0 accuracy1 r_square
    ( 'matlab', 0.01,      0.02,     100,          1e-6,   0.01,     0.01,     0.999     ),
    ( 'matlab', 0.01,      0.02,     400,          1e-12,  2e-3,     5e-3,     0.9999    ),
    ( 'matlab', 0.001,     0.002,    400,          1e-12,  2e-4,     2e-3,     0.9999999 ),
    ( 'octave', 0.01,      0.02,     100,          1e-6,   0.1,      0.13,     0.67      ),
    ( 'octave', 0.01,      0.02,     400,          1e-12,  0.1,      0.13,     0.67      ),
])
def example_a_scenario(request):
    return request.param

def test_example_a(engines, example_a_scenario):
    _engine, state_step, time_step, max_fun_evals, tol_fun, accuracy0, accuracy1, r_square = example_a_scenario
    engine = engines[_engine]
    engine.cd(os.path.join(os.path.dirname(__file__), "example_a"))

    engine.iss_solve('delta', 'cost', 0 - state_step, 0.5 + state_step,
                     'StateStepSize', state_step,
                     'TimeStep', time_step,
                     'DiscountRate', 0.9,
                     'ProblemFile', 'example_a',
                     'MaxFunEvals', max_fun_evals,
                     'TolFun', tol_fun,
                     'PoolSize', 4,
                     nargout=0)

    controls = numpy.array(engine.iss_plot_contrule('example_a', 0.5))
    engine.close(nargout=0)
    x = numpy.hstack([numpy.arange(0 - state_step, 0.5 + state_step, state_step), [0.5 + state_step]])
    assert controls.ndim == 2
    assert controls.shape == (x.size, 1)

    slope, intercept, r_value, p_value, std_err = scipy.stats.linregress(x, controls.transpose())

    assert_allclose(
        intercept,
        0,
        atol=accuracy0)

    # This slope comes from a paper by Jacek
    assert_allclose(
        slope,
        -(-0.9 + numpy.sqrt(0.9**2 + 4)) / 2,
        atol=accuracy1)

    assert r_value**2 >= r_square
