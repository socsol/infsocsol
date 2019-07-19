
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
function plot_diffs(states, diffs)

  lb = [60 0.1];
  ub = [600  1];

  state_step = (ub - lb) ./ (states - 1);
  
  state_lb = lb - state_step;
  state_ub = ub + state_step;

  figure
  hold on
  grid on
  
  [X,Y] = ndgrid(linspace(state_lb(1), ...
                          state_ub(1), ...
                          states(1)), ...
                 linspace(state_lb(2), ...
                          state_ub(2), ...
                          states(2)));
  
  for i = 1:length(diffs)
    subplot(ceil(length(diffs)/2), 2, i);
    surf(X,Y,reshape(diffs{i}, states));
    axis([state_lb(1), state_ub(1), state_lb(2), state_ub(2)]);
    view(3);
  end
end
