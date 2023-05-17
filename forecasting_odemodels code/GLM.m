% <============================================================================>
% < Author: Gerardo Chowell  ==================================================>
% <============================================================================>

function dx=GLM(t,x,params0)

% params0(1)=r, params0(2)=p, params0(3)=K 

% GLM model
dx(1,1)=params0(1).*(x(1,1).^params0(2)).*(1-(x(1,1)/params0(3)));




