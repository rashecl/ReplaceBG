function [meanAccuracy, ciAccuracy, cVals, sumSqResiduals,r] = linearCV(xvar, yvar,varargin)
        showPlot = 0; 
    utils.overridedefaults(who, varargin)
    %%% Calculate CV accuracy:
        idxs = floor(linspace(1,numel(xvar), 6));
        scores = [];
        sumSqResiduals_CV = [];
        for i = 1:numel(idxs)-1
            x_toFit = xvar;
            x_toTest=x_toFit(idxs(i):idxs(i+1));

            x_toFit(idxs(i):idxs(i+1))= [];

            y_toFit = yvar;
            y_toTest=y_toFit(idxs(i):idxs(i+1));
            y_toFit(idxs(i):idxs(i+1))= [];

            try
                f1 = fit(x_toFit', y_toFit','poly1');
            catch
                keyboard
            end
            accuracy = 1-mean(abs(y_toTest - f1(x_toTest))/y_toTest);
            sumSqResiduals_CV =[sumSqResiduals_CV; sum((y_toTest - f1(x_toTest)').^2)];
            scores = [scores; accuracy];
            
            if showPlot ==1 
                hold on; scatter(x_toFit,y_toFit,150,'.b')
                hold on; plot(x_toFit, f1(x_toFit),'-k')
                hold on; scatter(x_toTest, y_toTest,150,'.r') 
                pause(.5)
                cla
            end
        end
        meanAccuracy = mean(scores); 
        sumSqResiduals = sum(sumSqResiduals_CV);
        ciAccuracy = std(scores)*2; 
        
            tmp = corrcoef(xvar, yvar);
            r = tmp(2);
            f = fit(xvar', yvar','poly1');
            cVals = coeffvalues(f); 
            
        if showPlot == 1
            hold on; scatter(xvar', yvar',150,'.k')
            hold on; plot(xvar, f(xvar),'-r')

        end
end
