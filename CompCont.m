function U=CompCont(Vertices,Dimension,UpState,DownState,CodingVector,...
    UpProb,DownProb,ODM)
% This function computes the control for a particular state and stage. It
% is called by InfSim.

% Determine the optimal decision matrices.
ControlDimension=length(ODM);

% Initialize the control.
U=0;

% For each of the 2^Dimension possible transition states.
for i=0:Vertices
    VertexNum=i;
			
    % Reduce the vertex number to binary in a vector.
    BinVect=zeros(1,Dimension);
    for j=Dimension:-1:1
    	BinVect(j)=floor(VertexNum/2^(j-1));
    	VertexNum = VertexNum-BinVect(j)*2^(j-1);
    end; % for j=Dimension:-1:1
			
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