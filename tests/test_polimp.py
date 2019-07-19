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
from numpy.testing import assert_array_equal
import os

@pytest.fixture(scope="module", params=[
    # state_step time_step max_fun_evals tol_fun file
    ( 0.01,      0.02,     400,          1e-12,  'example_a51_policies.mat'  ),
    ( 0.001,     0.002,    400,          1e-12,  'example_a501_policies.mat' )
])
def polimp_scenario(request):
    return request.param

# Setup: load the policy data from ISS2 (stored in .mat files) and run the ISS3
# policy improvement algorithm bootstrapped so that it produces the same
# results as in ISS2.
def test_polimp(matlab_engine, polimp_scenario):
    state_step, time_step, max_fun_evals, tol_fun, file = polimp_scenario
    engine = matlab_engine
    engine.cd(os.path.join(os.path.dirname(__file__), "example_a_polimp"))
    data = engine.load(file)
    policies = numpy.array(data['Policies'])
    result = engine.check_polimp(state_step, time_step, max_fun_evals, tol_fun)
    assert_array_equal(numpy.array(result), policies)
