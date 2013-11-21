function Options = iss_conf_fmincon(ControlDimension, varargin)
  if nargin > 2 && isstruct(varargin{1})
    Options = optimset(varargin{:});
  else
    error('iss_conf_fmincon requires either a struct or a list of pairs');
  end
end
