function [UserConstraintFunction, UserConstraintFunctionFile] = ...
      DetermineUserConstraintFunction(Options)

StochasticProblem = Options.StochasticProblem;
UserConstraintFunctionFile = Options.UserConstraintFunctionFile;
  
UserConstraintFunction='';
if StochasticProblem
    if isempty(UserConstraintFunctionFile)
    elseif isa(UserConstraintFunctionFile,'char')
        UserConstraintFunction=str2func(UserConstraintFunctionFile);
        UserConstraintFunctionFile='ConstFuncStoch';
    elseif isa(UserConstraintFunctionFile,'function_handle')
        UserConstraintFunction=UserConstraintFunctionFile;
        UserConstraintFunctionFile='ConstFuncStoch';
    else
        error(['Expected UserConstraintFunctionFile to be a string, a',...
            ' function handle or an empty array. Received a ',...
            class(UserConstraintFunctionFile) '.']);
    end; % if isempty(UserConstraintFunctionFile)
else
    if isempty(UserConstraintFunctionFile)
    elseif isa(UserConstraintFunctionFile,'char')
        UserConstraintFunction=str2func(UserConstraintFunctionFile);
        UserConstraintFunctionFile='ConstFuncDeter';
    elseif isa(UserConstraintFunctionFile,'function_handle')
        UserConstraintFunction=UserConstraintFunctionFile;
        UserConstraintFunctionFile='ConstFuncDeter';
    else
        error(['Expected UserConstraintFunctionFile to be a string, a',...
            ' function handle or an empty array. Received a ',...
            class(UserConstraintFunctionFile) '.']);
    end; % if isempty(UserConstraintFunctionFile)
end; % if StochasticProblem
