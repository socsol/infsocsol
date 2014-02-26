
%%
%  Copyright 2013 Jacek B. Krawczyk and Alastair Pharo
%
%  Licensed under the Apache License, Version 2.0 (the "License");
%  you may not use this file except in compliance with the License.
%  You may obtain a copy of the License at
%
%      http://www.apache.org/licenses/LICENSE-2.0
%
%  Unless required by applicable law or agreed to in writing, software
%  distributed under the License is distributed on an "AS IS" BASIS,
%  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%  See the License for the specific language governing permissions and
%  limitations under the License.
function [SimulatedValue, StateEvolution, DeltaEvolution, Control] = ...
        iss_sim(InitialCondition, ODM, DeltaFunction, StageReturnFunction, ...
                Minimum, Maximum, varargin)

  %% Construct options
  Conf = iss_conf(Minimum, Maximum, varargin{:});

  SimulationTimeStep = Conf.Options.SimulationTimeStep;
  NumberOfSimulations = Conf.Options.NumberOfSimulations;

  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %%%                 MAIN LOOP                  %%%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %% We use the array fn to compute the trajectories in parallel
  % However, every run is identical, due to the only difference
  % being the random numbers produced.  Hence, the function f makes
  % no use of i.
  f = @(i) iss_sim_individual(InitialCondition, ODM, DeltaFunction, ...
                              StageReturnFunction, Minimum, Maximum, Conf);

  [SimulatedValue, StateEvolution, DeltaEvolution, Control] = ...
      Conf.ArrayFn(f, 1:NumberOfSimulations, ...
                   'UniformOutput', false);
end