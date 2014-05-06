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
function SimulatedValue = iss_plot_sim(ProblemFile, InitialCondition, varargin)

  %% Load settings from file.
  [DeltaFunction, StageReturnFunction, StateLB, StateUB, Conf] = ...
      iss_load_conf(ProblemFile);

  ODM = iss_load_solution(Conf);
  

  %% Augment configuration.
  Conf = iss_conf(StateLB, StateUB, Conf, varargin{:});


  %% Run iss_sim
  [SimulatedValue, StateEvolution, DeltaEvolution, Control] = ...
      iss_sim(InitialCondition, ODM, ...
              DeltaFunction, StageReturnFunction, ...
              StateLB, StateUB, Conf);

  
  %% Plot trajectories

  % These features came from the old code, but I don't think they work.
  VariableMin = 0;
  VariableMax = 0;
  VariableStateStep = 0;

  % These are extracted from the config
  Dimension = Conf.Dimension;
  Time=Conf.Time;
  SimTime=Conf.SimTime;
  ControlTime=Conf.ControlTime;
  ControlDimension = Conf.Options.ControlDimension;
  LineSpec = Conf.Options.LineSpec;
  TimepathOfInterest = Conf.Options.TimepathOfInterest;

  % Plot variable state bounds, if any.
  hold on;
  for i=1:Dimension
    subplot(Dimension+ControlDimension,1,i);
    if VariableMin
      plot([0,Time],StateLB(:,i),'k');
    end
    hold on;
    if VariableMax
      plot([0,Time],StateUB(:,i),'k');
    end
    ylabel(['x',int2str(i)]);
  end; % for i=1:Dimension

  for i = 1:length(StateEvolution)
    PlotTraj(Dimension,ControlDimension,VariableMin,VariableMax,...
             Time,StateLB,StateUB,SimTime,ControlTime,StateEvolution{i},...
             Control{i},LineSpec,TimepathOfInterest);
  end
end
