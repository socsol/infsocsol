function InfSOCSol(DeltaFunction,StageReturnFunction,StateLB,StateUB,...
    StateStepSize,TimeStep,DiscountRate,FileName,Options,A,b,Aeq,beq,...
    ControlLB,ControlUB,UserConstraintFunctionFile)
% InfSOCSol takes the given SOC problem and approximates it with a Markov
% decision chain, which it then solves. This results in a discrete-time,
% discrete-space control rule. InfSOCSol does not perform the interpolation
% necessary to convert this discrete-time, discrete-space control rule into
% a continuous-time, continuous-state control rule (this is done by
% InfSim).

% Error check number of input arguments
if nargin~=16
    error('InfSOCSol requires exactly 16 input arguments.');
end;

%% Extract options that aren't for fmincon
%   note that we don't bother to remove them from the cell, as it
%   is expected that optimset will ignore them anyway.
GivenOptions = struct(Options{:});
ExtraOptions = {};
ISSOptions = {'ControlDimension', 'StochasticProblem', 'NoisyVars', ...
              'PolicyIterations'};

for i = 1:length(ISSOptions)
  if isfield(GivenOptions, ISSOptions{i})
    ExtraOptions.(IssOptions{i}) = GivenOptions.(IssOptions{i});
  end
end

%% Create Conf struct
Conf = iss_conf(StateLB, StateUB, ...
                'StateStepSize', StateStepSize, ...
                'TimeStep', TimeStep, ...
                'DiscountRate', DiscountRate, ...
                'ProblemFile', FileName, ...
                'A', A, ...
                'b', b, ...
                'Aeq', Aeq, ...
                'beq', beq, ...
                'ControlLB', ControlLB, ...
                'ControlUB', ControlUB, ...
                'UserConstraintFunctionFile', UserConstraintFunctionFile, ...
                'FminconOptions', {Options}, ...
                ExtraOptions{:});

%% Run the main loop
%   returns the optimal decision matrices as a cell array

% Begin timing.
StartTime=cputime;

[OCM, UOptimal, Value] = iss_solve(DeltaFunction, StageReturnFunction, ...
                                   StateLB, StateUB, Conf);

% Stop timing execution and record time.
ElapsedTime=cputime-StartTime;
fprintf(1,'Computation time: %10.3f seconds\n', ElapsedTime);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%            WRITE PARAMETER FILE            %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The problem name defines a fileset consisting of a parameter file with
% the suffix .DPP. and a solution file with the suffix .DPS.
ParametersDataFile=[FileName,'.DPP'];

[fid,message]=fopen(ParametersDataFile,'w');
if fid==-1
	fprintf(['Error opening ',FileName,'.DPP\n']);
	error(message);
end; % if fid==-1
fprintf(fid,[DeltaFunction,'\n']);

if ischar(StageReturnFunction)
  fprintf(fid,[StageReturnFunction,'\n']);
else
  fprintf(fid,['x','\n']);  
end

MatWrite(StateLB,fid);
MatWrite(StateUB,fid);
MatWrite(StateStepSize,fid);
MatWrite(TimeStep,fid);
MatWrite(DiscountRate,fid);
MatWrite([Conf.Options.ControlDimension,Conf.Options.PolicyIterations,Conf.Options.StochasticProblem,...
    Conf.Options.NoisyVars],fid);

names = fieldnames(Conf.Options);
for i=1:length(names)
  opt = Conf.Options.(names{i});
  if ischar(opt)
    fprintf(fid,[names{i},': ',opt]);
  elseif isscalar(opt) && isnumeric(opt)
    fprintf(fid,[names{i},': ',num2str(opt)]);
  end
end;
%fprintf(fid,'fmincon was called: %g',NumFminconCalls);
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%            WRITE SOLUTION FILE             %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

SolutionDataFile=[FileName,'.DPS'];

[fid,message]=fopen(SolutionDataFile,'w');
if fid==-1
	fprintf(['Error opening ',FileName,'.DPS\n']);
	error(message);
end; % if fid==-1
for i=1:Conf.Options.ControlDimension
	MatWrite(OCM{i},fid);
end;
MatWrite(UOptimal,fid);
MatWrite(Value,fid);
fclose(fid);
