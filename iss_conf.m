function Conf = iss_conf(StateLB, StateUB, varargin)
  
  InitialSetup = 0;
  OptionsChanged = 0;
  
  if nargin > 2 && isstruct(varargin{1})
    Conf = varargin{1};
    if length(varargin) > 1 && isstruct(varargin{2})
      Options = varargin{2};
    else
      Options = struct(varargin{2:end});
    end
  else
    InitialSetup = 1;
    Conf = struct('Dimension', size(StateLB,2));
    Conf.Options = struct('StateStepSize', (StateUB - StateLB) / 10, ...
                          'TimeStep', 1, ...
                          'DiscountRate', 0.9, ...
                          'ProblemFile', 'infsocsol-result', ...
                          'A', [], ...
                          'b', [], ...
                          'Aeq', [], ...
                          'beq', [], ...
                          'ControlLB', -Inf, ...
                          'ControlUB', Inf, ...
                          'UserConstraintFunctionFile', [], ...
                          'ControlDimension', 1, ...
                          'PolicyIterations', 25, ...
                          'StochasticProblem', 0, ...
                          'NoisyVars', Conf.Dimension, ...
                          'NoiseSteps', 2, ...
                          'Noise', [-1, 1], ...
                          'NoiseProb', [1/2, 1/2], ...
                          'NumberOfSimulations', 1, ...
                          'SimulationEnd', 250, ...
                          'SimulationTimeStep', ones(1, 250), ...
                          'UserSuppliedNoise', [], ...
                          'TolX', sqrt(eps), ...
                          'MaxIter', 100);
    
    if isstruct(varargin{1})
      Options = varargin{1};
    else
      Options = struct(varargin{:});
    end  
  end

  fields = fieldnames(Options);
  for i = 1:length(fields)
    f = fields{i};
    Conf.Options.(f) = Options.(f);
    OptionsChanged = 1;
  end
  
  % Skip the rest unless an option changed or this is a first run.
  if ~InitialSetup && ~OptionsChanged
    return
  end

  %% An option should state which optimization routine to use.
  if ~isfield(Conf.Options, 'Optimizer')
    if (exist('fmincon', 'file'))
      Conf.Options.Optimizer = 'fmincon';
    elseif (exist('sqp', 'file'))
      Conf.Options.Optimizer = 'sqp';
    else
      error('neither fmincon nor sqp could be found');
    end
  end

  %% Use the option (set above) to select a function handle.
  if strcmp(Conf.Options.Optimizer, 'fmincon')
    if isfield(Conf.Options, 'FminconOptions')
      FminconDefaults = Conf.Options.FminconOptions;
    else
      FminconDefaults = {};
    end
    Conf.FminconOptions = iss_conf_fmincon(Conf.Options.ControlDimension, ...
                                           FminconDefaults{:});
    
    Conf.Optimizer = @iss_optim_fmincon;
  elseif strcmp(Conf.Options.Optimizer, 'sqp')
    Conf.Optimizer = @iss_optim_sqp;
  else
    error(['Unknown optimizer selected: ', Conf.Options.Optimizer]);
  end

  %% Construct coding vector and friends
  [Conf.States, Conf.TotalStates, Conf.CodingVector] = ...
      ConstructCodingVector(StateLB, StateUB, Conf.Options.StateStepSize);

  %% Determine user constraint function to use
  [Conf.UserConstraintFunction, Conf.UserConstraintFunctionFile] = ...
      DetermineUserConstraintFunction(Conf.Options);

  %% Compute discount factor
  [Conf.DiscountFactor] = Dis(Conf.Options.DiscountRate, ...
                              Conf.Options.TimeStep);
  
  %% Setup simulation config
  [Conf.Vertices, Conf.TotalSimulationStages, Conf.Time, Conf.SimTime, ...
   Conf.ControlTime, Conf.UserSuppliedNoise] = iss_conf_sim(StateLB, ...
                                                    StateUB, Conf);
end