function [sumSqResiduals, sumWeightedGlucoses,meanAccuracy, ciAccuracy]=predictHbA1c(gluPDF_allSubjects, HbA1cTestRes, varargin)
%     X = [200, 33];
    X = [200, .008, 33];
    showPlot = 0;
%     Winf = 200; 
%     slope = .01; 
%     tau = 33; %days     
utils.overridedefaults(who,varargin)

% Winf = X(1);
Winf = X(1);
slope = X(2);
tau = X(3); %days 

% slope = 0.0005; %Now this is a hyperparameter

gluBins = evalin('base', 'gluBins');
days_relVisit = evalin('base', 'days_relVisit');

% Eqn = '1./(1+10.^(-A*(x-infPt)))';

sumGluWeights = 1./(1+10.^(-slope.*(gluBins -Winf)));
sumGluWeights = sumGluWeights./sum(sumGluWeights);
% plot(gluBins,sumGluWeights)

temporalGluWeightsMat =nan(numel(days_relVisit), numel(gluBins)); 
for gIdx = 1:numel(gluBins)
    for dIdx =1:numel(days_relVisit)
        temporalGluWeightsMat(dIdx,gIdx) = sumGluWeights(gIdx)*exp(days_relVisit(dIdx)/tau);
    end
end
temporalGluWeightsMat= temporalGluWeightsMat./sum(temporalGluWeightsMat(:));

if any(isnan(temporalGluWeightsMat))
    keyboard
end


sumWeightedGlucoses = [];
for s = 1:numel(HbA1cTestRes)
    
    gluPDF = gluPDF_allSubjects(:,:,s); %GluPDF
%     gluPDF = gluPDF./sum(gluPDF(:)); 
    gluBins_mat = repmat(gluBins, numel(days_relVisit),1); 
    weightedGlucose = temporalGluWeightsMat.* gluPDF.* gluBins_mat;
    sumWeightedGlucoses = [sumWeightedGlucoses,sum(weightedGlucose(:))];
%     pause(.0001)
end


xvar = sumWeightedGlucoses;
yvar = HbA1cTestRes;

[meanAccuracy, ciAccuracy, cVals, sumSqResiduals] = linearCV(xvar, yvar,'showPlot',0);
if showPlot == 1
    set(gca, 'tickDir', 'out','box', 'off','FontSize', 12); hold on; 
    hold on; scatter3(Winf,tau,sumSqResiduals,200,'.w')
    pause(.001)
end
% title({'HbA1c vs. \Sigma Weighted Glucoses',...
%     ['\tau = ' num2str(tau), ', infPt = ' num2str(Winf), ', slope = ', num2str(k)],... 
%     ['CV error: ' sprintf('%0.3f',CVError)]})

end