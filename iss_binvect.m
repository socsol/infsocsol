
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
% ISS_BINVECT Reduce the vertex number to binary in a vector
function BinVect = iss_binvect(VertexNum, Conf)
  Dimension = Conf.Dimension;
  
  BinVect=zeros(1,Dimension);
  for j=Dimension:-1:1
    BinVect(j)=floor(VertexNum/2^(j-1));
    VertexNum=VertexNum-BinVect(j)*2^(j-1);
  end; % for j=Dimension:-1:1
end
  
