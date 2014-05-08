
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

%% Pass through to iss_plot_contrule

if nargout==1
  ControlValues = ...
      iss_plot_contrule(FileName, InitialCondition, ...
                        'VariableOfInterest',  VariableOfInterest, ...
                        'LineSpec', LineSpec);
else
  iss_plot_contrule(FileName, InitialCondition, ...
                    'VariableOfInterest',  VariableOfInterest, ...
                    'LineSpec', LineSpec);
end; % if nargout==1