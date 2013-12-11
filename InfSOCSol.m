
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
                Options{:});

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

iss_save_conf(Conf);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%            WRITE SOLUTION FILE             %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

iss_save_solution(OCM, Conf);