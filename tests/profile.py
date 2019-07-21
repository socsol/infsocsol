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
import pandas as pd
import os

engines = {}
def engine_for(rec):
    global engines

    constructors = {
        'matlab': matlab_engine,
        'octave': octave_engine
    }

    platform = rec['platform']
    root = None if rec['version'] == 'current' else rec['version']
    key = f'{platform}+{root}' if root else platform
    if key not in engines:
        engines[key] = constructors[platform](root)

    return engines[key]

def cd(engine, path):
    engine.cd(os.path.join(os.path.dirname(os.path.realpath(__file__)), path))

def example_a_current(engine, rec):
    cd(engine, "example_a_speed")
    engine.solve_current(rec['cpus'], float(rec['states']))

def example_a_v2(engine, rec):
    cd(engine, "example_a_speed")
    engine.solve_v2(float(rec['states']))

def fisheries_det_basic_current(engine, rec):
    cd(engine, "fisheries_det_basic_speed")
    engine.solve_current(rec['cpus'], float(rec['states']), float(rec['time_step']))

def fisheries_det_basic_v2(engine, rec):
    cd(engine, "fisheries_det_basic_speed")
    engine.solve_v2(float(rec['states']), float(rec['time_step']))

def run_profile(fn, rec):
    """
    Profile the calling of the function with the argument
    """

    engine = engine_for(rec)

    # Start the matlab worker pool before profiling
    use_pool = rec['platform'] == 'matlab' and rec['cpus'] > 1
    if use_pool:
        handle = engine.iss_pool_start(rec['cpus'])
    time = timeit(stmt="fn(engine, rec)", number=3, globals={ 'fn': fn, 'engine': engine, 'rec': rec })
    if use_pool:
        engine.iss_pool_stop(handle)

    ret = {'time': time}
    ret.update(rec)

    return ret

def profile_example_a(samples):
    """
    Profiling of example A
    """
    results = []
    for i in range(0, samples):
        states = 51 + 150*i

        # Run the ISS2 code on MATLAB
        results.append(run_profile(example_a_v2, {
            'platform': 'matlab',
            'cpus': 1,
            'version': 'v2',
            'states': states
        }))

        for platform in ['matlab', 'octave']:
            for cpus in range(1, os.cpu_count() + 1):
                results.append(run_profile(example_a_current, {
                    'platform': platform,
                    'cpus': cpus,
                    'version': 'current',
                    'states': states
                }))

    return pd.DataFrame(results).pivot_table(
        index='states',
        columns=['version', 'platform', 'cpus'],
        values='time'
    )

def profile_fisheries_det_basic(samples):
    """
    Profiling of deterministic fisheries model
    """
    results = []
    for i in range(0, samples):
        states = 2**i * 10
        time_step = 2**-i

        # Run the ISS2 code on MATLAB
        results.append(run_profile(fisheries_det_basic_v2, {
            'platform': 'matlab',
            'cpus': 1,
            'version': 'v2',
            'states': states,
            'time_step': time_step
        }))

        for platform in ['matlab', 'octave']:
            for cpus in range(1, os.cpu_count() + 1):
                results.append(run_profile(fisheries_det_basic_current, {
                    'platform': platform,
                    'cpus': cpus,
                    'version': 'current',
                    'states': states,
                    'time_step': time_step
                }))

    return pd.DataFrame(results).pivot_table(
        index=['states', 'time_step'],
        columns=['version', 'platform', 'cpus'],
        values='time'
    )
