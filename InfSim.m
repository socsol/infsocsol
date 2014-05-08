
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
function SimulatedValue=InfSim(FileName,InitialCondition,...
    SimulationTimeStep,NumberOfSimulations,LineSpec,TimepathOfInterest,...
    UserSuppliedNoise)
global StateEvolution Control
% InfSim derives a continuous-time, continuous-state control rule from the
% solution computed by InfSOCSol and then simulates the continuous system
% using this rule. It returns graphs of the timepaths of the state and
% control variables and the associated performance criterion values for one
% or more simulations.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%             DEFINE CONSTANTS               %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Error check the number of input arguments and give defaults to
% unspecified input arguments.
if nargin<7
	UserSuppliedNoise=-1;
    if nargin<6
        TimepathOfInterest=0;
        if nargin<5
            LineSpec='r-';
            if nargin<4
                NumberOfSimulations=1;
                if nargin<3
                    SimulationTimeStep=[];
                    if nargin<2
                        error(['InfSim must be given at least 2 input',...
                            ' arguments.']);
                    end;
                end; % if nargin<3
            end; % if nargin<4
        end; % if nargin<5
    end; % if nargin<6
end; % if nargin<7

% Error check SimulationTimeStep.
SimulationTimeStepSize=size(SimulationTimeStep);
if ~isempty(SimulationTimeStep)
    if isfinite(SimulationTimeStep)==ones(SimulationTimeStepSize)
    else
        error(['Expected SimulationTimeStep to be a real 1 x n array',...
            ' whose elements partition the interval [0, T] for some',...
            ' natural number n.']);
    end; % if isfinite(SimulationTimeStep)==ones(SimulationTimeStepSize)
end; % if isnumeric(SimulationTimeStep)&&isreal(SimulationTimeStep)&&...

% Error check NumberOfSimulations and define PlotTrajectories.
NumberOfSimulationsSize=size(NumberOfSimulations);
if isnumeric(NumberOfSimulations)&&isreal(NumberOfSimulations)&&...
        NumberOfSimulationsSize(1)==1&&NumberOfSimulationsSize(2)==1&&...
        isfinite(NumberOfSimulations)&&...
        round(NumberOfSimulations)==NumberOfSimulations&&...
        NumberOfSimulations~=0
    if NumberOfSimulations>0
        PlotTrajectories=1;
    else
        PlotTrajectories=0;
        NumberOfSimulations=-NumberOfSimulations;
    end; % if NumberOfSimulations>0
else
    error('Expected NumberOfSimulations to be a non-zero integer');
end; % if isnumeric(NumberOfSimulations)&&isreal(NumberOfSimulations)&&...

%% Pass through to iss_plot_sim
% This means that passing a negative value for NumberOfSimulations
% won't work as expected.

% Don't pass SimulationTimeStep through unless its defined
if ~isempty(SimulationTimeStep)
  simulation_timestep_option = {'SimulationTimeStep', SimulationTimeStep};
else
  simulation_timestep_option = {};
end

SimulatedValue = ...
    iss_plot_sim(FileName, InitialCondition, ...
                 'NumberOfSimulations', NumberOfSimulations, ...
                 'UserSuppliedNoise', UserSuppliedNoise, ...
                 'LineSpec', LineSpec, ...
                 'TimepathOfInterest', TimepathOfInterest, ...
                 simulation_timestep_option{:});
