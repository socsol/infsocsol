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

from timeit import timeit
from infsocsol.helpers import matlab_engine, octave_engine
import os

engines = {}
def engine_for(platform, root=None):
    global engines

    constructors = {
        'matlab': matlab_engine,
        'octave': octave_engine
    }

    key = f'{platform}+{root}' if root else platform
    if key not in engines:
        engines[key] = constructors[platform](root)

    return engines[key]

iterations = 0
def example_a_current(platform, cpus, states):
    global iterations
    engine = engine_for(platform)
    engine.cd(os.path.join(os.path.dirname(os.path.realpath(__file__)), "example_a_speed"))
    iterations = int(engine.solve_current(cpus, float(states)))

def example_a_v2(states):
    engine = engine_for('matlab', 'v2')
    engine.cd(os.path.join(os.path.dirname(os.path.realpath(__file__)), "example_a_speed"))
    engine.solve_v2(float(states))

def fisheries_det_basic_current(platform, cpus, states, time_step):
    global iterations
    engine = engine_for(platform)
    engine.cd(os.path.join(os.path.dirname(os.path.realpath(__file__)), "fisheries_det_basic_speed"))
    iterations = int(engine.solve_current(cpus, states, time_step))

def fisheries_det_basic_v2(states, time_step):
    engine = engine_for('matlab', 'v2')
    engine.cd(os.path.join(os.path.dirname(os.path.realpath(__file__)), "fisheries_det_basic_speed"))
    engine.solve_v2(states, time_step)

def run_profile(rec, stmt):
    """
    run
    """
    global iterations
    iterations = None
    time = timeit(stmt=stmt, number=1, globals=globals())
    rec['time'] = time
    rec['iterations'] = iterations
    return rec

def profile_example_a(samples, max_cpus):
    """
    Profiling of example A
    """
    results = []
    for i in range(0, samples):
        states = 51 + 150*i

        # Run the ISS2 code on MATLAB
        results.append(run_profile({
            'platform': 'matlab',
            'cpus': 1,
            'version': 'v2',
            'states': states
        }, f'example_a_v2({states})'))

        for platform in ['matlab', 'octave']:
            for cpus in range(1, max_cpus+1):
                results.append(run_profile({
                    'platform': platform,
                    'cpus': cpus,
                    'version': 'current',
                    'states': states
                }, f'example_a_current("{platform}", {cpus}, {states})'))

    return results

if __name__ == '__main__':
    results = profile_example_a(4, 4)
    import pandas as pd
    print(pd.DataFrame(results))
