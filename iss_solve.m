
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
function [OCM, UOptimal, Value, Flags] = iss_solve(DeltaFunction, ...
                                            StageReturnFunction, ...
                                            StateLB, StateUB, varargin);

  %% Construct options
  Conf = iss_conf(StateLB, StateUB, varargin{:});

  open_pool = 0;
  try
    if (Conf.Options.PoolSize > 1 && strcmp(Conf.System, 'matlab'))
      if matlabpool('size') == 0
        open_pool = 1;
        matlabpool(Conf.Options.PoolSize);
      end
    end

    Options = Conf.Options;
    Dimension = Conf.Dimension;

    % Initial policy -- in between the two bounds.
    MidControl = Options.ControlLB + (Options.ControlUB - ...
                                      Options.ControlLB) / 2;

    % Most likely happens when there are no control bounds.
    if (isnan(MidControl))
      if Options.ControlLB < 0 && Options.ControlUB > 0
        MidControl = 0;
      elseif Options.ControlLB < 0
        MidControl = Options.ControlUB;
      else
        MidControl = Options.ControlLB;
      end
    end

    % Create a cell array of controls.
    UOptimal = mat2cell(meshgrid(MidControl, ...
                                 ones(1, Conf.TotalStates)), ...
                        ones(1, Conf.TotalStates), ...
                        Options.ControlDimension);

    % Use this as the "start" control for each iteration.  This
    % means that the same start is used in every iteration.
    UStart = UOptimal;

    Norms = zeros(1, Options.PolicyIterations);

    StoppingTolerance = 5*10^(Dimension-5);

    for i=1:Options.PolicyIterations
      if Conf.Debug
        fprintf(' * Iteration #%i:\n', i);
      else
        fprintf(' * Iteration #%i ... ', i);
      end

      if Conf.Debug
        fprintf('   - Value determination:\n');
      end
      Value = iss_valdet(UOptimal, DeltaFunction, StageReturnFunction, ...
                         StateLB, StateUB, Conf);
      if Conf.Debug
        fprintf('   - Value determination completed.\n');
      end

      if Conf.Debug
        fprintf('   - Policy improvement ... ');
        polimp_start = tic();
      end

      UOld = UOptimal;
      [UOptimal, Flags] = iss_polimp(UStart, Value, DeltaFunction, ...
                                     StageReturnFunction, StateLB, ...
                                     StateUB, Conf);

      if Conf.Debug
        polimp_elapsed = toc(polimp_start);
        fprintf('done (%fs; %fs/state).\n', ...
                polimp_elapsed, ...
                polimp_elapsed / Conf.TotalStates);
      end

      % Termination criterion.
      if Conf.Debug
        fprintf('   - Iteration #%i ', i);
      end
      if i == 1
        fprintf('completed.\n', i);
      else
        m1 = cell2mat(UOld);
        m2 = cell2mat(UOptimal);
        diffs =  m1(:) - m2(:);
        num_diffs = length(find(diffs ~= 0));
        Norms(i) = norm(diffs);
        fprintf(['completed; norm: %f; # of ' ...
                 'differences: %i.\n'], Norms(i), num_diffs);

        if Norms(i) <= StoppingTolerance
          fprintf(['   - Norm is less than stopping tolerance of %f; Stopping.\n'], StoppingTolerance);
          break;
        % elseif i == 2 && Norms(i) <= StoppingTolerance
        %   fprintf(['   - Not enough change in second iteration; ' ...
        %            'randomizing controls.\n'], StoppingTolerance);

        %   for j = 1:length(UOptimal)
        %     % Make a random "extreme" or middle control choice
        %     UStart = Options.ControlLB + ...
        %              randi([-1, 1], 1, length(Options.ControlUB)) .* ...
        %              (Options.ControlUB - Options.ControlLB);

        %     % Replace any infinite values with a large-ish random
        %     % number.
        %     UStart(UStart == Inf) = abs(rand * 100);
        %     UStart(UStart == -Inf) = -abs(rand * 100);

        %     % NaNs occur when both values are infinite.
        %     UStart(UStart == Inf) = rand * 100;

        %     UOptimal{j} = UStart;
        %   end
        end
      end

      if i >= 4 && all(Norms(i-3:i-1) == Norms(i))
        fprintf('   - Last four norms were identical; aborting.\n');
        break;
      end
    end; % for i=1:PolicyIterations

    % Optimal Coding Matrix initialisation.  This is just
    % slicing the cell array of optimal controls orthogonally
    OCM = mat2cell(cell2mat(UOptimal), ...
                   Conf.TotalStates, ...
                   ones(1, Options.ControlDimension));

    % Print final value and number of policy iterations.
    FinalValue=Value(Conf.TotalStates);
    fprintf('\n * Final value determination: %f\n', FinalValue);
    fprintf(' * Number of policy iterations: %i\n', i);

    % Print information about how many errors occurred
    errors = length(find(cell2mat(Flags) ~= 1));
    fprintf(' * Errors: %i\n', errors);
    fprintf(' * Error Percentage: %f\n\n', errors * 100 / Conf.TotalStates);

    % Print final norm if the number of iterations used failed to take it under
    % 0.001.
    if i==Options.PolicyIterations
      fprintf(' * All iterations were used.\n');
    end

    if open_pool
      matlabpool close
    end
  catch
    exception = lasterror();

    if open_pool
      matlabpool close
    end

    %exception.stack(2)
    rethrow(exception);
  end

  %% If a problem file has been specified, save the details
  if Options.ProblemFile
    if Conf.Debug
      fprintf(' * Saving to %s ... ', Options.ProblemFile);
    end

    iss_save_conf(DeltaFunction, StageReturnFunction, StateLB, StateUB, Conf);
    iss_save_solution(OCM, Conf);

    if Conf.Debug
      fprintf('done.\n');
    end
  end
end
