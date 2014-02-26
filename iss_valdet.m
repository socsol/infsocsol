
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
%% ISS_VALDET
% This function performs the value determination step of the policy
% improvement algorithm
function value=iss_valdet(UCell, DeltaFunction, StageReturnFunction, ...
                                StateLB, StateUB, Conf)
  
  %% Extract options
  Dimension = Conf.Dimension;
  States = Conf.States;
  TotalStates = Conf.TotalStates;
  CodingVector = Conf.CodingVector;
  DiscountFactor = Conf.DiscountFactor;
  Options = Conf.Options;
  
  StateStepSize = Options.StateStepSize;
  TimeStep = Options.TimeStep;

  % This will differ depending on whether system is stochasic or not.
  TransProbFn = Conf.TransProbFn;

  %% Create a cell array of states.
  StateCell = Conf.ArrayFn(@(StateNum) ...
                           SVecToSVars(SnToSVec(StateNum, ...
                                                CodingVector, ...
                                                Dimension), ...
                                       StateLB, ...
                                       Conf), ...
                           (1:TotalStates)', ...
                           'UniformOutput', false);
  
  %% Work out the scalar cost at each state.
  Return = Conf.CellFn(@(StateVars, U) ...
                       iss_cost_compute(StageReturnFunction, ...
                                        U, StateVars, ...
                                        TimeStep, Conf), ...
                       StateCell, UCell);
  
  %% Compute transition probabilities.
  % Each CellFn call returns a column.  We then combine the columns
  % to make a matrix.
  TransProb = cell2mat(Conf.CellFn(@(StateVars, U) ...
                                   TransProbFn(DeltaFunction, ...
                                               StateVars, U, ...
                                               StateLB, StateUB, Conf), ...
                                   StateCell, UCell, ...
                                   'UniformOutput', false));


  %% Solve the system to get the value.
  if Conf.UseSparse
    identity = speye(TotalStates);
  else
    identity = eye(TotalStates);
  end
  
  value=(identity-DiscountFactor*TransProb)\Return;
end
