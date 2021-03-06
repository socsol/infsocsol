
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
function iss_save_conf(DeltaFunction, StageReturnFunction, StateLB, StateUB, Conf)
  Options = Conf.Options;

  % If we are running in Octave, override the save setup
  if exist('save_default_options','builtin')
    save_default_options('-v7', 'local');
  end

  save([Conf.Options.ProblemFile, '_options.mat'], ...
       'DeltaFunction', 'StageReturnFunction', ...
       'StateLB', 'StateUB', 'Options');
end