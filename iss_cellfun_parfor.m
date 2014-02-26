%% ISS_CELLFUN_PARFOR An implementation of CELLFUN that uses PARFOR
%
% SYNOPSIS
%   This s a MATLAB equivalent of parcellfun for GNU Octave. It is
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
% See also: cellfun, parcellfun, parfor

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
function varargout = iss_cellfun_parfor(numprocs, fun, varargin)

  % We need to track this here as apparently parfor breaks it somehow.
  nret = nargout;


  %% Work out what inputs are cell arrays.
  % Unless we discover otherwise, all inputs are cells.
  cells = varargin;
  for i = 1:numel(varargin)
    if ~iscell(varargin{i})
      cells = varargin(1:i-1);
      break;
    end
  end

  if numel(cells) < 1
    error('There must be at least one cell as input');
  end


  %% Any remaining inputs should be name:value pairs.
  % We need to know the 'uniform output' setting, but nothing else.
  if (i < length(varargin))
    options = struct(varargin{i:end});
    uniform_output = isfield(options, 'UniformOutput') && options.UniformOutput;
  else
    options = struct();
    uniform_output = true;
  end


  %% Break up the calls into lists of arguments.
  % Each cell in 'args' represents a call to 'fun'
  args = cellfun(@(varargin) varargin, cells{:}, ...
                 'UniformOutput', false);


  %% Start the pool, unless its already started
  handle_pool = 0;
  if matlabpool('size') == 0 && isempty(getCurrentJob)
    handle_pool = 1;
    matlabpool(numprocs);
  end


  %% Make the function calls in parallel.
  ret = cell(1, numel(cells{1}));
  try
    parfor i = 1:numel(cells{1})
      ret{i} = cell(1, nret);
      [ret{i}{:}] = fun(args{i}{:});
    end
  catch exception
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
  varargout = cellfun(@(varargin) reshape(varargin, size(cells{1})), ret{:}, ...
                      'UniformOutput', false);


  % If we are to give uniform output, convert each cell array to
  % a matrix.
  if uniform_output
    varargout = cellfun(@cell2mat, varargout, ...
                        'UniformOutput', false);
  end
end