
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
function Policies = check_polimp(state_step, time_step, max_fun_evals, tol_fun)
  
  DeltaFunction = 'delta';
  StageReturnFunction = 'cost';
  StateLB = 0;
  StateUB = 0.5;

  %% Construct options
  Conf = iss_conf(StateLB, StateUB, ...
                  'StateStepSize', state_step, ...
                  'TimeStep', time_step, ...
                  'DiscountRate', 0.9, ...
                  'ProblemFile', 'example_a', ...
                  'MaxFunEvals', max_fun_evals, ...
                  'TolFun', tol_fun, ...
                  'Debug', 1);

  Options = Conf.Options;
  Dimension = Conf.Dimension;

  % This initial control comes from InfSOCSol2
  MidControl = ((inv(time_step))*10);

  % Use this as the "start" control for each iteration.  This
  % means that the same start is used in every iteration.
  UStart = mat2cell(meshgrid(MidControl, ...
                             ones(1, Conf.TotalStates)), ...
                    ones(1, Conf.TotalStates), ...
                    Options.ControlDimension);

  % This is fed into the initial value determination
  UOptimal = mat2cell(meshgrid(1, ...
                               ones(1, Conf.TotalStates)), ...
                      ones(1, Conf.TotalStates), ...
                      Options.ControlDimension);

  Norms = zeros(1, Options.PolicyIterations);
  
  Policies = zeros(Conf.TotalStates, Options.PolicyIterations);

  for i=1:Options.PolicyIterations
    Value = iss_valdet(UOptimal, DeltaFunction, StageReturnFunction, ...
                       StateLB, StateUB, Conf);

    UOld = UOptimal;
    [UOptimal, Flags] = iss_polimp(UStart, Value, DeltaFunction, ...
                                   StageReturnFunction, StateLB, ...
                                   StateUB, Conf);
    Policies(:, i) = cell2mat(UOptimal)';

    if i ~= 1
      m1 = cell2mat(UOld);
      m2 = cell2mat(UOptimal);
      diffs = m1(:) - m2(:);
      num_diffs = length(find(diffs ~= 0));
      Norms(i) = norm(diffs);

      if Norms(i) <= 0.0001
        break;
      end
    end
  end; % for i=1:PolicyIterations
end
