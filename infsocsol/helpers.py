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

import matlab.engine
import numpy
import oct2py
import os

# Adds the root of the project to the *lab path
def setroot(engine, root=None):
    engine.addpath(os.path.join(*[p for p in [os.path.dirname(os.path.dirname(__file__)), root] if p]))

# This enables engine-agnostic callbacks in the test code
class OctaveWithMatlabInterface:
    def __init__(self, engine):
        self.engine = engine

    def __getattr__(self, name):
        keymap = {
            'nargout': 'nout'
        }

        def _feval(*args, **kwargs):
            _kwargs = { keymap[k]: v for k, v in kwargs.items() if keymap[k] }
            return self.engine.feval(name, *args, **_kwargs)

        return _feval

def octave_engine(root=None):
    engine = oct2py.Oct2Py()
    setroot(engine, root)
    return OctaveWithMatlabInterface(engine)

def matlab_engine(root=None):
    engine = matlab.engine.start_matlab()
    setroot(engine, root)
    return engine

def matrix(engine, obj):
    if engine.__class__ == OctaveWithMatlabInterface:
        return numpy.array(obj)
    else:
        return matlab.double(obj)

