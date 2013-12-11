
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
%% Compute a control using the ODM
function U = iss_odm_control(ODM, StateVars, Minimum, Maximum, varargin)

  %% Construct options
  Conf = iss_conf(Minimum, Maximum, varargin{:});

  
  %% Extract the options we need  
  CodingVector = Conf.CodingVector;
  ControlDimension = Conf.Options.ControlDimension;
  Dimension=Conf.Dimension;
  Min = Minimum(1,:);
  States = Conf.States;
  StateStep = Conf.Options.StateStepSize;
  Vertices=Conf.Vertices;
    

  %% Compute relative state
  AppState = (StateVars - Min) ./ StateStep + 1;
  
  [UpState, UpProb, DownState, DownProb] = ...
      iss_up_down_state(AppState, Conf);

  %% Compute U
  % Initialize the control.
  U=0;
  % For each of the 2^Dimension possible transition states.
  for VertexNum=0:Vertices
    
    % Reduce the vertex number to binary in a vector.
    BinVect=iss_binvect(VertexNum, Conf);
    
    % Compute the state vector for the current vertex.
    Vertex=UpState.*BinVect+DownState.*(~BinVect);

    % Compute the state number corresponding to the state vector.
    VertexStateNum=(Vertex-1)*CodingVector'+1; %#ok<NASGU>

    % Compute the probability of being at that vertex.
    VertexProb=prod(UpProb.*BinVect+DownProb.*(~BinVect));

    % Get the optimal controls for this vertex.
    VertexControl = zeros(1,ControlDimension);
    if ~isnan(VertexStateNum)
      for k=1:ControlDimension
        VertexControl(k)= ODM{k}(VertexStateNum);
      end
    end

    % Add these controls, weighted, to the overall control.
    U=U+VertexProb.*VertexControl;
  end; % for i=0:Vertices
end