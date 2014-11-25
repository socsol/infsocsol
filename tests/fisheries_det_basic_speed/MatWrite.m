function MatWrite(A,matfile)
% This function writes matrices in the .DPP and .DPS files defined by
% InfSOCSol.

sz=size(A);
fwrite(matfile,sz,'int64');
fwrite(matfile,A,'float');