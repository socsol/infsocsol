%% ISS_POOL_START Starts a MATLAB worker pool

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
function handle_pool = iss_pool_start(numprocs)
  handle_pool = 0;
  if exist('parpool')
    poolobj = gcp('nocreate');
    if isempty(poolobj)
      handle_pool = 1;
      parpool(numprocs);
    end
  elseif exist('matlabpool') == 2
    if matlabpool('size') == 0 && isempty(getCurrentJob)
      handle_pool = 1;
      matlabpool(numprocs);
    end
  end
end
