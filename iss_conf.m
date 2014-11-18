
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
                          'ProblemFile', [], ...
                          'A', [], ...
                          'b', [], ...
                          'Aeq', [], ...
                          'beq', [], ...
                          'ControlLB', -Inf, ...
                          'ControlUB', Inf, ...
                          'Debug', 0, ...
                          'UserConstraintFunctionFile', [], ...
                          'ControlDimension', 1, ...
                          'LineSpec', 'r-', ...
                          'LineWidth', 0.5, ...
                          'PolicyIterations', 25, ...
                          'PoolSize', 1, ...
                          'ScaleFactor', 1, ...
                          'StochasticProblem', 0, ...
                          'NoisyVars', Conf.Dimension, ...
                          'NoiseSteps', 2, ...
                          'Noise', [-1, 1], ...
                          'NoiseProb', [1/2, 1/2], ...
                          'NumberOfSimulations', 1, ...
                          'SimulationEnd', 250, ...
                          'SimulationTimeStep', ones(1, 250), ...
                          'TimepathOfInterest', 0, ...
                          'TransProbMin', 0.01, ... % i.e. 1 percent
                          'UserSuppliedNoise', -1, ...
                          'VariableOfInterest', 1, ...
                          'DerivativeCheck', 'off', ...
                          'Diagnostics', 'off', ...
                          'DiffMaxChange', 1e-1, ...
                          'DiffMinChange', 1e-8, ...
                          'Display', 'off', ...
                          'LargeScale', 'off', ...
                          'MaxIter',400, ...
                          'MaxSQPIter', Inf, ...
                          'OutputFcn', [], ...
                          'TolCon', 1e-6, ...
                          'TolFun', 1e-6, ...
                          'TolX', 1e-6, ...
                          'UseParallel', 'never');

    Options = struct(varargin{:});
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

  %% Set the max iterations based on the number of controls.
  if ~isfield(Conf.Options, 'MaxFunEvals')
    Conf.Options.MaxFunEvals = 100 * Conf.Options.ControlDimension;
  end

  %% Perform option validation
  Conf.Options = iss_conf_validate(StateLB, StateUB, Conf.Options);

  %% Figure out what system this is
  if exist('octave_config_info', 'builtin')
    Conf.System = 'octave';

    % Check for the presence of the 'optim' package in Octave
    if any(cellfun(@(package) strcmp(package.name, 'optim'), pkg('list')))
      pkg load optim
    end

    if ~isfield(Conf.Options, 'Algorithm')
      Conf.Options.Algorithm = 'lm_feasible';
    end
  else
    Conf.System = 'matlab';
    if ~isfield(Conf.Options, 'Algorithm')
      Conf.Options.Algorithm = 'active-set';
    end
  end

  %% An option should state which optimization routine to use.
  if ~isfield(Conf.Options, 'Optimizer')
    if (exist('fmincon', 'file'))
      Conf.Options.Optimizer = 'fmincon';
    elseif (exist('nonlin_min', 'file'))
      Conf.Options.Optimizer = 'nonlin_min';
    elseif (exist('sqp', 'file'))
      Conf.Options.Optimizer = 'sqp';
    else
      error('none of "fmincon", "nonlin_min" or "sqp" could be found');
    end
  end

  %% Use the option (set above) to select a function handle.
  if strcmp(Conf.Options.Optimizer, 'fmincon')
    Conf.FminconOptions = optimset(Conf.Options);
    Conf.Optimizer = @iss_optim_fmincon;
  elseif strcmp(Conf.Options.Optimizer, 'nonlin_min')
    Conf.NonlinMinOptions = optimset(Conf.Options);
    Conf.Optimizer = @iss_optim_nonlin_min;
  elseif strcmp(Conf.Options.Optimizer, 'sqp')
    warning(['Using "sqp".  Better performance can often be achieved ' ...
             'by installing the "optim" package from Octave-Forge.']);
    Conf.Optimizer = @iss_optim_sqp;
  else
    error(['Unknown optimizer selected: ', Conf.Options.Optimizer]);
  end

  %% Setup a cell and array functions
  % This is used to handle parallel processing.
  if (Conf.Options.PoolSize > 1)

    % Check for the presence of the 'parallel' package in Octave
    if strcmp(Conf.System, 'octave') && ...
          any(cellfun(@(package) strcmp(package.name, 'parallel'), pkg('list')))
      pkg load parallel
    end

    if exist('parcellfun', 'file') == 2
      Conf.CellFn = ...
          @(varargin) parcellfun(Conf.Options.PoolSize, varargin{:}, ...
                                 'VerboseLevel', 0);
    elseif exist('parfor', 'builtin') == 5
      Conf.CellFn = ...
          @(varargin) iss_cellfun_parfor(Conf.Options.PoolSize, varargin{:});
    elseif exist('distributed', 'file') == 2
      Conf.CellFn = ...
          @(varargin) iss_cellfun_distributed(Conf.Options.PoolSize, varargin{:});
    else
      warning('PoolSize > 1, but no parallel capabilities could be detected.');
      Conf.CellFn = @cellfun;
    end

    if exist('pararrayfun', 'file') == 2
      Conf.ArrayFn = ...
          @(varargin) pararrayfun(Conf.Options.PoolSize, varargin{:}, ...
                                  'VerboseLevel', 0);
    elseif exist('parfor', 'builtin') == 5
      Conf.ArrayFn = ...
          @(varargin) iss_arrayfun_parfor(Conf.Options.PoolSize, varargin{:});
    elseif exist('distributed', 'file') == 2
      Conf.ArrayFn = ...
          @(varargin) iss_arrayfun_distributed(Conf.Options.PoolSize, varargin{:});
    else
      warning('PoolSize > 1, but no parallel capabilities could be detected.');
      Conf.ArrayFn = @arrayfun;
    end
  else
    Conf.CellFn = @cellfun;
    Conf.ArrayFn = @arrayfun;
  end

  %% Construct coding vector and friends
  Conf.States=round((StateUB-StateLB)./Conf.Options.StateStepSize+1);
  c=cumprod(Conf.States);
  Conf.TotalStates=c(Conf.Dimension);
  Conf.CodingVector=[1,c(1:Conf.Dimension-1)];

  %% Determine whether sparse matrices are required
  % This is completely arbitrary at the moment.
  Conf.UseSparse = Conf.TotalStates > 5000;  
  if Conf.UseSparse
    fprintf('Using sparse matrices (%i states)\n', Conf.TotalStates);
  end

  %% Compute discount factor
  Conf.DiscountFactor = Dis(Conf.Options.DiscountRate, ...
                            Conf.Options.TimeStep);

  %% Setup simulation config
  Conf.Vertices = 2^Conf.Dimension-1;
  Conf.TotalSimulationStages = ...
      length(Conf.Options.SimulationTimeStep);
  Conf.Time = cumsum(Conf.Options.TimeStep);
  Conf.SimTime = [0,cumsum(Conf.Options.SimulationTimeStep)];
  Conf.ControlTime = Conf.SimTime(1:end-1);

  %% Determine user constraint function to use based on stochasticity
  if isempty(Conf.Options.UserConstraintFunctionFile)
    Conf.UserConstraintFunction = '';
    Conf.UserConstraintFunctionFile = '';
  else
    if ischar(Conf.Options.UserConstraintFunctionFile)
      Conf.UserConstraintFunction= ...
          str2func(Conf.Options.UserConstraintFunctionFile);
    else
      Conf.UserConstraintFunction= ...
          Conf.Options.UserConstraintFunctionFile;
    end

    if Conf.Options.StochasticProblem
      Conf.UserConstraintFunctionFile='ConstFuncStoch';
    else
      Conf.UserConstraintFunctionFile='ConstFuncDeter';
    end
  end


  %% Select functions to use based on stochasticity
  % These functions all have the same signature, but behave
  % differently
  if Conf.Options.StochasticProblem
    Conf.NextFn = @iss_next_euler_muruyama;

    if Conf.Options.UserSuppliedNoise == -1
      Conf.SimNoiseFn = @iss_normal_noise_realization;
    else
      Conf.SimNoiseFn = @iss_user_supplied_noise_realization;
    end

    Conf.TransProbFn = @iss_transprob_stoch;
  else
    Conf.NextFn = @iss_next_euler;
    Conf.SimNoiseFn = @iss_zero_noise_realization;
    Conf.TransProbFn = @iss_transprob_deter;
  end

  %% For convenience
  Conf.Debug = Conf.Options.Debug;
end