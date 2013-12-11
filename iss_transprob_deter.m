
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
function TransProb = iss_transprob_deter(DeltaFunction, StateVars, ...
                                         U, StateLB, StateUB, Conf);
  
  StateStepSize = Conf.Options.StateStepSize;
  TimeStep = Conf.Options.TimeStep;
  
  Next = iss_next_euler(DeltaFunction, StateVars, U, TimeStep, 0, Conf);
  AppState = (Next-StateLB)./StateStepSize+1;
  TransProb = iss_transprob(AppState, Conf);
end
