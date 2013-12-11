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
function varargout = iss_cellfun_parfor(numprocs, fun, varargin)

    if (nargin < 3)
        error('There must be at least one cell as input');
    end


    %% nret gives the number of return values to work with.
    if (nargout(fun) >= 1)
        nret = nargout(fun);
    else
        nret = nargout;
    end


    %% Work out what inputs are cell arrays.
    cells = cell(1, length(varargin));
    for i = 1:length(varargin)
        if (~iscell(varargin{i}))
            break;
        end

        cells{i} = varargin{i};
    end

    %% Any remaining inputs should be name:value pairs.
    if (i < length(varargin))
        cells = cells(1:i-1);
        options = struct(varargin{i:end});
    else
        options = struct();
    end

    %% Check that all the cell arrays have the same size (if there's more than one).
    if (length(cells) > 1)
        chksize = size(cells{1});
        checks = cellfun(@(x) all(size(x) == chksize), cells(2:end));
        if (~all(checks))
            error('All cell arrays must have the same dimensions.');
        end
    end

    %% Create the return cell array.
    varargout = cell(nret,1);
    for v = 1:nret
        if (~isfield(options, 'UniformOutput') || options.UniformOutput)
            varargout{v} = zeros(size(cells{1}));
        else
            varargout{v} = cell(size(cells{1}));
        end
    end

    %% Construct argument arrays for each function call.
    args = cell(length(cells{1}),length(cells));
    for i = 1:length(cells{1})
        for j = 1:length(cells)
            c = cells{j};
            args(i,j) = c(i);
        end
    end

    %% Start the pool, unless its already started
    handle_pool = 0;
    if matlabpool('size') == 0
      handle_pool = 1;
      matlabpool(numprocs);
    end

    %% Make the function calls in parallel.
    try
        ret = cell(size(cells{1}));
        parfor i = 1:length(cells{1})
            r = cell(1, nret);
            [r{:}] = fun(args{i,:});
            ret{i} = r;
        end
    catch exception
        matlabpool close;
        rethrow(exception);
    end

    %% Close the pool
    if handle_pool
      matlabpool close;
    end

    %% Distribute the function call results (not in parallel).
    for i = 1:length(cells{1})
        r = ret{i};
        for v = 1:nret
            if (~isfield(options, 'UniformOutput') || options.UniformOutput)
                % Retrieve the v-th return array
                arr = varargout{v};
                % Update the i-th element
                arr(i) = r{v};
                % Set the v-th array to reflect the update
                varargout{v} = arr;
            else
                % Retrieve the v-th return cell
                c = varargout{v};
                % Update the i-th element
                c{i} = r{v};
                % Set the v-th cell to reflect the update
                varargout{v} = c;
            end
        end
    end
end

