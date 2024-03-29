function [AICcs,performanceC,fit_model1,forecast_model12,Ys]=plotFit_ODEModel(options_pass,tstart1_pass,tend1_pass,windowsize1_pass)

% <============================================================================>
% < Author: Gerardo Chowell  ==================================================>
% <============================================================================>

% plot model fit to epidemic data with quantified uncertainty

close all

% <============================================================================>
% <=================== Declare global variables ===============================>
% <============================================================================>

global method1 % Parameter estimation method

% <============================================================================>
% <=================== Load parameter values supplied by user =================>
% <============================================================================>

if exist('options_pass','var')==1 & isempty(options_pass)==0

    options=options_pass; %forecast horizon (number of data points ahead)

    [cadfilename1_INP,caddisease_INP,datatype_INP, dist1_INP, numstartpoints_INP,M_INP, model_INP, params_INP, vars_INP, windowsize1_INP,tstart1_INP,tend1_INP,printscreen1_INP]=options();

else

    [cadfilename1_INP,caddisease_INP,datatype_INP, dist1_INP, numstartpoints_INP,M_INP, model_INP, params_INP, vars_INP, windowsize1_INP,tstart1_INP,tend1_INP,printscreen1_INP]=options_fit;

end

params_INP.num=length(params_INP.label); % number of model parameters

vars_INP.num=length(vars_INP.label); % number of variables comprising the ODE model


% <============================================================================>
% <================================ Datasets properties ==============================>
% <============================================================================>

cadfilename1=cadfilename1_INP;

caddisease=caddisease_INP;

datatype=datatype_INP;

% <=============================================================================>
% <=========================== Parameter estimation ============================>
% <=============================================================================>

%method1=0; % Type of estimation method: 0 = LSQ

d=1;

dist1=dist1_INP; %Define dist1 which is the type of error structure:

if method1>0
    dist1=method1;
end

% LSQ=0,
% MLE Poisson=1,
% Pearson chi-squard=2,
% MLE (Neg Binomial)=3, with VAR=mean+alpha*mean;
% MLE (Neg Binomial)=4, with VAR=mean+alpha*mean^2;
% MLE (Neg Binomial)=5, with VAR=mean+alpha*mean^d;

% % Define dist1 which is the type of error structure:
% switch method1
%
%     case 0
%
%         dist1=0; % Normnal distribution to model error structure
%
%         %dist1=2; % error structure type (Poisson=1; NB=2)
%
%         %factor1=1; % scaling factor for VAR=factor1*mean
%
%
%     case 3
%         dist1=3; % VAR=mean+alpha*mean;
%
%     case 4
%         dist1=4; % VAR=mean+alpha*mean^2;
%
%     case 5
%         dist1=5; % VAR=mean+alpha*mean^d;
%
% end

numstartpoints=numstartpoints_INP; % Number of initial guesses for optimization procedure using MultiStart

M=M_INP; % number of bootstrap realizations to characterize parameter uncertainty

% <==============================================================================>
% <============================== ODE model =====================================>
% <==============================================================================>

model=model_INP;
params=params_INP;
vars=vars_INP;

for j=1:params.num
    if params.initial(j)<params.LB(j) | params.initial(j)>params.UB(j)
        error('values in <params.initial> should lie within their parameter bounds defined by <params.LB> and <params.UB> ')
    end
end

if length(params.label)~=params.num | length(params.fixed)~=params.num | length(params.LB)~=params.num | length(params.UB)~=params.num | length(params.initial)~=params.num
    error('one or more parameter vectors do not match the number of parameters specified in <params.num>')
end


% <==============================================================================>
% <======================== Load epiemic data ========================================>
% <==============================================================================>

data=load(strcat('./input/',cadfilename1,'.txt'));

% <==================================================================================>
% <========================== Parameters of the rolling window analysis =========================>
% <==================================================================================>

if exist('tstart1_pass','var')==1 & isempty(tstart1_pass)==0

    tstart1=tstart1_pass;

else
    tstart1=tstart1_INP;

end

if exist('tend1_pass','var')==1 & isempty(tend1_pass)==0

    tend1=tend1_pass;
else
    tend1=tend1_INP;

end

if exist('windowsize1_pass','var')==1 & isempty(windowsize1_pass)==0

    windowsize1=windowsize1_pass;
else
    windowsize1=windowsize1_INP;
end

% <=========================================================================================>
% <================================ Load short-term forecast results ==================================>
% <=========================================================================================>

factors=factor(length(tstart1:1:tend1));

if length(factors)==1
    rows=factors;
    cols=1;

elseif length(factors)==3
    rows=factors(1)*factors(2);
    cols=factors(3);
else
    rows=factors(1);
    cols=factors(2);
end

cc1=1;

paramss=[];
composite=[];

for i=tstart1:1:tend1 %rolling window analysis

    load(strcat('./output/Forecast-ODEModel-',cadfilename1,'-model_name-',model.name,'-fixI0-',num2str(params.fixI0),'-method-',num2str(method1),'-dist-',num2str(dist1),'-tstart-',num2str(i),'-tend-',num2str(tend1),'-calibrationperiod-',num2str(windowsize1),'-forecastingperiod-0.mat'))

    % <========================================================================================>
    % <======================= Plot empirical distributions of the parameters ========================>
    % <========================================================================================>

    figure(100+i)

    params1=[];
    paramslabels1=cell(1,(params.num+1)*3);

    for j=1:params.num

        subplot(2,params.num,j)
        hist(Phatss_model1(:,j))
        hold on

        %line2=[param_estims(j,2,cc1)  10;param_estims(j,3,cc1)  10];
        %line1=plot(line2(:,1),line2(:,2),'r--')
        %set(line1,'LineWidth',2)

        params1=[params1 param_estims(j,1,cc1)  param_estims(j,2,cc1) param_estims(j,3,cc1) ];

        if isempty(params.label)
            xlabel(strcat('param(',num2str(j),')'))
            cad1=strcat('param(',num2str(j),')=',num2str(param_estims(j,1,cc1),2),' (95% CI:',num2str(param_estims(j,2,cc1) ,2),',',num2str(param_estims(j,3,cc1) ,2),')');

            paramslabels1(1+(j-1)*3:j*3)={strcat('param(',num2str(j),')'), strcat('param(',num2str(j),')_95%CI LB'), strcat('param(',num2str(j),')_95%CI UB')};
        else
            xlabel(params.label(j))
            cad1=strcat(cell2mat(params.label(j)),'=',num2str(param_estims(j,1,cc1),2),' (95% CI:',num2str(param_estims(j,2,cc1) ,2),',',num2str(param_estims(j,3,cc1) ,2),')');

            paramslabels1(1+(j-1)*3:j*3)={cell2mat(params.label(j)), strcat(cell2mat(params.label(j)),'_95%CI LB'), strcat(cell2mat(params.label(j)),'_95%CI UB')};
        end

        if j==1
           ylabel('Frequency')
        end
        

        title(cad1)

        set(gca,'FontSize', 24);
        set(gcf,'color','white')

    end

    params1=[params1 param_estims(j+1,1,cc1)  param_estims(j+1,2,cc1) param_estims(j+1,3,cc1) ];
    paramslabels1(1+j*3:(j+1)*3)={strcat('X0'), strcat('X0_95%CI LB'), strcat('X0_95%CI UB')};

    if method1==3 | method1==4
        params1=[params1 param_estims(j+2,1,cc1)  param_estims(j+2,2,cc1) param_estims(j+2,3,cc1) ];
        paramslabels1(1+(j+1)*3:(j+2)*3)={strcat('alpha'), strcat('alpha_95%CI LB'), strcat('alpha_95%CI UB')};

    elseif method1==5
        params1=[params1 param_estims(j+2,1,cc1)  param_estims(j+2,2,cc1) param_estims(j+2,3,cc1) ];
        paramslabels1(1+(j+1)*3:(j+2)*3)={strcat('alpha'), strcat('alpha_95%CI LB'), strcat('alpha_95%CI UB')};

        params1=[params1 param_estims(j+3,1,cc1)  param_estims(j+3,2,cc1) param_estims(j+3,3,cc1) ];
        paramslabels1(1+(j+2)*3:(j+3)*3)={strcat('d'), strcat('d_95%CI LB'), strcat('d_95%CI UB')};
    end


    if isempty(params.composite)==0

        compositetemp=params.composite(Phatss_model1);

        composite=[composite;[median(compositetemp) quantile(compositetemp,0.025) quantile(compositetemp,0.975)]];

        figure(200+i)

        if isempty(params.composite_name)==1

            cad1=strcat('\it{estim}=',num2str(composite(end,1),3),' (95%CI:',num2str(composite(end,2),3),',',num2str(composite(end,3),3),')')
            hist(compositetemp)
            ylabel('Frequency')
            xlabel('composite parameter')
            title(cad1)

        else
            cad1=strcat('\it{',params.composite_name,'}=',num2str(composite(end,1),3),' (95%CI:',num2str(composite(end,2),3),',',num2str(composite(end,3),3),')')
            hist(compositetemp)
            ylabel('Frequency')
            xlabel(params.composite_name)
            title(cad1)
        end

        legend(params.composite_name)

        set(gca,'FontSize', 24);
        set(gcf,'color','white')

    end


    % <========================================================================================>
    % <================================ Plot model fit and forecast ======================================>
    % <========================================================================================>
    figure(100+i)

    subplot(2,params.num,[params.num+1:1:params.num*2])

    plot(timevect2,forecast_model12,'c')
    hold on

    % plot 95% PI

    line1=plot(timevect2,median1,'r-')
    set(line1,'LineWidth',2)

    hold on
    line1=plot(timevect2,LB1,'r--')
    set(line1,'LineWidth',2)

    line1=plot(timevect2,UB1,'r--')
    set(line1,'LineWidth',2)

    % plot model fit

    color1=gray(8);
    line1=plot(timevect1,fit_model1,'color',color1(6,:))
    set(line1,'LineWidth',1)

    line1=plot(timevect2,median1,'r-')
    set(line1,'LineWidth',2)

    % plot the data

    line1=plot(timevect_all,data_all,'bo')
    set(line1,'LineWidth',2)

    line2=[timevect1(end) 0;timevect1(end) max(quantile(forecast_model12',0.975))*1.5];

    if forecastingperiod>0
        line1=plot(line2(:,1),line2(:,2),'k--')
        set(line1,'LineWidth',2)
    end

    axis([timevect1(1) timevect2(end) 0 max(quantile(forecast_model12',0.975))*1.5])

    xlabel('Time')
    cad2=strcat('(',caddisease,{' '},datatype,')');

    if vars.fit_diff
        ylabel(strcat(vars.label(vars.fit_index),'''(t)',{' '},cad2))
    else
        ylabel(strcat(vars.label(vars.fit_index),'(t)',{' '},cad2))
    end


    set(gca,'FontSize',24)
    set(gcf,'color','white')

    title(model.name)


    fitdata=[timevect1 data_all(1:length(timevect1)) median1 LB1 UB1];

    T = array2table(fitdata);
    T.Properties.VariableNames(1:5) = {'time','data','median','LB','UB'};
    writetable(T,strcat('./output/Fit-model_name-',model.name,'-tstart-',num2str(i),'-fixI0-',num2str(params.fixI0),'-method-',num2str(method1),'-dist-',num2str(dist1),'-tstart-',num2str(tstart1),'-tend-',num2str(tend1),'-calibrationperiod-',num2str(windowsize1),'-horizon-',num2str(forecastingperiod),'-',caddisease,'-',datatype,'.csv'))


    if length(tstart1:1:tend1)>1
        figure(400)

        subplot(rows,cols,cc1)

        plot(timevect2,forecast_model12,'c')
        hold on

        % plot 95% PI

        LB1=quantile(forecast_model12',0.025)';
        LB1=(LB1>=0).*LB1;

        UB1=quantile(forecast_model12',0.975)';
        UB1=(UB1>=0).*UB1;

        median1=median(forecast_model12,2);

        line1=plot(timevect2,median1,'r-')
        set(line1,'LineWidth',2)

        hold on
        line1=plot(timevect2,LB1,'r--')
        set(line1,'LineWidth',2)

        line1=plot(timevect2,UB1,'r--')
        set(line1,'LineWidth',2)

        % plot model fit

        color1=gray(8);
        line1=plot(timevect1,fit_model1,'color',color1(6,:))
        set(line1,'LineWidth',1)

        % plot the data

        line1=plot(timevect_all,data_all,'bo')
        set(line1,'LineWidth',2)

        line2=[timevect1(end) 0;timevect1(end) max(quantile(forecast_model12',0.975))*1.5];

        if forecastingperiod>0
            line1=plot(line2(:,1),line2(:,2),'k--')
            set(line1,'LineWidth',2)
        end

        axis([timevect1(1) timevect2(end) 0 max(quantile(forecast_model12',0.975))*1.5])

        %xlabel('Time (days)')
        %ylabel(strcat(caddisease,{' '},datatype))

        set(gca,'FontSize',16)
        set(gcf,'color','white')

        cc1=cc1+1;

    end

    paramss=[paramss;params1];


    %% plot all state variables in a figure

    if vars.num>1

        figure(500+i)

        factor1=factor(vars.num);

        if length(factor1)==1
            rows1=1;
            cols1=factor1;
        else
            rows1=factor1(1);
            cols1=factor1(2);
        end

        cc1=1;

        for i2=1:1:vars.num

            subplot(rows1,cols1,cc1)
            %for j=1:M
            plot(quantile(cell2mat(Ys(i2,:,:))',0.5),'k-')
            hold on
            plot(quantile(cell2mat(Ys(i2,:,:))',0.025),'k--')
            plot(quantile(cell2mat(Ys(i2,:,:))',0.975),'k--')
            %end

            title(vars.label(i2))
            set(gca,'FontSize', 24);
            set(gcf,'color','white')

            cc1=cc1+1;

        end

        for j=1:1:cols1

            subplot(rows1,cols1,rows1*cols1-cols1+j)
            xlabel('Time')
        end

    end % if

    %%

end


% <=============================================================================================>
% <================= Save csv file with parameters from rolling window analysis ====================================>
% <=============================================================================================>

rollparams=[(tstart1:1:tend1)' paramss];

T = array2table(rollparams);
T.Properties.VariableNames(1)={'time'};
if method1==3 | method1==4  %save parameter alpha. VAR=mean+alpha*mean; VAR=mean+alpha*mean^2;
    T.Properties.VariableNames(2:(params.num+2)*3+1) = paramslabels1;
elseif method1==5   % save parameters alpha and d. VAR=mean+alpha*mean^d;
    T.Properties.VariableNames(2:(params.num+3)*3+1) = paramslabels1;
else
    T.Properties.VariableNames(2:(params.num+1)*3+1) = paramslabels1;
end

writetable(T,strcat('./output/parameters-rollingwindow-model_name-',model.name,'-fixI0-',num2str(params.fixI0),'-method-',num2str(method1),'-dist-',num2str(dist1),'-tstart-',num2str(tstart1),'-tend-',num2str(tend1),'-calibrationperiod-',num2str(windowsize1),'-horizon-',num2str(forecastingperiod),'-',caddisease,'-',datatype,'.csv'))

% <=============================================================================================>
% <================= Save csv file with Monte Carlo standard errors from rolling window analysis =====================>
% <=============================================================================================>

rollparams=[(tstart1:1:tend1)' MCEs(:,1:end)];
T = array2table(rollparams);

T.Properties.VariableNames(1)={'time'};

if method1==3 | method1==4  %save parameter alpha. VAR=mean+alpha*mean; VAR=mean+alpha*mean^2;
    T.Properties.VariableNames(2:(params.num+2)+1) = paramslabels1(1:3:end);
    T=T(:,1:end-1);
elseif method1==5   % save parameters alpha and d. VAR=mean+alpha*mean^d;
    T.Properties.VariableNames(2:(params.num+3)+1) =  paramslabels1(1:3:end);
else
    T.Properties.VariableNames(2:(params.num+1)+1) =  paramslabels1(1:3:end);
    T=T(:,1:end-2);
end

writetable(T,strcat('./output/MCSEs-rollingwindow-model_name-',model.name,'-fixI0-',num2str(params.fixI0),'-method-',num2str(method1),'-dist-',num2str(dist1),'-tstart-',num2str(tstart1),'-tend-',num2str(tend1),'-calibrationperiod-',num2str(windowsize1),'-horizon-',num2str(forecastingperiod),'-',caddisease,'-',datatype,'.csv'))


% <=============================================================================================>
% <================= Save csv file with composite parameter ===============================================>
% <=============================================================================================>

composite12=[(tstart1:1:tend1)' composite12];

T = array2table(composite12);
T.Properties.VariableNames(1)={'time'};
T.Properties.VariableNames(2:4) = {'composite mean','composite 95% CI LB','composite 95% CI UB'};
writetable(T,strcat('./output/parameters-composite-model_name-',model.name,'-fixI0-',num2str(params.fixI0),'-method-',num2str(method1),'-dist-',num2str(dist1),'-tstart-',num2str(tstart1),'-tend-',num2str(tend1),'-calibrationperiod-',num2str(windowsize1),'-horizon-',num2str(forecastingperiod),'-',caddisease,'-',datatype,'.csv'))

% <=====================================================================================================>
% <============================== Save file with AIC metrics ===========================================>
% <=====================================================================================================>

%[i AICc part1 part2 numparams]];

T = array2table(AICcs);
T.Properties.VariableNames(1:5) = {'time','AICc','AICc part1','AICc part2','numparams'};
writetable(T,strcat('./output/AICc-model_name-',model.name,'-fixI0-',num2str(params.fixI0),'-method-',num2str(method1),'-dist-',num2str(dist1),'-tstart-',num2str(tstart1),'-tend-',num2str(tend1),'-calibrationperiod-',num2str(windowsize1),'-horizon-',num2str(forecastingperiod),'-',caddisease,'-',datatype,'.csv'))


% <========================================================================================>
% <========================================================================================>
% <========================== Save csv file with calibration performance metrics ============================>
% <========================================================================================>
% <========================================================================================>

performanceC=[(tstart1:1:tend1)' zeros(length(MAECSS(:,1)),1)+windowsize1 MAECSS(:,end)  MSECSS(:,end) PICSS(:,end) WISCSS(:,end)];

T = array2table(performanceC);
T.Properties.VariableNames(1:6) = {'time','calibration_period','MAE','MSE','Coverage 95%PI','WIS'};
writetable(T,strcat('./output/performance-calibration-model_name-',model.name,'-fixI0-',num2str(params.fixI0),'-method-',num2str(method1),'-dist-',num2str(dist1),'-tstart-',num2str(tstart1),'-tend-',num2str(tend1),'-calibrationperiod-',num2str(windowsize1),'-horizon-',num2str(forecastingperiod),'-',caddisease,'-',datatype,'.csv'))
