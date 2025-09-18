classdef AppModel < handle
  properties
    Vars struct = struct('ans',0);     % user variables: x,y,ans, etc.
    AngleMode char = 'rad';     % 'rad'|'deg'
    ExactMode logical = false;  % use Symbolic when true (if toolbox present)
    LastAnswer double = NaN       % for Ans recall
  end
end
