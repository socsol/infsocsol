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
import infsocsol.helpers as helpers

@pytest.fixture(scope="module")
def matlab_engine():
    return helpers.matlab_engine()

@pytest.fixture(scope="module")
def octave_engine():
    return helpers.octave_engine()

@pytest.fixture(scope="module")
def engines(matlab_engine, octave_engine):
    return {
        'matlab': matlab_engine,
        'octave': octave_engine
    }

@pytest.fixture(scope="module", params=["matlab", "octave"])
def engine(engines, request):
    return engines[request.param]
