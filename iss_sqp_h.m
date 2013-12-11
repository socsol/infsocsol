
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
function v = iss_sqp_h(u, x, A, b, nonlcon, conf)
  if all([size(A), size(b)] > 0)
    v1 = b - A * u;
  else
    v1 = [];
  end

  v2 = [];
  if ~isempty(nonlcon)
    [c,ceq] = nonlcon(u, x, conf);
    if ~isempty(c)
      v2 = -c;
    end
  end
  
  v = [v1,v2]';
end