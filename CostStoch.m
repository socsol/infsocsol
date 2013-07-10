function value=CostStoch(U,DeltaFunction,StageReturnFunction,...
    UserConstraintFunction,StateLB,StateStepSize,TimeStep,...
    DiscountFactor,Dimension,States,CodingVector,StateVars,...
    PrevValue,Conf,...
    Noise,NoiseSteps,NoiseProb,NoisyVars) %#ok<INUSL>
% This is the cost function minimized by fmincon at the policy improvement
% step of the policy improvement algorithm in the stochastic case.

% Compute the time derivative vector.
Delta=feval(DeltaFunction,U,StateVars,1);
DeltaMain=Delta(1:Dimension)*TimeStep;
DeltaStoch=Delta(Dimension+1:Dimension+NoisyVars)*sqrt(TimeStep);

% Compute the stage return by left hand endpoint rectangular approximation.
value=feval(StageReturnFunction,U,StateVars,1,Cost)*TimeStep;

% Compute the number of vertices.
Vertices=2^Dimension-1;

for NoiseCount=1:NoisyVars*NoiseSteps
    NoiseNum=NoiseCount-1;
    
    % Reduce the NoiseNum to base NoiseSteps in a vector.
    NoiseVect=zeros(1,Dimension);
    for j=Dimension:-1:1
        NoiseVect(j)=floor(NoiseNum /NoiseSteps^(j-1));
        NoiseNum=NoiseNum-NoiseVect(j)*NoiseSteps^(j-1);
    end; % for j=Num(1):-1:1
    TotalNoiseProb=prod(NoiseProb(NoiseVect+1));
    TotalNoiseVect=[Noise(NoiseVect+1),zeros(1,Dimension-NoisyVars)];
    
    % Compute "approximate" state vector. This is where the system evolves
    % to before it is constrained to the state grid.
    AppState=(StateVars+DeltaMain+DeltaStoch.*TotalNoiseVect-StateLB)...
        ./StateStepSize+1;
    
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
    end; % for i=1:Dimension
    DownProb=1-UpProb;
    
    % Compute the return for this by weighting the cost to go at each node
    % by its associated transition probability for each of the 2^Dimension
    % possible transition states.
    for i=0:Vertices
        VertexNum=i;
        
        % Reduce the vertex number to binary in a vector.
        BinVect=zeros(1,Dimension);
        for j=Dimension:-1:1
            BinVect(j)=floor(VertexNum /2^(j-1));
            VertexNum=VertexNum-BinVect(j)*2^(j-1);
        end; % for j=Dimension:-1:1
        
        % Compute the state vector for the current vertex.
        Vertex=UpState.*BinVect+DownState.*(~BinVect);
        
        % Compute the state number corresponding to the state vector.
        VertexStateNum=(Vertex-1)*CodingVector'+1;
        
        % Compute the probability of being at that vertex.
        VertexProb=prod(UpProb.*BinVect+DownProb.*(~BinVect));
        
        % Add the weighted return at this vertex to the value.
        value=value+DiscountFactor*TotalNoiseProb*VertexProb...
            *PrevValue(VertexStateNum);
    end; % for i=0:Vertices
end; % for NoiseCount=1:NoisyVars*NoiseSteps