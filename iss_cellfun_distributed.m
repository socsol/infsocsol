%% ISS_CELLFUN_DISTRIBUTED Uses MATLAB's distributed cells to run CELLFUN

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
function varargout = iss_cellfun_distributed(numprocs, fun, varargin)

  if (nargin < 3)
    error('There must be at least one cell as input');
  end


  %% nret gives the number of return values to work with.
  if (nargout(fun) >= 1)
    nret = nargout(fun);
  else
    nret = nargout;
  end


  %% Start the pool, unless its already started
  handle_pool = 0;
  if matlabpool('size') == 0 && isempty(getCurrentJob)
    handle_pool = 1;
    matlabpool(numprocs);
  end
  

  %% Work out what inputs are cell arrays.
  cells = varargin;
  for i = 1:numel(varargin)
    if (~iscell(varargin{i}))
      cells = varargin(1:i-1);
      break;
    end
  end

  options = cell(1, length(varargin) - length(cells));
  for j = 1:length(options)
    options{j} = varargin{i+j-1};
  end

  % This shouldn't happen, but if this function is called inside a
  % worker, don't try to distribute again.
  if isempty(getCurrentJob)
    dcells = cell(size(cells));
    for i = 1:length(dcells)
      dcells{i} = distributed(cells{i});
    end
  else
    dcells = cells;
  end


  %% Pass a distributed cell to cellfun
  varargout = cell(1, nargout);
  [varargout{:}] = cellfun(fun, dcells{:}, options{:});
  
  
  %% Get the cells back onto the local machine
  for i = 1:nargout
    varargout{i} = gather(varargout{i});
  end


  %% Close the pool
  if handle_pool
    matlabpool close;
  end
end