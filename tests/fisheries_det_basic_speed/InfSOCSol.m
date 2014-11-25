function InfSOCSol(DeltaFunction,StageReturnFunction,StateLB,StateUB,...
    StateStepSize,TimeStep,DiscountRate,FileName,Options,A,b,Aeq,beq,...
    ControlLB,ControlUB,UserConstraintFunctionFile)
% InfSOCSol takes the given SOC problem and approximates it with a Markov
% decision chain, which it then solves. This results in a discrete-time,
% discrete-space control rule. InfSOCSol does not perform the interpolation
% necessary to convert this discrete-time, discrete-space control rule into
% a continuous-time, continuous-state control rule (this is done by
% InfSim).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%             DEFINE CONSTANTS 1             %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Error check number of input arguments.
if nargin~=16
    error('InfSolve requires exactly 16 input arguments.');
end;

% A few variable definitions and initializations.
clear global DeltaFunction global StageReturnFunction global OCM*;
Dimension=size(StateLB,2);

% Check that Options is a cell array of strings of appropriate size, and
% initialize some variables pertaining to Options.
OptionsSize=size(Options);
if OptionsSize(1)>1||mod(OptionsSize(2),2)||~iscellstr(Options)
    error(['Expected Options to be an empty array or a 1 x 2n cell',...
        ' array of strings for some natural number n.']);
end;
Options=char(Options);
OptionsSize=size(Options);
OptionsLength=OptionsSize(1);

% Initialize and print ControlDimension.
ControlDimension=1;
for i=1:OptionsLength
    if strcmpi(deblank(Options(i,:)),'controldimension')
        temp=str2double(Options(i+1,:));
        if ~isempty(temp)&&isfinite(temp)&&isreal(temp)&&temp>0&&...
                round(temp)==temp
            ControlDimension=temp;
            Options=[Options(1:i-1,:);Options(i+2:OptionsLength,:)];
            OptionsLength=OptionsLength-2;
            break;
        else
            error(['Expected ControlDimension to be a natural number in'...
                ' string form.']);
        end; % if ~isempty(temp)&&isfinite(temp)&&isreal(temp)&&temp>0&&...
    end; % if strcmpi(deblank(Options(i,:)),'controldimension')
end; % for i=1:OptionsLength
fprintf(1,['\nInfSOCSol Options\n=================\n\n',...
    'Control dimension:             %2.0f\n'],ControlDimension);

% Initialize and print PolicyIterations.
PolicyIterations=25;
for i=1:OptionsLength
    if strcmpi(deblank(Options(i,:)),'policyiterations')
        temp=str2double(Options(i+1,:));
        if ~isempty(temp)&&isfinite(temp)&&isreal(temp)&&temp>0&&...
                round(temp)==temp
            PolicyIterations=temp;
            Options=[Options(1:i-1,:);Options(i+2:OptionsLength,:)];
            OptionsLength=OptionsLength-2;
            break;
        else
            error(['Expected PolicyIterations to be a natural number in'...
                ' string form.']);
        end; % if ~isempty(temp)&&isfinite(temp)&&isreal(temp)&&temp>0&&...
    end; % if strcmpi(deblank(Options(i,:)),'policyiterations')
end; % for i=1:OptionsLength
fprintf(1,'Number of policy iterations: %4.0f\n',PolicyIterations);

% Initialize and print StochasticProblem.
StochasticProblem=0;
for i=1:OptionsLength
    if strcmpi(deblank(Options(i,:)),'stochasticproblem')
        if strcmpi(deblank(Options(i+1,:)),'yes')||...
                strcmpi(deblank(Options(i+1,:)),'no')
            if strcmp(deblank(Options(i+1,:)),'yes')
                StochasticProblem=1;
            else
                StochasticProblem=0;
            end; % if strcmp(deblank(Options(i+1,:)),'yes')
            Options=[Options(1:i-1,:);Options(i+2:OptionsLength,:)];
            OptionsLength=OptionsLength-2;
            break;
        else
            error('Expected StochasticProblem to be ''yes'' or ''no''.');
        end; % if strcmpi(deblank(Options(i+1,:)),'yes')||...
    end; % if strcmpi(deblank(Options(i,:)),'stochasticproblem')
end; % for i=1:OptionsLength
if StochasticProblem
    fprintf(1,'Stochastic problem:           yes\n');
else
    fprintf(1,'Stochastic problem:            no\n');
end; % if StochasticProblem

% Initialize variables pertaining to stochastic problems and print the
% number of noisy variables.
NoisyVars=Dimension;
if StochasticProblem
    for i=1:OptionsLength
        if strcmpi(deblank(Options(i,:)),'noisyvars')
            temp=str2double(Options(i+1,:));
            if ~isempty(temp)&&isfinite(temp)&&isreal(temp)&&temp>0&&...
                    round(temp)==temp
                NoisyVars=temp;
                Options=[Options(1:i-1,:);Options(i+2:OptionsLength,:)];
                OptionsLength=OptionsLength-2;
                break;
            else
                error(['Expected NoisyVars to be a natural number in',...
                    ' string form.']);
            end; % if ~isempty(temp)&isfinite(temp)&isreal(temp)&temp>0&...
        end; % if strcmpi(deblank(Options(i,:)),'noisyvars')
    end; % for i=1:OptionsLength
    NoiseSteps=2;         % OR: 3;
    Noise=[-1,1];         % OR: [0,-1.52513527,1.52516527];
    NoiseProb=[1/2,1/2];  % OR: [0.6476,0.1762,0.1762];
    fprintf(1,'Number of noisy variables:     %2.0f\n',NoisyVars);
end; % if StochasticProblem

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%           DEFINE FMINCON OPTIONS           %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize some variables pertaining to Options.
fminconOptions=optimset('DerivativeCheck','off','Diagnostics','off',...
    'DiffMaxChange',1e-1,'DiffMinChange',1e-8,'Display','off',...
    'LargeScale','off','MaxFunEvals',100*ControlDimension,'MaxIter',400,...
    'MaxSQPIter',Inf,'OutputFcn',[],'TolCon',1e-6,'TolFun',1e-6,...
   'TolX',1e-6, 'Algorithm','active-set'); %apparently needed in Matlab 7.8
%     'TolX',1e-6); %% replaced by the preceding row if 'LargeScale','off' 
OptionsForWrite=Options;
OptionsForWriteLength=OptionsLength/2;

% Initialize DerivativeCheck.
for i=1:OptionsLength
    if strcmpi(deblank(Options(i,:)),'derivativecheck')
        fminconOptions=optimset(fminconOptions,'DerivativeCheck',...
            deblank(Options(i+1,:)));
        Options=[Options(1:i-1,:);Options(i+2:OptionsLength,:)];
        OptionsLength=OptionsLength-2;
        break;
    end; % if strcmpi(deblank(Options(i,:)),'derivativecheck')
end; % for i=1:OptionsLength

% Initialize Diagnostics.
for i=1:OptionsLength
    if strcmpi(deblank(Options(i,:)),'diagnostics')
        fminconOptions=optimset(fminconOptions,'Diagnostics',...
            deblank(Options(i+1,:)));
        Options=[Options(1:i-1,:);Options(i+2:OptionsLength,:)];
        OptionsLength=OptionsLength-2;
        break;
    end; % if strcmpi(deblank(Options(i,:)),'diagnostics')
end; % for i=1:OptionsLength

% Initialize DiffMaxChange.
for i=1:OptionsLength
    if strcmpi(deblank(Options(i,:)),'diffmaxchange')
        fminconOptions=optimset(fminconOptions,'DiffMaxChange',...
            str2double(Options(i+1,:)));
        Options=[Options(1:i-1,:);Options(i+2:OptionsLength,:)];
        OptionsLength=OptionsLength-2;
        break;
    end; % if strcmpi(deblank(Options(i,:)),'diffmaxchange')
end; % for i=1:OptionsLength

% Initialize DiffMinChange.
for i=1:OptionsLength
    if strcmpi(deblank(Options(i,:)),'diffminchange')
        fminconOptions=optimset(fminconOptions,'DiffMinChange',...
            str2double(Options(i+1,:)));
        Options=[Options(1:i-1,:);Options(i+2:OptionsLength,:)];
        OptionsLength=OptionsLength-2;
        break;
    end; % if strcmpi(deblank(Options(i,:)),'diffminchange')
end; % for i=1:OptionsLength

% Initialize Display.
for i=1:OptionsLength
    if strcmpi(deblank(Options(i,:)),'display')
        fminconOptions=optimset(fminconOptions,'Display',...
            deblank(Options(i+1,:)));
        Options=[Options(1:i-1,:);Options(i+2:OptionsLength,:)];
        OptionsLength=OptionsLength-2;
        break;
    end; % if strcmpi(deblank(Options(i,:)),'display')
end; % for i=1:OptionsLength

% Initialize MaxFunEvals.
for i=1:OptionsLength
    if strcmpi(deblank(Options(i,:)),'maxfunevals')
        fminconOptions=optimset(fminconOptions,'MaxFunEvals',...
            str2double(Options(i+1,:)));
        Options=[Options(1:i-1,:);Options(i+2:OptionsLength,:)];
        OptionsLength=OptionsLength-2;
        break;
    end; % if strcmpi(deblank(Options(i,:)),'maxfunevals')
end; % for i=1:OptionsLength

% Initialize MaxIter.
for i=1:OptionsLength
    if strcmpi(deblank(Options(i,:)),'maxiter')
        fminconOptions=optimset(fminconOptions,'MaxIter',...
            str2double(Options(i+1,:)));
        Options=[Options(1:i-1,:);Options(i+2:OptionsLength,:)];
        OptionsLength=OptionsLength-2;
        break;
    end; % if strcmpi(deblank(Options(i,:)),'maxiter')
end; % for i=1:OptionsLength

% Initialize MaxSQPIter.
for i=1:OptionsLength
    if strcmpi(deblank(Options(i,:)),'maxsqpiter')
        fminconOptions=optimset(fminconOptions,'MaxSQPIter',...
            str2double(Options(i+1,:)));
        Options=[Options(1:i-1,:);Options(i+2:OptionsLength,:)];
        OptionsLength=OptionsLength-2;
        break;
    end; % if strcmpi(deblank(Options(i,:)),'maxsqpiter')
end; % for i=1:OptionsLength

% Initialize OutputFcn.
for i=1:OptionsLength
    if strcmpi(deblank(Options(i,:)),'outputfcn')
        fminconOptions=optimset(fminconOptions,'OutputFcn',...
            str2func(deblank(Options(i+1,:))));
        Options=[Options(1:i-1,:);Options(i+2:OptionsLength,:)];
        OptionsLength=OptionsLength-2;
        break;
    end; % if strcmpi(deblank(Options(i,:)),'outputfcn')
end; % for i=1:OptionsLength

% Initialize TolCon.
for i=1:OptionsLength
    if strcmpi(deblank(Options(i,:)),'tolcon')
        fminconOptions=optimset(fminconOptions,'TolCon',...
            str2double(Options(i+1,:)));
        Options=[Options(1:i-1,:);Options(i+2:OptionsLength,:)];
        OptionsLength=OptionsLength-2;
        break;
    end; % if strcmpi(deblank(Options(i,:)),'tolcon')
end; % for i=1:OptionsLength

% Initialize TolFun.
for i=1:OptionsLength
    if strcmpi(deblank(Options(i,:)),'tolfun')
        fminconOptions=optimset(fminconOptions,'TolFun',...
            str2double(Options(i+1,:)));
        Options=[Options(1:i-1,:);Options(i+2:OptionsLength,:)];
        OptionsLength=OptionsLength-2;
        break;
    end; % if strcmpi(deblank(Options(i,:)),'tolfun')
end; % for i=1:OptionsLength

% Initialize TolX.
for i=1:OptionsLength
    if strcmpi(deblank(Options(i,:)),'tolx')
        fminconOptions=optimset(fminconOptions,'TolX',...
            str2double(Options(i+1,:)));
        Options=[Options(1:i-1,:);Options(i+2:OptionsLength,:)];
        OptionsLength=OptionsLength-2;
        break;
    end; % if strcmpi(deblank(Options(i,:)),'tolx')
end; % for i=1:OptionsLength

% Check for unrecognised Options and print fmincon Options.
if OptionsLength~=0
    error(['Unrecognised option: ',Options(1,:)]);
end;
fprintf(1,'\nFmincon Options\n===============\n\n');
disp(fminconOptions);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%        INCORPORATE USER CONSTRAINTS        %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

UserConstraintFunction='';
if StochasticProblem
    if isempty(UserConstraintFunctionFile)
    elseif isa(UserConstraintFunctionFile,'char')
        UserConstraintFunction=str2func(UserConstraintFunctionFile);
        UserConstraintFunctionFile='ConstFuncStoch';
    elseif isa(UserConstraintFunctionFile,'function_handle')
        UserConstraintFunction=UserConstraintFunctionFile;
        UserConstraintFunctionFile='ConstFuncStoch';
    else
        error(['Expected UserConstraintFunctionFile to be a string, a',...
            ' function handle or an empty array. Received a ',...
            class(UserConstraintFunctionFile) '.']);
    end; % if isempty(UserConstraintFunctionFile)
else
    if isempty(UserConstraintFunctionFile)
    elseif isa(UserConstraintFunctionFile,'char')
        UserConstraintFunction=str2func(UserConstraintFunctionFile);
        UserConstraintFunctionFile='ConstFuncDeter';
    elseif isa(UserConstraintFunctionFile,'function_handle')
        UserConstraintFunction=UserConstraintFunctionFile;
        UserConstraintFunctionFile='ConstFuncDeter';
    else
        error(['Expected UserConstraintFunctionFile to be a string, a',...
            ' function handle or an empty array. Received a ',...
            class(UserConstraintFunctionFile) '.']);
    end; % if isempty(UserConstraintFunctionFile)
end; % if StochasticProblem

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%             DEFINE CONSTANTS 2             %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

States=round((StateUB-StateLB)./StateStepSize+1);
c=cumprod(States);
TotalStates=c(Dimension);
CodingVector=[1,c(1:Dimension-1)];
NumFminconCalls=0;
DiscountFactor=Dis(DiscountRate,TimeStep);

% Initial policy.
UOptimal=ones(1,TotalStates);

% The problem name defines a fileset consisting of a parameter file with
% the suffix .DPP. and a solution file with the suffix .DPS.
ParametersDataFile=[FileName,'.DPP'];
SolutionDataFile=[FileName,'.DPS'];

% Begin timing.
StartTime=cputime;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 MAIN LOOP                  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:PolicyIterations
    U=UOptimal;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%             VALUE DETERMINATION            %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if StochasticProblem
        Value=ValDetStoch(DeltaFunction,StageReturnFunction,StateLB,...
            StateStepSize,TimeStep,DiscountFactor,Dimension,States,...
            TotalStates,CodingVector,U,...
            Noise,NoiseSteps,NoiseProb,NoisyVars);
    else
        Value=ValDetDeter(DeltaFunction,StageReturnFunction,StateLB,...
            StateStepSize,TimeStep,DiscountFactor,Dimension,States,...
            TotalStates,CodingVector,U);
    end; % if StochasticProblem
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%             POLICY IMPROVEMENT             %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    UStart=((inv(TimeStep))*10);
    if StochasticProblem
        for StateNum=1:TotalStates
            StateVect=SnToSVec(StateNum,CodingVector,Dimension);
            StateVars=(StateVect-1).*StateStepSize+StateLB;
            UOptimal(StateNum)=fmincon('CostStoch',UStart,A,b,Aeq,beq,...
                ControlLB,ControlUB,UserConstraintFunctionFile,...
                fminconOptions,DeltaFunction,StageReturnFunction,...
                UserConstraintFunction,StateLB,StateStepSize,TimeStep,...
                DiscountFactor,Dimension,States,CodingVector,StateVars,...
                Value,...
                Noise,NoiseSteps,NoiseProb,NoisyVars);
            NumFminconCalls=NumFminconCalls+1;
            for j=1:ControlDimension
               eval(['OCM',int2str(j),'(StateNum)=UOptimal(StateNum);']);
            end;
        end; % for state=1:TotalStates
    else
        for StateNum=1:TotalStates
            StateVect=SnToSVec(StateNum,CodingVector,Dimension);
            StateVars=(StateVect-1).*StateStepSize+StateLB;
            UOptimal(StateNum)=fmincon('CostDeter',UStart,A,b,Aeq,beq,...
                ControlLB,ControlUB,UserConstraintFunctionFile,...
                fminconOptions,DeltaFunction,StageReturnFunction,...
                UserConstraintFunction,StateLB,StateStepSize,TimeStep,...
                DiscountFactor,Dimension,States,CodingVector,StateVars,...
                Value);
            NumFminconCalls=NumFminconCalls+1;
            for j=1:ControlDimension
               	eval(['OCM',int2str(j),'(StateNum)=UOptimal(StateNum);']);
            end; 
        end; % for state=1:TotalStates
    end; % if StochasticProblem

    % Termination criterion.
    Norm=norm(U-UOptimal);
    fprintf(1,['Iteration Number: ',num2str(i),'. Norm: ',num2str(Norm),'\n']);
    if Norm<=0.0001
        break;
    end;
end; % for i=1:PolicyIterations

% Print final value and number of policy iterations.
FinalValue=Value(TotalStates);
fprintf(1,'Final value determination: %f\n',FinalValue);
fprintf(1,['Number of policy iterations: ',num2str(i),'\n']);

% Print final norm if the number of iterations used failed to take it under
% 0.001.
if i==PolicyIterations
    fprintf(1,'All iterations were used.\n');
end;

global Iterations;
Iterations = i;

% Stop timing execution and record time.
ElapsedTime=cputime-StartTime;
fprintf(1,'Computation time: %10.3f seconds\n',ElapsedTime);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%            WRITE PARAMETER FILE            %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[fid,message]=fopen(ParametersDataFile,'w');
if fid==-1
	fprintf(['Error opening ',FileName,'.DPP\n']);
	error(message);
end; % if fid==-1
fprintf(fid,[DeltaFunction,'\n']);
fprintf(fid,[StageReturnFunction,'\n']);
MatWrite(StateLB,fid);
MatWrite(StateUB,fid);
MatWrite(StateStepSize,fid);
MatWrite(TimeStep,fid);
MatWrite(DiscountRate,fid);
MatWrite([ControlDimension,PolicyIterations,StochasticProblem,...
    NoisyVars],fid);
for i=1:OptionsForWriteLength
    fprintf(fid,[OptionsForWrite(i,:),': ',OptionsForWrite(i+1,:)]);
end;
fprintf(fid,'Computation Time: %g',ElapsedTime);
fprintf(fid,'fmincon was called: %g',NumFminconCalls);
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%            WRITE SOLUTION FILE             %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[fid,message]=fopen(SolutionDataFile,'w');
if fid==-1
	fprintf(['Error opening ',FileName,'.DPS\n']);
	error(message);
end; % if fid==-1
for i=1:ControlDimension
	eval(['MatWrite(OCM',int2str(i),',fid);']);
end;
MatWrite(UOptimal,fid);
MatWrite(Value,fid);
fclose(fid);
