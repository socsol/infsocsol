
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
function [UOptimal, Flags] = iss_polimp(Value, DeltaFunction, ...
                                        StageReturnFunction, StateLB, ...
                                        StateUB, Conf)

  TotalStates = Conf.TotalStates;
  [UOptimal, Flags] = Conf.ArrayFn(@(StateNum) iss_polimp_each(StateNum, ...
                                                    Value, DeltaFunction, ...
                                                    StageReturnFunction, ...
                                                    StateLB, StateUB, ...
                                                    Conf), ...
                                   (1:TotalStates)', ...
                                   'UniformOutput', false);
end

function [UOptimal, Flags] = iss_polimp_each(StateNum, Value, DeltaFunction, ...
                                             StageReturnFunction, StateLB, ...
                                             StateUB, Conf)
  
  %% Extract relevant settings from Conf
  CodingVector = Conf.CodingVector;
  Dimension = Conf.Dimension;
  DiscountFactor = Conf.DiscountFactor;
  Optimizer = Conf.Optimizer;
  States = Conf.States;
  UserConstraintFunctionFile = Conf.UserConstraintFunctionFile;
  UserConstraintFunction = Conf.UserConstraintFunction;

  Options = Conf.Options;  
  StateVect=SnToSVec(StateNum,CodingVector,Dimension);
  StateVars=(StateVect-1).*Options.StateStepSize+StateLB;

  UStart = Options.ControlUB;

  % Check for infinite control values. Happens when there
  % are no control bounds.
  ub_idx = isinf(UStart);
  if any(ub_idx)
    UStart(ub_idx) = Options.ControlLB(ub_idx);
    lb_idx = isinf(UStart);
    
    % Happens when both bounds are inf.  Choose a random number.
    if any(lb_idx)
      UStart(lb_idx) = inv(Options.TimeStep)*10; %rand([1,length(lb_idx)]);
    end
  end

  [UOptimal, Flags] = ...
      Optimizer(UStart, Value, StateVars, DeltaFunction, ...
                StageReturnFunction, StateLB, StateUB, Conf);
end
