function [timeInRange, meanGlucose, stdGlucose, cvGlucose]=generateStatsFromGMdata(GlucoseConcentrations)
    % Generate outputs from CGM data:
    % timeInRange (70-180 mg/DL)
    % meanGlucose
    % stdGlucose
    % cvGlucose 
    [phat,~] = lognfit(GlucoseConcentrations);
    [meanGlucose,varGlucose]=lognstat(phat(1),phat(2));
    stdGlucose = sqrt(varGlucose);
    cvGlucose = stdGlucose/meanGlucose;
    timeInRange = 100*histcounts(GlucoseConcentrations,[70 180])/numel(GlucoseConcentrations);
end
