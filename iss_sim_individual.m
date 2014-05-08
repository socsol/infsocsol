
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
function [SimulatedValue, StateEvolution, DeltaEvolution, Control] = ...
        iss_sim_individual(InitialCondition, ODM, DeltaFunction, StageReturnFunction, ...
                           Minimum, Maximum, varargin)

  %% Construct options
  Conf = iss_conf(Minimum, Maximum, varargin{:});

  SimulationTimeStep = Conf.Options.SimulationTimeStep;
  TotalSimulationStages=Conf.TotalSimulationStages;
  ControlDimension=Conf.Options.ControlDimension;
  Dimension=Conf.Dimension;
  SimTime=Conf.SimTime;

  NextFn = Conf.NextFn;
  SimNoiseFn = Conf.SimNoiseFn;
  
  %% Predefine empty holders 
  %   to speed execution and improve memory management.
  Control=zeros(TotalSimulationStages,ControlDimension);
  
  StateEvolution=zeros(TotalSimulationStages+1,Dimension);
  DeltaEvolution=zeros(TotalSimulationStages,Dimension);
  

  %% Compute trajectory

  % Initialise State
  StateVars = InitialCondition;
  SimulatedValue = 0;
  
  % For each stage in turn.
  for SimulationStage=1:TotalSimulationStages
    % Compute the control choice using the ODM
    U = iss_odm_control(ODM, StateVars, Minimum, Maximum, Conf);

    % Record the state and control for this simulation stage.
    StateEvolution(SimulationStage,:)=StateVars; 

    Control(SimulationStage,:)=U;
    DiscountFactor=Dis(Conf.Options.DiscountRate,SimTime(SimulationStage));
    SimulatedValue=SimulatedValue+ ...
        iss_cost_compute(StageReturnFunction,U,StateVars, ...
                         SimulationTimeStep(SimulationStage), Conf) ...
        * DiscountFactor;
    
    % Use an approximating function (Euler or Euler-Muruyama) to get the
    % next state
    [StateVars, Delta] = NextFn(DeltaFunction, StateVars, U, ...
                                SimulationTimeStep(SimulationStage), ...
                                SimNoiseFn(SimulationStage, Conf), ...
                                Conf);
    
    DeltaEvolution(SimulationStage,:) = Delta;

  end; % for SimulationStage=1:TotalSimulationStages
  
  % Record the values of the terminal state.
  StateEvolution(TotalSimulationStages+1,:)=StateVars;
end
