%% This code will examine the relationship between temporal glucose concentrations and HbA1c levels at 26 weeks
load('S.mat')
% histogram([S.Week26VisitHbA1cTestDay])
% hold on; histogram([S.Week13VisitHbA1cTestDay])

% Step 1 align CGM data to 26 week visit

for s = 1:numel(S)
    S(s).CGM.Day_rel26Week = [S(s).CGM.Day - S(s).Week26VisitHbA1cTestDay];
end

binDays = 7;
binGlu = 10; %mg/mL 
dayRange = -180:binDays:0;
gluBinEdges = [0:binGlu:400]; 
gluBins = [0:binGlu:400-binGlu]+binGlu/2; 
days_relVisit = -180:binDays:0;

%% Step 1: Examine how glucose distributions can be used to predicting HbA1c levels at 26 weeks
timeInRanges = []; 
meanGlucoses=[]; 
stdGlucoses = [];


for s = 1:numel(S)
%     [timeInRanges(s), meanGlucoses(s), stdGlucoses(s), ~]=generateStatsFromGMdata(S(s).CGM.GlucoseValue(S(s).CGM.Day_rel26Week>=-180));
    [timeInRanges(s), meanGlucoses(s), stdGlucoses(s), ~]=generateStatsFromGMdata(S(s).CGM.GlucoseValue(S(s).CGM.Day_rel26Week>=-360));
end
%
figure(1)
set(gcf, 'position', [173 544 1260 700])
subplot(2,3,[1:3])
set(gca, 'tickDir', 'out','ylim', [0, .05],'box', 'off','FontSize', 14)

[timeInRange, meanGlucose, stdGlucose, ~]=generateStatsFromGMdata(S(3).CGM.GlucoseValue(S(3).CGM.Day_rel26Week>=-180));

hold on; histogram(S(3).CGM.GlucoseValue(S(3).CGM.Day_rel26Week>=-180),'normalization', 'probability','edgecolor','none','faceColor', [.1 .5 .93])
plot([meanGlucose meanGlucose], ylim, '-k'); 
plot([meanGlucose-stdGlucose meanGlucose-stdGlucose],ylim,  '--k')
plot([meanGlucose+stdGlucose meanGlucose+stdGlucose],ylim,  '--k')
title({'Mean [Glucose] distribution','Example subject: 180 days'})
xlabel('Glucose')
ylabel('Probability')
    
subplot(2,3,4)
set(gca, 'tickDir', 'out','box', 'off','FontSize', 12); hold on; 
title({'HbA1c vs. mean [glucose]',''})
xlabel('Mean [glu] (mg/dL)'); ylabel('[HbA1c] (mmol/mL)')
xvar = meanGlucoses; 
yvar = [S.Week26VisitHbA1cTestRes];
    tmp = corrcoef(xvar, yvar);
    r = tmp(2);
    fm = fit(xvar', yvar','poly1');
    cVals = coeffvalues(fm);             
    hold on; scatter(xvar', yvar',150,'.k')
    hold on; plot(xvar, fm(xvar),'-r')
            
% [meanAccuracy, ciAccuracy, cVals,sumSqResiduals,r] = linearCV(xvar, yvar,'showPlot',0);
    text(205,7, {['R^2=' sprintf('%0.3f',r^2)],...
        ['y =' sprintf('%0.3f',cVals(1)) '*x + ' sprintf('%0.3f',cVals(2))]})
    title('HbA1c vs. mean [glucose]')%, ['Accuracy = ', sprintf('%.2f', 100*meanAccuracy), ' +/- ', sprintf('%.2f',ciAccuracy*100),'%'],['Mean sqResidual= ' sprintf('%0.3f',sumSqResiduals/numel(xvar))]})
%     xlabel('Mean [glu] (mg/dL)'); ylabel('[HbA1c] (mmol/mL)')
      
subplot(2,3,5)
set(gca, 'tickDir', 'out','box', 'off','FontSize', 12); hold on; 
title({'HbA1c vs. stdev [glucose]',''})
xlabel('stdev [glu] (mg/dL)'); ylabel('[HbA1c] (mmol/mL)')
xvar = stdGlucoses; 
yvar = [S.Week26VisitHbA1cTestRes];

% [meanAccuracy, ciAccuracy, cVals, sumSqResiduals, r] = linearCV(xvar, yvar,'showPlot',0);
    tmp = corrcoef(xvar, yvar);
    r = tmp(2);
    f = fit(xvar', yvar','poly1');
    cVals = coeffvalues(f);             
    hold on; scatter(xvar', yvar',150,'.k')
    hold on; plot(xvar, f(xvar),'-r')
    
    text(100,6.7, {['R^2=' sprintf('%0.3f',r^2)],...
        ['y =' sprintf('%0.3f',cVals(1)) '*x + ' sprintf('%0.3f',cVals(2))]})
    title('HbA1c vs. stdev [glucose]')%, ['Accuracy = ', sprintf('%.2f', 100*meanAccuracy), ' +/- ', sprintf('%.2f',ciAccuracy*100),'%'],['Mean sqResidual= ' sprintf('%0.3f',sumSqResiduals/numel(xvar))]})
%     xlabel('stdev [glu] (mg/dL)'); ylabel('[HbA1c] (mmol/mL)')
    
    
subplot(2,3,6)
set(gca, 'tickDir', 'out','box', 'off','FontSize', 12); hold on;
title({'HbA1c vs. Time in range',''})
    xlabel('Time in range (70-180 mg/dL)'); ylabel('[HbA1c] (mmol/mL)')
    
xvar = timeInRanges;
yvar = [S.Week26VisitHbA1cTestRes];

% [meanAccuracy, ciAccuracy, cVals,sumSqResiduals,r] = linearCV(xvar, yvar,'showPlot',0);
    tmp = corrcoef(xvar, yvar);
    r = tmp(2);
    f = fit(xvar', yvar','poly1');
    cVals = coeffvalues(f);             
    hold on; scatter(xvar', yvar',150,'.k')
    hold on; plot(xvar, f(xvar),'-r')
    text(5,5.5, {['R^2=' num2str(r^2)],...
        ['y =' sprintf('%0.3f',cVals(1)) '*x + ' sprintf('%0.3f',cVals(2))]})
    title('HbA1c vs. Time in range')%, ...
%         ['Accuracy = ', sprintf('%.2f', 100*meanAccuracy), ' +/- ', sprintf('%.2f',ciAccuracy*100),'%'], ['Mean sqResidual= ' sprintf('%0.3f',sumSqResiduals/numel(xvar))]})
%     xlabel('Time in range (70-180 mg/dL)'); ylabel('[HbA1c] (mmol/mL)')

%% Step 2: Create temporal glucose distribution for each subject
% binDays = 7;
% binGlu = 10; %mg/mL 
% dayRange = -180:binDays:0;

figure (2)
% set(2, 'Position', [1694 103 1082 798])
set(2, 'Position', [165 7 1082 798])



gluPDF_allSubjects = [];

% gluBinEdges = [40:binGlu:400]; 
% gluBins = [40:binGlu:400-binGlu]+binGlu/2; 
% days_relVisit = -180:binDays:0;
x = repmat(days_relVisit', 1,numel(gluBins));
y= repmat(gluBins,numel(days_relVisit),1);

for s = 1:numel(S) 
    cla
    gluPDF = [];
    c = 0;
    emptydays = [];
for d = -180:binDays:0
    c = c+1;
    idxs = find(S(s).CGM.Day_rel26Week>=d & S(s).CGM.Day_rel26Week<d+binDays);
    if isempty(idxs)
        disp(['No data for subject ' num2str(s) ' on day ' num2str(d) ' : Median [Glu] dist imputation']})
        gluPDF(c, :) = nan(1,numel(gluBins));
        emptydays = [emptydays; c];
        continue
    end
    
    gluPDF_singleTimePt= histcounts(S(s).CGM.GlucoseValue(idxs), gluBinEdges,'normalization', 'probability');
    gluPDF(c, :) = gluPDF_singleTimePt;
end
    if ~isempty(emptydays)
        gluPDF(emptydays, :) = repmat(nanmedian(gluPDF),numel(emptydays),1);
    end
    if s==1 
        subplot(2,2,1)
        set(gca, 'zlim', [0, .25])
        xlabel('Day (relative to HbA1c test)'); ylabel('[Glu]'); zlabel('probability')
        title({'Glucose probability distribution', ['Subject: ', num2str(s), ' (previous week)'] },'FontSize', 14)
        view([65 45]); hold on; 
        
        for i = fliplr(1:size(gluPDF,1))
            hold on; plot3(x(i,:),y(i,:),gluPDF(i,:),'-k')
            pause(.1)
            
            if i == size(gluPDF,1)
                pause
                view([65 45]); 
                title({'Glucose probability distribution', ['Subject: ', num2str(s)]},'FontSize', 14)
            end
        end
        pause
        surf(x,y, gluPDF,'edgecolor','none')
        xlabel('Day (relative to HbA1c test)'); ylabel('[Glu]'); zlabel('probability')
        title({'Glucose probability distribution', ['Subject: ', num2str(s)]},'FontSize', 14)
        pause
        subplot(2,2,2)
        cla
        view([65 45])
        set(gca, 'zlim', [0, .25])
        hold on;  

    else
        
%         subplot(2,2,2)   
        surf(x,y, gluPDF,'edgecolor','none')
        xlabel('Day (relative to HbA1c test)'); ylabel('[Glu]'); zlabel('probability')
        title({'Glucose probability distribution', ['Subject: ', num2str(s)]},'FontSize', 14)
        pause(.0001)
    end
    gluPDF_allSubjects(:,:,s) = gluPDF;
end

subplot(2,1,2)
% view([130.0000 38])
view([65 45])

avgGlucose = nanmean(gluPDF_allSubjects,3);
hold on; surf(x,y, avgGlucose,'edgecolor','none')
title({'Mean Glucose probability distribution', 'All Subjects'},'FontSize', 14)
xlabel('Day (relative to HbA1c test)'); ylabel('[Glu]'); zlabel('probability')

%% Step 3: Use model based machine learning model to predict HbA1c levels
% Wmax = 1;
Winf = 70.4993; 
% slope = .03;
slope = 0.05;
tau = 49.5362; %days 

% % 79.6408    0.5000   48.3805
% Winf = 1; 
% slope = .001; 
% tau = 47; %days 

% Eqn = '1./(1+10.^(-A*(x-infPt)))';

sumGluWeights = 1./(1+10.^(-slope.*(gluBins -Winf)));
sumGluWeights = sumGluWeights./sum(sumGluWeights);
%
figure(3)
set(gcf,'Position', [1687 102 1323 769])
 subplot(2,2,1)
    temporalGluWeightsMat =nan(numel(days_relVisit), numel(gluBins)); 
    for gIdx = 1:numel(gluBins)
        for dIdx =1:numel(days_relVisit)
            temporalGluWeightsMat(dIdx,gIdx) = sumGluWeights(gIdx)*exp(days_relVisit(dIdx)/tau);
        end
    end

    temporalGluWeightsMat= temporalGluWeightsMat./sum(temporalGluWeightsMat(:));

    surf(gluBins,days_relVisit, temporalGluWeightsMat)
    xlabel('[Glucose]'); ylabel({'Days', '(relative to HbA1c test)'}); zlabel({'Weight', '(rel. weight on HbA1c levels)'})
    set(gca, 'tickDir', 'out','box', 'off','FontSize', 12); hold on; 
%     view([32.5000 26.8000])
    
    title('Temporal [Glu] weights')
    view([0 0])
    ylim([-5, 0])
    plots.arrow([.8*Winf, -5, 0.003],[Winf, -5, 0.0025]) %
    text(.5*Winf, -5, 0.0031,'infPt','FontSize',12)
%     text(.75*Winf, -5, 0.0015,'slope','FontSize',12,'rotation',80)
    pause
    
    cla
    surf(gluBins,days_relVisit, temporalGluWeightsMat)
    text(400, -50, 0.0013,'\tau','FontSize',20)
    ylim([-200, 0]);
    view([90, 0])
    xlim([395, 400])
    title('Temporal [Glu] weights')
    xlabel('[Glucose]'); ylabel({'Days', '(relative to HbA1c test)'}); zlabel({'Weight', '(rel. influence on HbA1c)'})
    pause; 
    
    plots.arrow([.8*Winf, -5, 0.003],[Winf, -5, 0.0025]) %
    text(.5*Winf, -5, 0.0031,'infPt','FontSize',12)
%     text(.75*Winf, -5, 0.0015,'slope','FontSize',12,'rotation',80)
    xlim([0, 400])
    view([15 30])
    pause
    
    hold on;scatter3(215, -5, 0.004104, 200,'or', 'filled')
    t = text(315, -26, 0.005,{'T = -1 weeks', '[Glu] = ~215 mg/dL'},'FontSize',12,'FontWeight','bold');%###
    pause
    
    

    % This is defined by three parameters (inflecction point, slope, and
    % temporal decay constant')
%
sumWeightedGlucoses = [];
for s = 1:numel(S)
    %
    subplot(2,2,2)
    
    gluPDF = gluPDF_allSubjects(:,:,s); %GluPDF
%     gluPDF = gluPDF./sum(gluPDF(:)); 
    surf(gluBins,days_relVisit, gluPDF)
    xlabel('[Glucose]'); ylabel({'Days', '(relative to HbA1c test)'}); zlabel({'Probability', 'of [GLU]'})
    view([30 30])
    title({'PDF of [Glucose]',['Subject: ', num2str(s)]})
    set(gca, 'tickDir', 'out','box', 'off','FontSize', 12,'zlim',[0 .2]);%###
    
%     subplot(2,3,3)
    gluBins_mat = repmat(gluBins, numel(days_relVisit),1); 
%     surf(gluBins,days_relVisit, gluBins_mat)
%     xlabel('[Glucose]'); ylabel({'Days', '(relative to HbA1c test)'}); zlabel('[Glu]')
%     view([10 45])
%     title('[Glucose]')
%     set(gca, 'tickDir', 'out','box', 'off','FontSize', 12);


    subplot(2,3,4) % Glu Concententration and time dependent influence on HbA1c 

    weightedGlucose = temporalGluWeightsMat.* gluPDF.* gluBins_mat;
    surf(gluBins,days_relVisit, weightedGlucose)
    if sum(weightedGlucose(:)) >= 6.394 && sum(weightedGlucose(:)) < 6.6
    hold on; scatter3(225, -5, 0.07821, 200,'or', 'filled')
    hold off; 
    end
    xlabel('[Glucose]'); ylabel({'Days', '(relative to HbA1c test)'}); zlabel({'Weighted',  '[GLU]'})
    view([30 30])
    title('Relative influence on HbA1c')
    set(gca, 'tickDir', 'out','box', 'off','FontSize', 12,'zlim',[0 .15])%###


    subplot(2,3,5) % HbA1c_26wk vs. sumWeightedGlucose
    set(gca, 'tickDir', 'out','box', 'off','FontSize', 12,'zlim',[0, .1]); hold on; 
    if sum(weightedGlucose(:)) >= 6.394 && sum(weightedGlucose(:)) < 6.6
        scatter(sum(weightedGlucose(:)),S(s).Week26VisitHbA1cTestRes,400,'.r')
        pause
    else
        scatter(sum(weightedGlucose(:)),S(s).Week26VisitHbA1cTestRes,100,'.k')
    end
    xlabel('Sum of weighted [Glucose]'); ylabel('HbA1c')
    xlim([0,10]); ylim([5,11])
    sumWeightedGlucoses = [sumWeightedGlucoses,sum(weightedGlucose(:))];
    pause(.0001)
end

yvar = [S.Week26VisitHbA1cTestRes];
xvar = sumWeightedGlucoses;
set(gca, 'tickDir', 'out','box', 'off','FontSize', 12); hold on; 
[meanAccuracy, ciAccuracy, cVals,sumSqResiduals] = linearCV(xvar, yvar,'showPlot',1);

title({'HbA1c vs. \Sigma Weighted Glucoses',...
    ['\tau = ' sprintf('%0.1f',tau), ', infPt = ' sprintf('%0.1f',Winf)],... 
    ['Accuracy = ' sprintf('%0.3f',meanAccuracy*100),'%'], ['Mean sqResidual= ' sprintf('%0.3f',sumSqResiduals/numel(xvar))]})

HbA1cTestRes = [S.Week26VisitHbA1cTestRes];

% Grid search

subplot(2,3,6) 
cla
clear surfX surfY surfZ CO
    
% view([-61.6000 27.6000])
view([-76.8000 53.2000])
numSamplesTau = 15;
numSamplesInf = 15; 
colors = jet(numSamplesTau); 

title('Determining optimal parameters')
set(gca,'xlim', [0 100], 'ylim', [30 80],'zlim',[48.2 49.2])
xlabel('infPt'); ylabel('\tau','FontSize', 22); zlabel('\Sigma (Sq residual)') 
hold on; 

surfZ = nan(numSamplesInf,numSamplesTau);
% slope = 0.008; 
i = 0;
for tau = linspace(30,80,numSamplesTau)
    tau
    i = i+1; 
    j = 0; 
for infPt = linspace(0,100,numSamplesInf)
    j = j+1;
        surfX(i,j) = infPt;
        surfY(i,j) = tau; 

        X = [infPt, slope, tau];
        sumSqResiduals = predictHbA1c(gluPDF_allSubjects, HbA1cTestRes,'X',X);
        surfZ(i,j)= sumSqResiduals;
        
        hold on; scatter3(infPt, tau,sumSqResiduals,75,'.k')
        pause(.0001)
end
end
pause(.5)
hold on; surf(surfX,surfY,surfZ)
xlabel('infPt'); ylabel('\tau','FontSize', 30); zlabel('\Sigma (Sq residuals)')
    
% Gradient descent

pause

infPt0 = 70; 
tau0 = 30; 
slope0=slope; %This was constrained
% options = optimset('Display','iter','PlotFcns',@optimplotfval,'MaxIter',150);
options = optimset('Display','iter','MaxIter',150);
% [x,fval,exitflag,output] = fminsearchbnd(fun,x0,LB,UB,options,varargin)
[XResult, fvalResult] = fminsearchbnd(@(X) predictHbA1c(gluPDF_allSubjects, HbA1cTestRes,...
    'X',X,'showPlot',1),[infPt0, slope0, tau0],[0, slope, 30],[100, slope, 80],options)

subplot(2,3,6)
hold on; scatter3(XResult(1), XResult(3), fvalResult,200,'or','filled')
text(XResult(1), XResult(3)+10, 46.5, {['Tau=', sprintf('%.1f', XResult(3))],...
    ['infPt=',  sprintf('%.1f', XResult(1))]},'FontSize', 20, 'FontWeight', 'bold')
%  set(gcf,'InvertHardcopy', 'off')
% print(3,'-dpng',['ML to predict HbA1c Levels', char(datetime) ,'.png'],'-r300')

%% Determine how predictor weights change with age:

figure(4)
set(4, 'Position', [1622 179 1619 806])
clear surfX surfY surfZ CO

subplot(2,3,1)
set(gca,'box','off','FontSize', 12); hold on; 
histogram([S.Age],'binWidth', 5,'FaceColor', [.1 .5 .93])
hold on; plot([30 30],ylim,'--k','lineWidth', 2); 
plot([50 50],ylim,'--k','lineWidth', 2)
ylabel('# of patients'); xlabel('Age')
title("Age distribution")

% idxYoung = find([S.Age]<50);
idxYoung = find([S.Age]<50 & [S.Age]>=30);
idxOld = find([S.Age]>=50);

for group = 1:2
    clear surfX surfY surfZ

    if group ==1 
        idxCohort = idxYoung;
        subplot(2,3,[2])
        set(gca,'box','off','FontSize', 12); hold on; 

    elseif group == 2
        idxCohort = idxOld;
        subplot(2,3,[3])
        set(gca,'box','off','FontSize', 12); hold on; 

    end
    
    view([-61.6000 27.6000])
    numSamplesTau = 15;
    numSamplesInf = 15; 
    colors = jet(numSamplesTau); 

    xlabel('infPt'); ylabel('\tau','FontSize', 22); zlabel('\Sigma (Sq residual)') 
    hold on; 

    surfZ = nan(numSamplesTau,numSamplesInf);
%     slope = 0.03; 
    i = 0;
    for tau = linspace(15,80,numSamplesTau)
        tau
        i = i+1; 
        j = 0; 
    for infPt = linspace(0,120,numSamplesInf)
        j = j+1;
            surfX(i,j) = infPt;
            surfY(i,j) = tau; 

            X = [infPt, slope, tau];
            sumSqResiduals = predictHbA1c(gluPDF_allSubjects(:,:,idxCohort), HbA1cTestRes(idxCohort),'X',X);
            surfZ(i,j)= sumSqResiduals;
    %                 hold on; scatter3(infPt, slope,meanResidual,2,colors(k,:))
    end
    end
    hold on; surf(surfX,surfY,surfZ,'edgeColor', 'none')
    xlabel('infPt'); ylabel('\tau','FontSize', 30); zlabel('\Sigma (Sq residuals)')
    if group == 1
        title({'Determine parameters', '30 <= Age < 50'},'Color',[.1 .8 .1])
        view([-70 50])
        pause(.01)
        
        infPt0 = 50; 
        tau0 = 30; 
%         slope0=0.03;
        options = optimset('Display','iter','MaxIter',150);
        [XResult_young, fvalResult] = fminsearchbnd(@(X) predictHbA1c(gluPDF_allSubjects(:,:,idxCohort), HbA1cTestRes(idxCohort),...
        'X',X,'showPlot',1),[infPt0, slope0, tau0],[0, slope, 15],[120, slope, 80],options)
         hold on; scatter3(XResult_young(1), XResult_young(3), fvalResult,200,'or','filled')
         text(XResult_young(1), XResult_young(3)+10, fvalResult+1, {['Tau=', sprintf('%.1f', XResult(3))],...
    ['infPt=',  sprintf('%.1f', XResult(1))]},'FontSize', 20, 'FontWeight', 'bold')   
    
    elseif group == 2
        title({'Determine parameters','Age >= 50'},'Color','r')
        view([-65 40])
        pause(.01)
        infPt0 = 50; 
        tau0 = 30; 
        slope0=0.05;
        options = optimset('Display','iter','MaxIter',150);
        [XResult_old, fvalResult] = fminsearchbnd(@(X) predictHbA1c(gluPDF_allSubjects(:,:,idxCohort), HbA1cTestRes(idxCohort),...
        'X',X,'showPlot',1),[infPt0, slope0, tau0],[15, slope, 15],[100, slope, 80],options)
        hold on; scatter3(XResult_old(1), XResult_old(3), fvalResult,200,'or','filled')
        
        text(XResult_old(1), XResult_old(3)+10, fvalResult+2.5, {['Tau=', sprintf('%.1f', XResult_old(3))],...
    ['infPt=',  sprintf('%.1f', XResult_old(1))]},'FontSize', 20, 'FontWeight', 'bold')
    end
    pause(.01)
end

subplot(2,3,4) % HbA1c concentration dependence
set(gca,'box','off','FontSize', 12); hold on; 
% Young first:
title('HbA1c concentration dependence')
Winf = XResult_young(1); 
% slope = .03; 
tau_young = XResult_young(3); %days 
sumGluWeights = 1./(1+10.^(-slope.*(gluBins -Winf)));
sumGluWeights = sumGluWeights./sum(sumGluWeights);
hold on; plot(gluBins,sumGluWeights,'-g','lineWidth', 2)

% Old second: 
Winf = XResult_old(1); 
% slope = .03; 
tau_old = XResult_old(3); %days 
sumGluWeights = 1./(1+10.^(-slope.*(gluBins -Winf)));
sumGluWeights = sumGluWeights./sum(sumGluWeights);
hold on; plot(gluBins,sumGluWeights,'-r','lineWidth', 2)
set(gca,'tickDir', 'out', 'FontSize', 12)
xlabel('[Glucose]'); ylabel('Rel. weight on HbA1c levels')


subplot(2,3,5) % HbA1c time dependence
set(gca,'box','off','FontSize', 12,'tickDir', 'out'); hold on; 
title('HbA1c time dependence')
temporalWeights = exp(days_relVisit./tau_young);
hold on; plot(days_relVisit,temporalWeights,'-g','lineWidth', 2)

temporalWeights = exp(days_relVisit./tau_old);
hold on; plot(days_relVisit,temporalWeights,'-r','lineWidth', 2)
xlabel('Days from HbA1c test'); ylabel('Rel. weight on HbA1c levels')

subplot(2,3,6) %
[sumSqResiduals, sumWeightedGlucoses,meanAccuracy, ciAccuracy]=predictHbA1c(gluPDF_allSubjects(:,:,idxYoung), HbA1cTestRes(idxYoung));
hold on; scatter(sumWeightedGlucoses,HbA1cTestRes(idxYoung),15,'markerFaceColor',[.1 .5 .1],'MarkerEdgeColor','none')
text(.1,6,['MeanSqResiduals = ' sprintf('%.2f',sumSqResiduals/numel(idxYoung))],'color', 'g','FontSize', 14,'FontWeight', 'bold')
xvar = sumWeightedGlucoses; yvar = HbA1cTestRes(idxYoung); 
f = fit(xvar', yvar','poly1');
hold on; plot(xvar, f(xvar),'-g','lineWidth',2)


[sumSqResiduals, sumWeightedGlucoses,meanAccuracy, ciAccuracy]=predictHbA1c(gluPDF_allSubjects(:,:,idxOld), HbA1cTestRes(idxOld));
hold on; scatter(sumWeightedGlucoses,HbA1cTestRes(idxOld),15,'markerFaceColor','r','markeredgeColor','none')
text(.05,9,['MeanSqResiduals = ' sprintf('%.2f',sumSqResiduals/numel(idxOld))],'color', 'r','FontSize', 14,'FontWeight', 'bold')
xvar = sumWeightedGlucoses; yvar = HbA1cTestRes(idxOld); 
f = fit(xvar', yvar','poly1');
hold on; plot(xvar, f(xvar),'-r','lineWidth',2)

xlabel('\Sigma weighted [Glu]'), ylabel('Actual HbA1c levels')
title('HbA1c vs. \Sigma weighted [Glu]')
set(gca,'tickDir', 'out', 'FontSize', 12)

% set(gcf,'InvertHardcopy', 'off')
% print(4,'-dpng',['How HbA1c measurements are affected by age', char(datetime) ,'.png'],'-r300')