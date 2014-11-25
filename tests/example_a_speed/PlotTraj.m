function PlotTraj(Dimension,ControlDimension,VariableMin,VariableMax,...
    Time,Minimum,Maximum,SimTime,ControlTime,StateEvolution,Control,...
    LineSpec,TrajectoryOfInterest)
% This function plots timepaths. It is called by InfSim.

% Compute last time to 4dp for rescaling of time axes.
axisTime=round(1000*SimTime(length(SimTime)))/1000;

% Plot either all timepaths, or just the timepath of interest.
if TrajectoryOfInterest==0

    % Plot the timepaths of each of the Dimension state variables.
    for i=1:Dimension
        subplot(Dimension+ControlDimension,1,i);
        plot(SimTime,StateEvolution(:,i),LineSpec);
        hold on;
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
        plot(SimTime,[Control(:,i); Control(length(ControlTime),i)],LineSpec);
        hold on;
        ylabel(['u_',int2str(i)]);
        tempAxis=axis;
        axis([0,axisTime,tempAxis(3:4)]);
    end; % for i=1:ControlDimension
else
    if TrajectoryOfInterest<=Dimension
        plot(SimTime,StateEvolution(:,TrajectoryOfInterest),LineSpec);
        hold on;
        if VariableMin
            plot([0,Time],Minimum(:,TrajectoryOfInterest),'k');
        end;
        if VariableMax
            plot([0,Time],Maximum(:,TrajectoryOfInterest),'k');
        end;
        ylabel(['x_',int2str(TrajectoryOfInterest)]);
    else
        plot(SimTime,[Control(:,TrajectoryOfInterest-Dimension); Control(length(ControlTime),TrajectoryOfInterest...
            -Dimension)],LineSpec);
        hold on;
        ylabel(['u_',int2str(TrajectoryOfInterest-Dimension)]);
    end; % if TrajectoryOfInterest<=Dimension
    tempAxis=axis;
    axis([0,axisTime,tempAxis(3:4)]);
end; % if TrajectoryOfInterest==0
xlabel('t');