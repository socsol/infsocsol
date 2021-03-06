%% ISS_ARRAYFUN_DISTRIBUTED Uses MATLAB's distributed arrays to run ARRAYFUN

%%
%  Copyright 2015 Jacek B. Krawczyk and Alastair Pharo
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
function varargout = iss_arrayfun_distributed(numprocs, fun, varargin)

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
  handle_pool = iss_pool_start(numprocs);


  %% Work out what inputs are cell arrays.
  arrays = varargin;
  for i = 1:numel(varargin)
    if (~ismatrix(varargin{i}))
      arrays = varargin(1:i-1);
      break;
    end
  end

  options = cell(1, length(varargin) - length(arrays));
  for j = 1:length(options)
    options{j} = varargin{i+j-1};
  end

  % If this function is called inside a worker, don't try to distribute
  % again.
  if isempty(getCurrentJob)
    darrays = cell(size(arrays));
    for i = 1:length(darrays)
      darrays{i} = distributed(arrays{i});
    end
  else
    darrays = arrays;
  end
  arrays = []; % for memory


  %% Pass a distributed cell to cellfun
  varargout = cell(1, nargout);

  try
    [varargout{:}] = arrayfun(fun, darrays{:}, options{:});
  catch exception
    iss_pool_stop(handle_pool);
    rethrow(exception);
  end


  %% Get the results back onto the local machine
  for i = 1:nargout
    varargout{i} = gather(varargout{i});
  end


  %% Close the pool
  iss_pool_stop(handle_pool);
end