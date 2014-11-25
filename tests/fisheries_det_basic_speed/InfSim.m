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
%%%             READ PARAMETER FILE            %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Open parameter file.
[fid,message]=fopen([FileName,'.DPP'],'r');

% Error in opening?
if fid==-1
	fprintf(['Error opening ',FileName,'.DPP\n']);
	error(message);
end; % if fid==-1

% Read in program parameters.
DeltaFunction=fscanf(fid,'%s',1);
StageReturnFunction=fscanf(fid,'%s',1);
fgets(fid);
Minimum=MatRead(fid);
Maximum=MatRead(fid);
StateStepSize=MatRead(fid);
TimeStep=MatRead(fid);
DiscountRate=MatRead(fid); % For "new" files.
InfSOCSolOptions=MatRead(fid);
fclose(fid);
%DiscountRate=InfSOCSolOptions(4); % For "old" files.

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
                    SimulationTimeStep=TimeStep;
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
if isnumeric(SimulationTimeStep)&&isreal(SimulationTimeStep)&&...
        SimulationTimeStepSize(1)==1
    if isfinite(SimulationTimeStep)==ones(SimulationTimeStepSize)
    else
        error(['Expected SimulationTimeStep to be a real 1 x n array',...
            ' whose elements partition the interval [0, T] for some',...
            ' natural number n.']);
    end; % if isfinite(SimulationTimeStep)==ones(SimulationTimeStepSize)
else
    error(['Expected SimulationTimeStep to be a real 1 x n array whose',...
        ' elements partition the interval [0, T] for some natural',...
        ' number n.']);
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

% Define constants.
Dimension=size(Minimum,2);
TotalSimulationStages=length(SimulationTimeStep);
Time=cumsum(TimeStep);
SimTime=[0,cumsum(SimulationTimeStep)];
ControlTime=SimTime(1:(length(SimTime)-1));
ControlDimension=InfSOCSolOptions(1);
StochasticProblem=InfSOCSolOptions(3); % For "new" files.
%StochasticProblem=InfSOCSolOptions(2); % For "old" files.
Vertices=2^Dimension-1;
SimulatedValue=zeros(1,NumberOfSimulations);

% Define stochastic constants and error check UserSuppliedNoise.
UserSuppliedNoiseSize=size(UserSuppliedNoise);
if StochasticProblem
    NoisyVars=InfSOCSolOptions(4); % For "new" files.
%    NoisyVars=InfSOCSolOptions(3); % For "old" files.
    if isnumeric(UserSuppliedNoise)&&isreal(UserSuppliedNoise)
        if isfinite(UserSuppliedNoise)==ones(UserSuppliedNoiseSize)
            if UserSuppliedNoise==0
                UserSuppliedNoise=zeros(TotalSimulationStages,NoisyVars);
            elseif UserSuppliedNoise==-1    
            elseif UserSuppliedNoiseSize==...
                    [TotalSimulationStages,NoisyVars] %#ok<BDSCA>
            else
                error(['UserSuppliedNoise must be 0 or a real',...
                    ' length(SimulationTimeStep) x N array']);
            end; % if UserSuppliedNoise==0
        else
            error(['UserSuppliedNoise must be 0 or a real',...
                ' length(SimulationTimeStep) x N array']);
        end; % if isfinite(UserSuppliedNoise)==ones(UserSuppliedNoiseSize)
    else
        error(['UserSuppliedNoise must be 0 or a real',...
            ' length(SimulationTimeStep) x N array']);
    end; % if isnumeric(UserSuppliedNoise)&&isreal(UserSuppliedNoise)
end; % if StochasticProblem

% Check for variable discretization parameters and set up the 
% parameters for the terminal state function below.
if size(Minimum,1)==1
	VariableMin=0;
	Min=Minimum;
else
	VariableMin=1;
	Min=Minimum(1,:);
end; % if size(Minimum,1)==1
if size(Maximum,1)==1
	VariableMax=0;
else
	VariableMax=1;
end; % if size(Maximum,1)==1
if size(StateStepSize,1)==1
	VariableStateStep=0;
else
	VariableStateStep=1;
end; % if size(StateStepSize,1)==1

% Are any of the three discretization arguments variable? This is the
% variable that is used to decide whether to recalculate the
% discretization information for each stage.
VariableDiscretization=VariableMin|VariableMax|VariableStateStep;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%             READ SOLUTION FILE             %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Open solution file.
[fid,message]=fopen([FileName,'.DPS'],'r');

% Error in opening?
if fid==-1
	fprintf(['Error opening ',FileName,'.DPS\n']);
	error(message);
end; % if fid==-1

% Read Optimal Decision Matrices for each control dimension.
ODM=cell(1,ControlDimension);
for i=1:ControlDimension
	eval(['ODM{1,',int2str(i),'}=MatRead(fid);'])
end;
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%        COMPUTE AND PLOT TRAJECTORIES       %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot variable state bounds, if any.
if PlotTrajectories;
	hold on;
	for i=1:Dimension
		subplot(Dimension+ControlDimension,1,i);
		if VariableMin
			plot([0,Time],Minimum(:,i),'k');
		end
		hold on;
		if VariableMax
			plot([0,Time],Maximum(:,i),'k');
		end
		ylabel(['x',int2str(i)]);
	end; % for i=1:Dimension
end; % if PlotTrajectories

% Predefine empty holders to speed execution and improve
% memory management.
Control=zeros(TotalSimulationStages,ControlDimension);
StateEvolution=zeros(TotalSimulationStages+1,Dimension);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 MAIN LOOP                  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% For each of the NumberOfSimulations trajectories.
for count=1:NumberOfSimulations
    fprintf(['Computing trajectory number ',int2str(count),' of ',...
        int2str(NumberOfSimulations),'.\n']);
    
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%             COMPUTE TRAJECTORY             %%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% Set up discretization for stage 1 if it has changed
	% or if it has never been done.
	if VariableDiscretization||count==1
		Min=Minimum(1,:);
		Max=Maximum(1,:);
		StateStep=StateStepSize(1,:);
		States=round((Max-Min)./StateStep+1);
		c=cumprod(States);
		CodingVector = [1,c(1:Dimension-1)];
	end; % if VariableDiscretization||count==1
	
	% Convert the initial condition to a state vector
	AppState= (InitialCondition-Min)./StateStep+1;
	
	% For each stage in turn.
    for SimulationStage=1:TotalSimulationStages
	
		% Time is based on the simulation step and not on 
		% the discretization time step.
		t=SimTime(SimulationStage);
		
		% Take the current state, which is not constrained
		% to lie on the state grid, and find the adjacent
		% states together with their associated transition
		% probabilities.
		UpState=ceil(AppState);
		DownState=floor(AppState);
		UpProb=AppState-DownState;
        
        % Deal with the case of the approximated state
   	    % lying outside the discrete state space.
        [UpState,DownState,UpProb]=ConState(Dimension,UpState,DownState,...
            UpProb,States);
        DownProb=1-UpProb;

		% Compute the control for this by weighting the control at
		% each node by its associated transition probability.
        U=CompCont(Vertices,Dimension,UpState,DownState,CodingVector,...
            UpProb,DownProb,ODM);
		
		% Record the state and control for this simulation stage.
		StateVars=(AppState-1).*StateStep+Min;
		StateEvolution(SimulationStage,:)=StateVars; 
		Control(SimulationStage,:)=U;
        DiscountFactor=Dis(DiscountRate,t);
		SimulatedValue(count)=SimulatedValue(count)+...
            feval(StageReturnFunction,U,StateVars)*...
            SimulationTimeStep(SimulationStage)*DiscountFactor;

		% Stochastic case.
        if StochasticProblem
            % Compute deltas using Euler-Muruyama method.
			Delta=feval(DeltaFunction,U,StateVars,t);
			DeltaDeter=Delta(1:Dimension)*...
                SimulationTimeStep(SimulationStage);
			DeltaStoch=Delta(Dimension+1:Dimension+NoisyVars)*...
                sqrt(SimulationTimeStep(SimulationStage));
            
            % Compute noise.
            NoiseRealization=zeros(1,Dimension);
            if UserSuppliedNoise==-1
                NoiseRealization(1,1:NoisyVars)=randn(1,NoisyVars);
            else
        		NoiseRealization(1,1:NoisyVars)=...
                    UserSuppliedNoise(SimulationStage,:);
            end; % if UserSuppliedNoise==-1
        
            % Compute "approximate" state vector. This is where the system
            % evolves to before it is constrained to the state grid.
            AppState=(StateVars+DeltaDeter+...
                DeltaStoch.*NoiseRealization-Min)./StateStep+1;
            
        % Deterministic case.
        else
            % Compute delta using Euler-Muruyama method.
			Delta=feval(DeltaFunction,U,StateVars,t)*...
                SimulationTimeStep(SimulationStage);
            
            % Compute "approximate" state vector. This is where the system
            % evolves to before it is constrained to the state grid.
            AppState=(StateVars+Delta-Min)./StateStep+1;
        end; % if StochasticProblem
    end; % for SimulationStage=1:TotalSimulationStages

	% Record the values of the terminal state and add the terminal
	% state cost to the computed payoff.
	StateVars=(AppState-1).*StateStep+Min;
	StateEvolution(TotalSimulationStages+1,:)=StateVars;
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%%%               PLOT TRAJECTORY              %%%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if PlotTrajectories
        PlotTraj(Dimension,ControlDimension,VariableMin,VariableMax,...
            Time,Minimum,Maximum,SimTime,ControlTime,StateEvolution,...
            Control,LineSpec,TimepathOfInterest);
    end;
end; % for count=1:NumberOfSimulations