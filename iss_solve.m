
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
function [OCM, UOptimal, Value, Errors, Iterations] = ...
      iss_solve(DeltaFunction, ...
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

    % Determine the initial control.  This is used both to get the initial
    % value, and to feed into *every* policy improvement iteration.
    InitialControl = iss_initial_control(Conf);

    % Create a cell array of controls.  Use this as the "start" control
    % for each iteration.  This means that the same start is used in
    % every iteration.
    UStart = mat2cell(meshgrid(InitialControl, ...
                               ones(1, Conf.TotalStates)), ...
                      ones(1, Conf.TotalStates), ...
                      Options.ControlDimension);

    % Track the norm of each policy iteration.
    Norms = zeros(1, Options.PolicyIterations);

    % The value of all states is initially zero.
    Value = zeros(1, Conf.TotalStates);

    for i=1:Options.PolicyIterations
      if Conf.Debug
        fprintf(' * Iteration #%i:\n', i);
      else
        fprintf(' * Iteration #%i ... ', i);
      end

      if Conf.Debug
        fprintf('   - Policy improvement ... ');
        polimp_start = tic();
      end

      % Remember the previous control policy if this is not the first
      % iteration
      if i > 1
        UOld = UOptimal;
      end

      [UOptimal, Errors] = iss_polimp(UStart, Value, DeltaFunction, ...
                                      StageReturnFunction, StateLB, ...
                                      StateUB, Conf);

      if Conf.Debug
        polimp_elapsed = toc(polimp_start);
        fprintf('done (%fs; %fs/state; %i errors).\n', ...
                polimp_elapsed, ...
                polimp_elapsed / Conf.TotalStates, ...
                length(find(Errors)));
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

        if Norms(i) <= Options.StoppingTolerance
          fprintf(['   - Norm is less than stopping tolerance of %f; Stopping.\n'], ...
                  Options.StoppingTolerance);
          break;
        end
      end

      if i >= 4 && all(Norms(i-3:i-1) == Norms(i))
        fprintf('   - Last four norms were identical; aborting.\n');
        break;
      end

      if Conf.Debug
        fprintf('   - Value determination:\n');
      end

      Value = iss_valdet(UOptimal, DeltaFunction, StageReturnFunction, ...
                         StateLB, StateUB, Conf);

      if Conf.Debug
        fprintf('   - Value determination completed.\n');
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
    errors = length(find(Errors));
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

  %% Return the number of iterations
  Iterations = i;

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
