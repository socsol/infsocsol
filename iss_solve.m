function [OCM, UOptimal, Value, Flags] = iss_solve(DeltaFunction, ...
                                            StageReturnFunction, ...
                                            StateLB, StateUB, varargin);

  %% Construct options
  Conf = iss_conf(StateLB, StateUB, varargin{:});
  
  Options = Conf.Options;
  Dimension = Conf.Dimension;
  
  % Initial policy -- in between the two bounds.
  UOptimal = meshgrid(Options.ControlLB + (Options.ControlUB - ...
                                           Options.ControlLB) / 2, ...
                      ones(1, Conf.TotalStates));

  Norms = zeros(1, Options.PolicyIterations);
  
  StoppingTolerance = 5*10^(Dimension-5);
  
  for i=1:Options.PolicyIterations
    
    U=UOptimal;
    Value = iss_valdet(U, DeltaFunction, StageReturnFunction, StateLB, ...
                        StateUB, Conf);
    
    [UOptimal, Flags] = iss_polimp(U, Value, DeltaFunction, ...
                                   StageReturnFunction, StateLB, ...
                                   StateUB, Conf);
    
    % Termination criterion.
    if i > 1
      diffs = U(:) - UOptimal(:);
      Norms(i) = norm(diffs, 2);
      fprintf(1, ...
              ['Iteration Number: %i; Norm: %f; # of Differences: %i\n'], ...
              i, Norms(i), length(find(diffs ~= 0)));

      if Norms(i) <= StoppingTolerance
        break;
      end
    end
    
    if i >= 4 && all(Norms(i-3:i-1) == Norms(i))
        fprintf('Last four norms were identical; aborting');
    end
  end; % for i=1:PolicyIterations

  % Optimal Coding Matrix initialisation
  OCM = cell(Options.ControlDimension);
  for j=1:Options.ControlDimension
    OCM{j} = UOptimal(:, j);
    OCM{j}
  end

  % Print final value and number of policy iterations.
  FinalValue=Value(Conf.TotalStates);
  fprintf(1,'Final value determination: %f\n',FinalValue);
  fprintf(1,['Number of policy iterations: ',num2str(i),'\n']);

  % Print final norm if the number of iterations used failed to take it under
  % 0.001.
  if i==Options.PolicyIterations
    fprintf(1,'All iterations were used.\n');
  end
end
