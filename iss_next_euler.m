
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
%% Uses the Euler method to compute the next state
function [next, delta] = iss_next_euler(DeltaFunction, StateVars, U, ...
                                        TimeStep, NoiseRealization, Conf)

  %% Compute delta
  delta=TimeStep*feval(DeltaFunction,U,StateVars,1);

  %% Compute next state
  next = StateVars + delta;
end