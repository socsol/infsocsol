function A=MatRead(matfile)
% This function reads matrices in the .DPP and .DPS files defined by
% InfSOCSol.

sz=fread(matfile,[1,2],'int64');
A=fread(matfile,sz,'float');