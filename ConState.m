function [UpState,DownState,UpProb]=ConState(Dimension,UpState,...
    DownState,UpProb,States)
% This function constrains an approximated state to lie within the state
% grid. It is called by InfSim.

for i=1:Dimension
  	if DownState(i)>=States(i)
    	UpState(i)=States(i);
    	DownState(i)=States(i);
    	UpProb(i)=1;
    elseif UpState(i)<=1
    	DownState(i)=1;
    	UpState(i)=1;
    	UpProb(i)=1;
    elseif UpState(i)==DownState(i)
    	UpProb(i)=1;
    end; % if DownState(i)>=States(i)
end; % for i=1:Dimension