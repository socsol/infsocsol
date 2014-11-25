function StateVect=SnToSVec(SNum,CVect,Dimension)
SNum=SNum-1;
StateVect=zeros(1,Dimension);
for i=Dimension:-1:1
	StateVect(i)=floor(SNum/CVect(i));
	SNum=SNum-StateVect(i)*CVect(i);
end
StateVect=StateVect+1;


