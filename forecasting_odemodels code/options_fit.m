% <============================================================================>
% < Author: Gerardo Chowell  ==================================================>
% <============================================================================>

function [cadfilename1,caddisease,datatype, dist1, numstartpoints,B, model, params,vars,windowsize1,tstart1,tend1,printscreen1]=options_fit


% <============================================================================>
% <=================== Declare global variables =======================================>
% <============================================================================>

global method1 % Parameter estimation method

% <============================================================================>
% <================================ Datasets properties =======================>
% <============================================================================>
% Located in the input folder, the time series data file is a text file with extension *.txt. 
% The time series data file contains the incidence curve of the epidemic of interest. 
% The first column corresponds to time index: 0,1,2, ... and the second
% column corresponds to the observed time series data.

cadfilename1='curve-EXP_GGM model-r1-0.18-r2-0.18-p-0.94-w-0.2-M-1-dist1-1-factor1-1'; % Name of the data file containing the incidence curve

%cadfilename1='curve-GLM model-r-0.18-p-0.94-K-10000-M-1-dist1-3-factor1-5'; % Name of the data file containing the incidence curve

caddisease='simulated'; % string indicating the name of the disease related to the time series data

datatype='cases'; % string indicating the nature of the data (cases, deaths, hospitalizations, etc)

% <=============================================================================>
% <=========================== Parameter estimation ============================>
% <=============================================================================>

method1=0; % Type of estimation method

% Nonlinear least squares (LSQ)=0,
% MLE Poisson=1,
% MLE (Neg Binomial)=3, with VAR=mean+alpha*mean;
% MLE (Neg Binomial)=4, with VAR=mean+alpha*mean^2;
% MLE (Neg Binomial)=5, with VAR=mean+alpha*mean^d;

dist1=0; % Define dist1 which is the type of error structure. See below:

%dist1=0; % Normal distribution to model error structure (method1=0)
%dist1=1; % Poisson error structure (method1=0 OR method1=1)
%dist1=2; % Neg. binomial error structure where var = factor1*mean where
                  % factor1 is empirically estimated from the time series
                  % data (method1=0)
%dist1=3; % MLE (Neg Binomial) with VAR=mean+alpha*mean  (method1=3)
%dist1=4; % MLE (Neg Binomial) with VAR=mean+alpha*mean^2 (method1=4)
%dist1=5; % MLE (Neg Binomial)with VAR=mean+alpha*mean^d (method1=5)


switch method1
    case 1
        dist1=1;
    case 3
        dist1=3;
    case 4
        dist1=4;
    case 5
        dist1=5;
end


numstartpoints=10; % Number of initial guesses for optimization procedure using MultiStart

B=40; % number of bootstrap realizations to characterize parameter uncertainty

% <==============================================================================>
% <============================== ODE model =====================================>
% <==============================================================================>


model.fc=@EXP_GGM;  % name of the model function
model.name='EXP_GGM model'; % string indicating the name of the ODE model

params.num=4; % number of model parameters
params.label={'r1','r2','p','w'}; % list of symbols to refer to the model parameters
params.LB=[0 0 0 0];  % lower bound values of the parameter estimates
params.UB=[10 10 1 1]; % upper bound values of the parameter estimates
params.initial=[0.18 0.18 0.94 0.2]; % initial parameter values/guesses
params.fixed=[0 0 0 0]; % Boolean vector to indicate any parameters that should remain fixed (1) to initial values indicated in params.initial. Otherwise the parameter is estimated (0).
params.fixI0=1; % Boolean variable indicating if the initial value of the fitting variable is fixed according to the first observation in the time series (1). Otherwise, it will be estimated along with other parameters.
params.composite='';  % Estimate a composite function of the individual model parameter estimates otherwise it is left empty.

vars.num=1; % number of variables comprising the ODE model
vars.label={'C'}; % list of symbols to refer to the variables included in the model
vars.initial=5; % vector of initial conditions for the model variables
vars.fit_index=1; % index of the model's variable that will be fit to the observed time series data
vars.fit_diff=1; % boolean variable to indicate if the derivative of model's fitting variable should be fit to data.

% <==================================================================================>
% <========================== Parameters of the rolling window analysis =========================>
% <==================================================================================>

windowsize1=30;  % moving window size

tstart1=1; % time point for the start of rolling window analysis

tend1=1;  %time point for the end of the rolling window analysis

printscreen1=1; % print outputs to screen (1) or not (0)

