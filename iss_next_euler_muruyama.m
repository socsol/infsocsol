
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
%% Uses the Euler-Muruyama method to compute the next state
function [next, delta] = iss_next_euler_muruyama(DeltaFunction, StateVars, ...
                                                 U, TimeStep, NoiseRealization, Conf)
  
  %% Extract options
  Dimension=Conf.Dimension;
  NoisyVars = Conf.Options.NoisyVars;
  
  %% Compute delta
  Delta=feval(DeltaFunction,U,StateVars,1);
  DeltaDeter=Delta(1:Dimension)*TimeStep;
  DeltaStoch=Delta(Dimension+1:Dimension+NoisyVars)*sqrt(TimeStep);

  %% Compute next state
  delta = DeltaDeter + DeltaStoch.*NoiseRealization;
  next = StateVars + delta;  
end