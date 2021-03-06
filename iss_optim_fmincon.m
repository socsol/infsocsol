
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
function [UOptimal, error] = iss_optim_fmincon(UStart, Value, StateVars, ...
                                               DeltaFunction, ...
                                               StageReturnFunction, ...
                                               StateLB, StateUB, Conf)

States = Conf.States;
StateStepSize = Conf.StateStepSize;
CodingVector = Conf.CodingVector;
DiscountFactor = Conf.DiscountFactor;
UserConstraintFunctionFile = Conf.UserConstraintFunctionFile;
UserConstraintFunction = Conf.UserConstraintFunction;
Options = Conf.Options;
FminconOptions = Conf.FminconOptions;
  
if Options.StochasticProblem
  [UOptimal, fval, flag] = fmincon('CostStoch',UStart,Options.A, ...
                                   Options.b,Options.Aeq,Options.beq, ...
                                   Options.ControlLB,Options.ControlUB, ...
                                   UserConstraintFunctionFile, ...
                                   FminconOptions, DeltaFunction, ...
                                   StageReturnFunction, ...
                                   UserConstraintFunction, ...
                                   StateLB, ...
                                   StateStepSize,Options.TimeStep, ...
                                   DiscountFactor,size(StateLB, ...
                                                    2), States, ...
                                   CodingVector,StateVars, Value,Conf, ...
                                   Options.Noise, Options.NoiseSteps, ...
                                   Options.NoiseProb, Options.NoisyVars);
else
  [UOptimal, fval, flag] = fmincon('CostDeter',UStart,Options.A, ...
                                   Options.b,Options.Aeq,Options.beq, ...
                                   Options.ControlLB,Options.ControlUB, ...
                                   UserConstraintFunctionFile, ...
                                   FminconOptions, ...
                                   DeltaFunction, ...
                                   StageReturnFunction, ...
                                   UserConstraintFunction, ...
                                   StateLB, ...
                                   StateStepSize,Options.TimeStep, ...
                                   DiscountFactor,size(StateLB, ...
                                                       2), States, ...
                                   CodingVector,StateVars, Value,Conf);
end

% Negative flags are counted as errors.
error = flag < 0 || isempty(fval); % flag > 2 || 