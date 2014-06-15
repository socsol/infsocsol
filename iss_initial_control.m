
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
function MidControl = iss_initial_control(Conf)
  % Extract options
  ControlLB = Conf.Options.ControlLB;
  ControlUB = Conf.Options.ControlUB;
  TimeStep = Conf.Options.TimeStep;

  % Initial policy -- in between the two bounds.
  MidControl = ControlLB + (ControlUB - ControlLB) / 2;

  % This most likely happens when there are no control bounds.  We
  % handle this by choosing some large predictable number.
  MidControl(isnan(MidControl)) = inv(TimeStep) * 10;
    
  % If the lower bound is violated, use the lower bound exactly.
  MidControl(MidControl < ControlLB) = ControlLB(MidControl < ControlLB);

  % Similarly for the upper bound.
  MidControl(MidControl > ControlUB) = ControlUB(MidControl > ControlUB);
end