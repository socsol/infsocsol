
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
function TransProb = iss_transprob(AppState, Conf)
  
  CodingVector = Conf.CodingVector;
  Dimension = Conf.Dimension;
  TotalStates = Conf.TotalStates;
  Vertices = Conf.Vertices;
  
  [UpState, UpProb, DownState, DownProb] = ...
      iss_up_down_state(AppState, Conf);

  % Create a row vector for the transition probabilities.
  if Conf.UseSparse
    TransProb=sparse(1,TotalStates);
  else
    TransProb=zeros(1,TotalStates);
  end
  
  % Compute the return for this by weighting the cost to go at each node
  % by its associated transition probability for each of the 2^Dimension
  % possible transition states.
  for VertexNum=0:Vertices
    % Reduce the vertex number to binary in a vector
    BinVect = iss_binvect(VertexNum, Conf);
    
    % Compute the state vector for the current vertex.
    Vertex=UpState.*BinVect+DownState.*(~BinVect);

    % Compute the state number corresponding to the state vector.
    VertexStateNum=(Vertex-1)*CodingVector'+1;	
    
    % Compute the probability of being at that vertex.  If we are
    % using a sparse matrix, we ignore low probabilities.
    prob = prod(UpProb.*BinVect+DownProb .* (~BinVect));
    if ~Conf.UseSparse || prob >= Conf.Options.TransProbMin
      TransProb(VertexStateNum) = prob;
    end
  end; % for i=0:Vertices
end
