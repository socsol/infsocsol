function [OCM, UOptimal, Value, Flags] = iss_solve(DeltaFunction, ...
                                            StageReturnFunction, ...
                                            StateLB, StateUB, varargin);

  %% Construct options
  Conf = iss_conf(StateLB, StateUB, varargin{:});
  
  Options = Conf.Options;
  Dimension = Conf.Dimension;
  
  % Initial policy.
  UOptimal=ones(1,Conf.TotalStates);
  
  OCM = cell(Options.ControlDimension);
  Norms = zeros(1, Options.PolicyIterations);
  
  StoppingTolerance = 5*10^(Dimension-5);
  
  for i=1:Options.PolicyIterations
    
    U=UOptimal;
    Value = iss_valdet(U, DeltaFunction, StageReturnFunction, StateLB, ...
                        StateUB, Conf);
    
    [UOptimal, OCM, Flags] = iss_polimp(UOptimal, OCM, Value, ...
                                        DeltaFunction, StageReturnFunction, ...
                                        StateLB, StateUB, Conf);
    
    % Termination criterion.
    Norms(i) = norm(U-UOptimal);
    fprintf(1,['Iteration Number: ',num2str(i),'. Norm: ',num2str(Norm),'\n']);
    if Norms(i) <= StoppingTolerance
      break;
    end;
    
    if i >= 4 && all(Norms(i-3:i-1) == Norms(i))
        fprintf('Last four norms were identical; aborting');
    end
  end; % for i=1:PolicyIterations

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
