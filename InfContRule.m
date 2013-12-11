
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
function ControlValues=InfContRule(FileName,InitialCondition,...
    VariableOfInterest,LineSpec) %#ok<INUSD>
% InfContRule produces graphs of the continuous-time, continuous-state
% control rule derived from the solution computed by InfSOCSol. Each
% control rule graph holds all but one state variable constant.

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
DeltaFunction=fscanf(fid,'%s',1); %#ok<NASGU>
StageReturnFunction=fscanf(fid,'%s',1); %#ok<NASGU>
fgets(fid);
Minimum=MatRead(fid);
Maximum=MatRead(fid);
StateStepSize=MatRead(fid);
TimeStep=MatRead(fid); %#ok<NASGU>
DiscountRate=MatRead(fid); %#ok<NASGU>
InfSOCSolOptions=MatRead(fid); %#ok<NASGU>
fclose(fid);
ControlDimension=InfSOCSolOptions(1);

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
for i=1:ControlDimension
	eval(['ODM',int2str(i),'=MatRead(fid);'])
end;
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%             DEFINE CONSTANTS               %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Error check the number of input arguments and give defaults to
% unspecified input arguments.
if  nargin<4
    LineSpec='r-'; %#ok<NASGU>
    if nargin<3
        VariableOfInterest=1;
        if nargin<2
            error('InfContRule must be given at least 3 input arguments.');
        end;
    end; % if nargin<3
end; % if nargin<4

% Determine the Dimension of the problem. This is used to compute the
% coding vector. (Though strictly its use is mere convenience).
Dimension=size(Minimum,2);

% Compute the discretization constants for the target stage.
States=round((Maximum-Minimum)./StateStepSize+1);
c=cumprod(States);
TotalStates=c(Dimension);
CodingVector=[1,c(1:Dimension-1)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%         COMPUTE CONTROL PROFILES           %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compute the State Number for the initial state modified by setting the
% variable of interest to its minimum value. All the states of interest are
% this base state plus some multiple of the variable of interest's coding
% value.
InitialCondition(VariableOfInterest)=Minimum(VariableOfInterest);
fprintf('Initial Condition: %12g\n',InitialCondition(VariableOfInterest));
BaseState=round((InitialCondition-Minimum)./StateStepSize)*...
    CodingVector'+1; %#ok<NASGU>

% Compute the actual state variables corresponding to the states of
% interest and compute the control profiles in these states.
fprintf('State Step:        %12g\n',StateStepSize(VariableOfInterest));
StateVect=Minimum(VariableOfInterest)+StateStepSize(VariableOfInterest)...
    *(0:(States(VariableOfInterest)-1)); %#ok<NASGU>
for i=1:ControlDimension
	eval(['C',int2str(i),'=ODM',int2str(i),...
        '(BaseState+CodingVector(VariableOfInterest).*',...
        '(0:(States(VariableOfInterest)-1)));']);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%           PLOT CONTROL PROFILES            %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1:ControlDimension
	subplot(ControlDimension,1,i);
	eval(['plot(StateVect,C',int2str(i),',LineSpec);']);
    grid;
	ylabel(['u_',int2str(i)]);
	hold on;
end; % for i=1:ControlDimension
xlabel(['x_',int2str(VariableOfInterest)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%               RETURN OUTPUT                %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargout==1
    ControlValues=zeros(length(StateVect),ControlDimension);
    for i=1:ControlDimension
        ControlValues(:,i) = eval(['C',int2str(i),]);
    end;
end; % if nargout==1