
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
%% ISS_CONF_VALIDATE
% Validates InfSOCSol config files.
function Options = iss_conf_validate(StateLB, StateUB, Options)
  
  %% Natural number options
  natural_numbers = {'ControlDimension', 'PolicyIterations', ...
                     'NoisyVars'};
  
  for i = 1:length(natural_numbers)
    nn = natural_numbers{i};
    Options.(nn) = parse_natural_number(Options.(nn));
    if ~is_natural_number(Options.(nn))
      error(['Expected ',nn,' to be a natural number.']);
    end
  end
  
  %% Numbers (unspecified)
  numbers = {'DiffMaxChange', 'DiffMinChange', ...
             'MaxFunEvals', 'MaxIter', 'MaxSQPIter', ...
             'TolCon', 'TolFun', 'TolX'};
  
  for i = 1:length(numbers)
    rn = numbers{i};
    Options.(rn) = parse_real_number(Options.(rn));
    if ~isscalar(Options.(rn)) || ~isreal(Options.(rn))
      error(['Expected ', rn, ' to be a real number']);
    end
  end
  
  %% Booleans
  booleans = {'StochasticProblem'};
  for i = 1:length(booleans)
    b = booleans{i};
    Options.(b) = parse_boolean(Options.(b));
    if ~is_boolean(Options.(b))
      error(['Expected ',b,' to be a boolean ("yes" or "no").']);
    end
  end
      
  %% Functions
  functions = {'OutputFcn', 'UserConstraintFunctionFile'};
  for i = 1:length(functions)
    f = functions{i};
    Options.(f) = parse_function(Options.(f));
    if ~is_function(Options.(f), [])
      error(['Expected ', f, ' to be a function, or name of a ' ...
      'function.']);
    end
  end  
end

function it = parse_natural_number(it)
  it = parse_real_number(it);
end

function valid = is_natural_number(it, null_value)
  if nargin > 1 && ...
        strcmp(class(it),class(null_value)) && ... 
        all(it == null_value)
    valid = true;
    return;
  end
  
  valid = isscalar(it) && ...
          isfinite(it) && ...
          isreal(it) && ...
          it > 0 && ...
          round(it) == it;
end

function it = parse_real_number(it)
  if ischar(it)
    it = str2double(it);
  end
end    

function it = parse_boolean(it)
  if ischar(it)
    if strcmp(it, 'yes')
      it = 1;
    elseif strcmp(it, 'no')
      it = 2;
    end
  end
end
  
function valid = is_boolean(it, null_value)
  if nargin > 1 && ...
        strcmp(class(it),class(null_value)) && ... 
        all(it == null_value)
    valid = true;
    return;
  end
  
  valid = isscalar(it) && ...
          (it == 1 || it == 0);
end

function it = parse_function(it)
  if ischar(it)
    it = str2func(it);
  end
end

function valid = is_function(it, null_value)
  if nargin > 1 && ...
        strcmp(class(it),class(null_value)) && ... 
        all(it == null_value)
    valid = true;
    return;
  end

  valid = isa(it, 'function_handle');
end