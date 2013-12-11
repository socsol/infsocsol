
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
function [UpState, UpProb, DownState, DownProb] = ...
      iss_up_down_state(AppState, Conf)

  Dimension = Conf.Dimension;
  States = Conf.States;
  
  % Compute the adjacent nodes on the state grid and the transition
  % probabilities.
  UpState=ceil(AppState);
  DownState=floor(AppState);
  UpProb=AppState-DownState;
  for i=1:Dimension
    if DownState(i)>=States(i)&&UpState(i)~=States(i)
      UpState(i)=States(i);
      DownState(i)=States(i);
      UpProb(i)=1;
    elseif UpState(i)<=1&&DownState(i)~=1
      DownState(i)=1;
      UpState(i)=1;
      UpProb(i)=1;
    elseif UpState(i)==DownState(i)
      UpProb(i)=1;
    end; % if DownState(i)>=States(i)&&UpState(i)~=States(i)
  end; % i=1:Dimension
  DownProb=1-UpProb;
end
