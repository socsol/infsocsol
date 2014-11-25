function InfValGraph(FileName,InitialCondition,VariableOfInterest,...
    VariableOfInterestValues,SimulationTimeStep,NumberOfSimulations,...
    ScaleFactor,LineSpec)

global XValues VValues
%clear XValues VValues 
%modified to get hold of the computed values

% InfValGraph automates the process of computing expected values for the
% continuous system (under the continuous-time, continuous-state control
% rule derived from the solution computed by InfSOCSol) as the initial
% conditions change. In a similar spirit to InfContRule above, it deals
% with one state variable at a time (indentified by VariableOfInterest),
% while the other state variables remain fixed.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%              DEFINE CONSTANTS              %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Give defaults to unspecified input arguments.
if nargin<8
    LineSpec='r-';
    if nargin<7
	    ScaleFactor=1;
        if nargin<6
            NumberOfSimulations=1;
        end;
    end; % if nargin<7
end; % if nargin<8

% Error check ScaleFactor.
ScaleFactorSize=size(ScaleFactor);
if isnumeric(ScaleFactor)&&isreal(ScaleFactor)&&ScaleFactorSize(1)==1&&...
        ScaleFactorSize(2)==1&&isfinite(ScaleFactor)
else
    error('Expected ScaleFactor to be a real number.');
end; % if isnumeric(ScaleFactor)&&isreal(ScaleFactor)&&...

% Error check NumberOfSimulations.
NumberOfSimulationsSize=size(NumberOfSimulations);
if isnumeric(NumberOfSimulations)&&isreal(NumberOfSimulations)&&...
        NumberOfSimulationsSize(1)==1&&NumberOfSimulationsSize(2)==1&&...
        isfinite(NumberOfSimulations)&&...
        round(NumberOfSimulations)==NumberOfSimulations&&...
        NumberOfSimulations>0
else
    error('Expected NumberOfSimulations to be a natural number.');
end; % isnumeric(NumberOfSimulations)&&isreal(NumberOfSimulations)&&...

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

% Error check VariableOfInterestValues.
VariableOfInterestValuesSize=size(VariableOfInterestValues);
if isnumeric(VariableOfInterestValues)&&...
        isreal(VariableOfInterestValues)&&...
        VariableOfInterestValuesSize(1)==1
    if isfinite(VariableOfInterestValues)==...
            ones(VariableOfInterestValuesSize)
    else
        error(['Expected VariableOfInterestValues to be a real 1 x n',...
            ' array for some natural number n.']);
    end; % if isfinite(VariableOfInterestValues)==...
else
    error(['Expected VariableOfInterestValues to be a real 1 x n array',...
        ' for some natural number n.']);
end; % if isnumeric(VariableOfInterestValues)&&...

% Error check VariableOfInterest.
VariableOfInterestSize=size(VariableOfInterest);
if isnumeric(VariableOfInterest)&&isreal(VariableOfInterest)&&...
        VariableOfInterestSize(1)==1&&VariableOfInterestSize(2)==1&&...
        round(VariableOfInterest)==VariableOfInterest&&VariableOfInterest>0
else
    error(['Expected VariableOfInterest to be a natural number between',...
        ' 1 and d (inclusive).']);
end; % isnumeric(VariableOfInterest)&&isreal(VariableOfInterest)&&...

% Define UserSuppliedNoise.
if NumberOfSimulations==1
	UserSuppliedNoise=0;
else
	UserSuppliedNoise=-1;
end; % if NumberOfSimulations==1

% Predefine vector for better memory management and speed.
ValueVector=zeros(1,length(VariableOfInterestValues));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%           COMPUTE VALUE PROFILE            %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:length(VariableOfInterestValues)
	InitialCondition(VariableOfInterest)=VariableOfInterestValues(i);
	ValueVector(i)=ScaleFactor*mean(InfSim(FileName,InitialCondition,...
        SimulationTimeStep,-abs(NumberOfSimulations),UserSuppliedNoise));
end; % for i=1:length(VariableOfInterestValues)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%             PLOT VALUE PROFILE             %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
XValues=VariableOfInterestValues
VValues=ValueVector
plot(VariableOfInterestValues,ValueVector,LineSpec);
ylabel('Value');
xlabel(['x_',int2str(VariableOfInterest)]);
grid;