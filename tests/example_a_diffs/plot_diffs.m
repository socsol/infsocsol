
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
function plot_norms(x_axis, diffs)
    
  figure
  hold on
  grid on
  
  legends = cell(1, length(diffs));
  
  for i = 1:length(diffs)
    plot(x_axis, diffs{i}, ...
         'Color', [1 - i/length(diffs), 0, i/length(diffs)]);
    
    legends{i} = ['Iteration ', num2str(i+1)];
  end

  %legend(legends{:});
end
