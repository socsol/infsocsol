%% ISS_ARRAYFUN_PARFOR An implementation of ARRAYFUN that uses PARFOR
%
% SYNOPSIS
%   This s a MATLAB equivalent of pararrayfun for GNU Octave. It is
%   used instead of parfor in order to a single functional
%   interface for both MATLAB and Octave.  You should not need to
%   use it stand-alone.
%
%   This function automatically starts and stops workers in order to perform
%   computation, so you shouldn't do this yourself.
%
% USAGE
%   % Run with two processors -- call fn(x, y, z) on each combination of
%   % elements from x, y, z, and give their return values in the matrix, v.
%   v = vk_cellfun_parfor(2, fn, x, y, z);
%
%   % If fn2 returns a non-scalar, then use the "UniformOutput" option.  In this
%   % case, v will be a cell.
%   v = vk_cellfun_parfor(2, fn2, x, y, z, 'UniformOutput', false);
%
% See also: arrayfun, pararrayfun, parfor

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
function varargout = iss_arrayfun_parfor(numprocs, fun, varargin)


  %% nret gives the number of return values to work with.
  if (nargout(fun) >= 1)
    nret = nargout(fun);
  elseif nargout >= 1
    nret = nargout;
  else
    nret = 1;
  end


  %% Work out what inputs are cell arrays.
  % Unless we discover otherwise, all inputs are arrays.
  array_count = numel(varargin);
  for i = 1:array_count
    if ~isnumeric(varargin{i})
      array_count = i-1;
      break;
    end
  end

  if array_count < 1
    error('There must be at least one array as input');
  end


  %% Any remaining inputs should be name:value pairs.
  % We need to know the 'uniform output' setting, but nothing else.
  if (array_count < numel(varargin))
    options = struct(varargin{array_count+1:end});
    uniform_output = isfield(options, 'UniformOutput') && options.UniformOutput;
  else
    options = struct();
    uniform_output = true;
  end


  %% Work out the dimensions of each array
  array_size = size(varargin{1});
  array_numel = numel(varargin{1});


  %% Start the pool, unless its already started
  handle_pool = 0;
  if matlabpool('size') == 0 && isempty(getCurrentJob)
    handle_pool = 1;
    matlabpool(numprocs);
  end


  %% Construct return cell
  % We have to return the result of each parfor run, and the break
  % it up afterwards.
  rets = cell(array_size);


  %% Make the function calls in parallel.
  try
    parfor i = 1:array_numel
      rets{i} = cell(1, nret);
      args = cell(1, array_count);

      for j = 1:array_count
        args{j} = varargin{j}(i);
      end

      [rets{i}{:}] = fun(args{:});
    end
  catch exception
    fprintf('Error:\n');
    disp(exception);

    if handle_pool
      matlabpool close;
    end

    rethrow(exception);
  end


  %% Close the pool
  if handle_pool
    matlabpool close;
  end


  %% Construct the output cell arrays
  varargout = cell(1, nret);

  for i = 1:nret
    if uniform_output
      varargout{i} = zeros(array_size);
    else
      varargout{i} = cell(array_size);
    end
  end

  for i = 1:array_numel
    for j = 1:nret
      if uniform_output
        varargout{j}(i) = rets{i}{j};
      else
        varargout{j}(i) = rets{i}(j);
      end
    end
  end
end