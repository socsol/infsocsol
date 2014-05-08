%%
%  Copyright 2014 Jacek B. Krawczyk and Alastair Pharo
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
function ControlValues = iss_plot_contrule(ProblemFile, InitialCondition, varargin)

  %% Load settings from file.
  [DeltaFunction, StageReturnFunction, StateLB, StateUB, Conf] = ...
      iss_load_conf(ProblemFile);

  ODM = iss_load_solution(Conf);
  

  %% Augment configuration.
  Conf = iss_conf(StateLB, StateUB, Conf, varargin{:});


  %% Extract options
  VariableOfInterest = Conf.Options.VariableOfInterest;
  Dimension = Conf.Dimension;
  States = Conf.States;
  TotalStates = Conf.TotalStates;
  CodingVector = Conf.CodingVector;
  StateStepSize = Conf.Options.StateStepSize;
  ControlDimension = Conf.Options.ControlDimension;
  LineSpec = Conf.Options.LineSpec;

  %% Compute control profiles

  % Compute the State Number for the initial state modified by setting
  % the variable of interest to its minimum value. All the states of
  % interest are this base state plus some multiple of the variable of
  % interest's coding value.
  InitialCondition(VariableOfInterest)=StateLB(VariableOfInterest);
  if Conf.Options.Debug
    fprintf('Initial Condition: %12g\n', ...
            InitialCondition(VariableOfInterest));
  end
  BaseState=round((InitialCondition-StateLB)./StateStepSize)*...
            CodingVector'+1; %#ok<NASGU>

  % Compute the actual state variables corresponding to the states of
  % interest and compute the control profiles in these states.
  if Conf.Options.Debug
    fprintf('State Step:        %12g\n', ...
            StateStepSize(VariableOfInterest));
  end
  StateVect=StateLB(VariableOfInterest)+StateStepSize(VariableOfInterest) ...
            *(0:(States(VariableOfInterest)-1)); %#ok<NASGU>
  C = cell(1, ControlDimension);
  for i=1:ControlDimension
    C{i} = ODM{i}(BaseState+CodingVector(VariableOfInterest) .* (0: ...
                                                      (States(VariableOfInterest)-1)));
  end;

  
  %% Plot control profiles

  for i=1:ControlDimension
    subplot(ControlDimension,1,i);
    plot(StateVect,C{i},LineSpec);
    grid;
    ylabel(['u_',int2str(i)]);
    hold on;
  end; % for i=1:ControlDimension
  xlabel(['x_',int2str(VariableOfInterest)]);


  %% Return output

  if nargout==1
    ControlValues=zeros(length(StateVect),ControlDimension);
    for i=1:ControlDimension
      ControlValues(:,i) = C{i};
    end;
  end; % if nargout==1  
end
