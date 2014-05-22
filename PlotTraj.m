
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
function PlotTraj(Dimension,ControlDimension,VariableMin,VariableMax,...
    Time,Minimum,Maximum,SimTime,ControlTime,StateEvolution,Control,...
    LineSpec,LineWidth,TrajectoryOfInterest)
% This function plots timepaths. It is called by InfSim.

% Compute last time to 4dp for rescaling of time axes.
axisTime=round(1000*SimTime(length(SimTime)))/1000;

% Plot either all timepaths, or just the timepath of interest.
if TrajectoryOfInterest==0

    % Plot the timepaths of each of the Dimension state variables.
    for i=1:Dimension
        subplot(Dimension+ControlDimension,1,i);
        hold on;
        plot(SimTime,StateEvolution(:,i),LineSpec, 'LineWidth', LineWidth);
        grid on;
        if VariableMin
            plot([0,Time],Minimum(:,i),'k');
        end;
        if VariableMax
            plot([0,Time],Maximum(:,i),'k');
        end;
        ylabel(['x_',int2str(i)]);
        tempAxis=axis;
        axis([0,axisTime,tempAxis(3:4)]);
    end; % for i=1:Dimension

    % Plot the timepaths of each of the ControlDimension controls.
    for i=1:ControlDimension
        subplot(Dimension+ControlDimension,1,Dimension+i);
        hold on;
        plot(SimTime,[Control(:,i); Control(length(ControlTime), ...
                                            i)],LineSpec, 'LineWidth', ...
             LineWidth);
        grid on;
        ylabel(['u_',int2str(i)]);
        tempAxis=axis;
        axis([0,axisTime,tempAxis(3:4)]);
    end; % for i=1:ControlDimension
else
    if TrajectoryOfInterest<=Dimension
        hold on;
        plot(SimTime,StateEvolution(:,TrajectoryOfInterest),LineSpec, ...
             'LineWidth', LineWidth);
        grid on;
        if VariableMin
            plot([0,Time],Minimum(:,TrajectoryOfInterest),'k');
        end;
        if VariableMax
            plot([0,Time],Maximum(:,TrajectoryOfInterest),'k');
        end;
        ylabel(['x_',int2str(TrajectoryOfInterest)]);
    else
        hold on;
        plot(SimTime,[Control(:,TrajectoryOfInterest-Dimension); Control(length(ControlTime),TrajectoryOfInterest...
            -Dimension)],LineSpec, 'LineWidth', LineWidth);
        grid on;
        ylabel(['u_',int2str(TrajectoryOfInterest-Dimension)]);
    end; % if TrajectoryOfInterest<=Dimension
    tempAxis=axis;
    axis([0,axisTime,tempAxis(3:4)]);
end; % if TrajectoryOfInterest==0
xlabel('t');