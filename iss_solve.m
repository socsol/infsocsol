
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
    
    % Create a cell array of controls.
    UOptimal = mat2cell(meshgrid(MidControl, ...
                                 ones(1, Conf.TotalStates)), ...
                        ones(1, Conf.TotalStates), ...
                        Options.ControlDimension);

    Norms = zeros(1, Options.PolicyIterations);
    
    StoppingTolerance = 5*10^(Dimension-5);
    
    for i=1:Options.PolicyIterations
      Value = iss_valdet(UOptimal, DeltaFunction, StageReturnFunction, ...
                         StateLB, StateUB, Conf);

      UOld = UOptimal;
      [UOptimal, Flags] = iss_polimp(Value, DeltaFunction, ...
                                     StageReturnFunction, StateLB, ...
                                     StateUB, Conf);

      % Termination criterion.
      if i > 1
        m1 = cell2mat(UOld);
        m2 = cell2mat(UOptimal);
        diffs =  m1(:) - m2(:);
        Norms(i) = norm(diffs);
        fprintf(1, ...
                ['Iteration Number: %i; Norm: %f; # of Differences: %i\n'], ...
                i, Norms(i), length(find(diffs ~= 0)));

        if Norms(i) <= StoppingTolerance
          break;
        end
      end
      
      if i >= 4 && all(Norms(i-3:i-1) == Norms(i))
        fprintf('Last four norms were identical; aborting');
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
    fprintf(1,'Final value determination: %f\n',FinalValue);
    fprintf(1,['Number of policy iterations: ',num2str(i),'\n']);

    % Print final norm if the number of iterations used failed to take it under
    % 0.001.
    if i==Options.PolicyIterations
      fprintf(1,'All iterations were used.\n');
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
end
