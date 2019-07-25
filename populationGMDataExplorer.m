function populationGMDataExplorer()
global S
load('S.mat') 

%% Assess the effects of various factors on glucose variability
figure(8888)
clf
set(gcf, 'Position', [138 26 1251 740],'Name','Population analysis')

XvarNames = fieldnames(S);
XvarNames = XvarNames([6,2,3,4,5,7,8,9,10,11,12,13,15,19,21]);
YvarNames = {'CGM'; 'BGM'};

XSelectBox = uicontrol('style','text',...
            'String','Factor:',...
            'Position', [100 10 100 35]);
XSelect = uicontrol('Style', 'popup',...
           'String', [XvarNames],...
           'Position', [100 -20 200 50],...
           'Callback',@makePlots);
            XSelect.Value = 1;
            
YSelectBox = uicontrol('style','text',...
            'String','Monitoring method:',...
            'Position', [300 10 100 35]);
YSelect = uicontrol('Style', 'popup',...
           'String', YvarNames,...
           'Position', [300 -20 100 50],...
           'Callback',@makePlots);
            YSelect.Value = 1; 
            

function makePlots(source, event)
    XIdx = XSelect.Value;
    YIdX = YSelect.Value; 
    global inset1 inset2 inset3 l1 l2 l3 l4
        DependentVariableName = char(YvarNames(YIdX)); %'CGM'; % or BGM
        IndependentVariableName = char(XvarNames(XIdx)); % 'TrtGroup'; %'ScreeningVisitHbA1cTestRes AgeDecade TrtGroup Edulevel AnnualInc 
        subplot(5,2,[1,3,5,7])
        cla
        subplot(5,2,2)
        cla
        subplot(5,2,6)
        cla
        subplot(5,2,8)
        cla
        subplot(5,2,10)
        cla
        subplot(5,2,[9])
        cla
        try
            delete(inset1)
            delete(l1)
        catch
        end
        inset1 = axes('Position', [.93 .46 .05 .1]);
        xlabel(IndependentVariableName)
        ylim([70 250]);
        title('Mean [glucose]')
        hold on; 
        
        try
            delete(inset2)
            delete(l2)
        catch
        end
        inset2 = axes('Position', [.93 .29 .05 .1]);
        xlabel(IndependentVariableName)
        ylim([20 100]);
        title('StDev([glucose])')
        hold on; 
        
        try
            delete(inset3)
            delete(l3)
            delete(l4)
        catch
        end
        inset3 = axes('Position', [.93 .11 .05 .1]);
        xlabel(IndependentVariableName)
        ylim([.3 .5]);
        title('CV([glucose])')
        hold on; 


        x = eval(['[S.' IndependentVariableName ']'])';
        uniqueFactors = unique(x); 

        if strcmp(class(uniqueFactors),'categorical')
           uniqueFactors = reordercats(uniqueFactors);
           uniqueFactors = categories(uniqueFactors);
           if strcmp(IndependentVariableName,'PtStatus')
                numFactors = 1;
           else
               numFactors = numel(uniqueFactors);
           end
        end

        if strcmp(class(uniqueFactors) , 'double')
            if numel(uniqueFactors)>25
                x = discretizeVariable(x,5); %5 is the minimum bin size
                uniqueFactors = unique(x,'sorted');
                numFactors = sum(~isnan(uniqueFactors));
                spChar = '~';
            else
                spChar = '';
                numFactors = sum(~isnan(uniqueFactors));
            end
        end

        colors = jet(numFactors);
        legendEntries = {};
        
        timeInRanges = nan(numel(S),numFactors);
        meanGlucoses = nan(numel(S),numFactors);
        stdGlucoses = nan(numel(S),numFactors);
        cvGlucoses = nan(numel(S),numFactors);
        
        for f = 1:numFactors
            y = [];
            c = 0; 
            
            HourlyGlucoseLevels = [];
            HourlyGlucoseStd = [];
            HourlyGlucoseN = [];
            
            for subjIdx=1:numel(S) 
                % Investigate interactions here: ###
%                 if ~(S(subjIdx).Age< 35 && S(subjIdx).Gender == 'F')% if ~(S(s).Gender == 'F' && S(s).Age >25 && S(s).Age <45)
%                     continue
%                 end

                if x(subjIdx)==uniqueFactors(f)
                    tmpY = eval(['S(subjIdx).' DependentVariableName '.GlucoseValue']);
                    tmpX = eval(['S(subjIdx).' DependentVariableName '.Day']);
                    tmpY = tmpY(tmpX>0);
                    c = c+1; 
                    [timeInRange, meanGlucose, stdGlucose, cvGlucose]=generateStatsFromGMdata(tmpY);
                    
                    timeInRanges(c,f) = timeInRange;
                    meanGlucoses(c,f) = meanGlucose;
                    stdGlucoses(c,f) = stdGlucose;
                    cvGlucoses(c,f) = cvGlucose;
                    
                    y=[y; tmpY];
                else
                    continue
                end
                % For plotting daily Glucose fluctuations:
                HourlyGlucoseLevels = [HourlyGlucoseLevels; S(subjIdx).glucoseLevelsMean];
                HourlyGlucoseStd = [HourlyGlucoseStd; S(subjIdx).glucoseLevelsStd];
                HourlyGlucoseN = [HourlyGlucoseN; S(subjIdx).glucoseLevelsN];
            end

            if ~isempty(y) 
            subplot(5,2,[1,3,5])
                set(gca, 'TickDir', 'Out','FontSize',14,'ylim',[0 .05],'xlim',[0 600]) 
                ylabel('Probability')
                xlabel('[Glucose] (mg/dL)')
                titleStr = ['Effect of ' IndependentVariableName ' on '  DependentVariableName]; 
                assignin('base', 'titleStr',titleStr)
                title(titleStr)
                
                y(y<=0) = [];
                hold on; histogram(y,'normalization', 'probability','binWidth', 3,'edgeColor',[.5 .5 .5],'FaceColor',colors(f,:))

                if strcmp(class(uniqueFactors),'double')
                    legendEntries(end+1) = {[IndependentVariableName ':' spChar num2str(uniqueFactors(f)), ', n=' num2str(c)]};
                else
                    legendEntries(end+1) = {[IndependentVariableName ':' char(uniqueFactors(f)), ', n=' num2str(c)]};
                end
                legend(legendEntries);
            
            
            subplot(5,2,6) % Bar chart of mean glucose levels for each group
                xlim([0,numFactors+1])
                Y = nanmean(meanGlucoses(:,f));
                semY = nanstd(meanGlucoses(:,f))/sum(~isnan(meanGlucoses(:,f)));
                hold on; rectangle('Position', [f-.48 , 0, .96, Y],'FaceColor',colors(f,:))
                hold on; errorbar(f, Y, semY, semY, '.k')
                title('Mean glucose concentration')
                ylabel('[Glucose] mg/DL')
                if iscategorical(uniqueFactors)||iscell(uniqueFactors)
                    xticklabels({})
                end
                
            % plot how selected factor influences mean glucose in inset
            if iscategorical(uniqueFactors)||iscell(uniqueFactors)       
                errorbar(inset1, f,Y, semY, semY,'ok')
                    if f == numFactors && f > 2
                    x2fit = [1:numFactors]';
                    y2fit = nanmean(meanGlucoses)';
                    linFit = fit(x2fit,y2fit,'poly1');
                    [rho,p]=corr(x2fit,y2fit);
                    y2plot = linFit(x2fit);
                    hold on; plot(inset1,x2fit,y2plot,'-k')
                    params= coeffvalues(linFit);
%                     text(inset1,x2fit(1),y2plot(1)*.8,{['r= ' sprintf('%0.3g', rho)],['p= ' sprintf('%0.3g',p)]},'FontSize',10)
                    [l1,icons]=legend(['r= ' sprintf('%0.2g', rho) newline ' p= ' sprintf('%0.2g',p)],'location','NorthEastOutside');
                    delete(icons(2))
                    l1.Color = 'none';
                    elseif f == numFactors && f == 2
                        [H,p]=ttest2(meanGlucoses(:,1),meanGlucoses(:,2))
                        [l1,icons]=legend(['p= ' sprintf('%0.2g', p)],'location','NorthEastOutside');
                        delete(icons(2))
                        l1.Color = 'none';
                        l1.FontSize = 13;
                    end
            else
                errorbar(inset1, uniqueFactors(f),Y, semY, semY, 'ok')
                if f == numFactors && f > 2
                    x2fit = uniqueFactors(~isnan(uniqueFactors));
                    y2fit = nanmean(meanGlucoses)';
                    linFit = fit(x2fit,y2fit,'poly1');
                    [rho,p]=corr(x2fit,y2fit);                    
                    y2plot = linFit(x2fit);
                    hold on; plot(inset1,x2fit,y2plot,'-k')
                    params= coeffvalues(linFit);
%                     text(inset1,x2fit(1),y2plot(1)*.8,{['r= ' sprintf('%0.3g', rho)],['p= ' sprintf('%0.3g',p)]},'FontSize',10)
                    [l1,icons]=legend(['r= ' sprintf('%0.2g', rho) newline ' p= ' sprintf('%0.2g',p)],'location','NorthEastOutside');
                    delete(icons(2))
                    l1.Color = 'none';
                elseif f == numFactors && f == 2
                    [H,p]=ttest2(meanGlucoses(:,1),meanGlucoses(:,2))
                    [l1,icons]=legend(['p= ' sprintf('%0.2g', p)],'location','NorthEastOutside');
                    delete(icons(2))
                    l1.Color = 'none';
                    
                    % perform t-test 
                end
            end
                        
            subplot(5,2,8) % Bar chart of stdev glucose levels for each group
                xlim([0,numFactors+1])
                Y = nanmean(stdGlucoses(:,f));
                semY = nanstd(stdGlucoses(:,f))/sum(~isnan(stdGlucoses(:,f)));
                hold on; rectangle('Position', [f-.48 , 0, .96, Y],'FaceColor',colors(f,:))
                hold on; errorbar(f, Y, semY, semY, '.k')
                
                title('Stdev of glucose concentration')
                ylabel('Stdev([Glucose]) mg/DL')
                if iscategorical(uniqueFactors)||iscell(uniqueFactors)
                    xticklabels({})
                end
                
            % plot how selected factor influences std glucose in inset
            if iscategorical(uniqueFactors)||iscell(uniqueFactors)       
                errorbar(inset2, f,Y, semY, semY, 'ok')
                    if f == numFactors && f > 2
                    x2fit = [1:numFactors]';
                    y2fit = nanmean(stdGlucoses)';
                    linFit = fit(x2fit,y2fit,'poly1');
                    [rho,p]=corr(x2fit,y2fit);
                    y2plot = linFit(x2fit);
                    hold on; plot(inset2,x2fit,y2plot,'-k')
                    params= coeffvalues(linFit);
                    [l2,icons]=legend(['r= ' sprintf('%0.2g', rho) newline ' p= ' sprintf('%0.2g',p)],'location','NorthEastOutside');
                    delete(icons(2))
                    l2.Color = 'none';
                    elseif f == numFactors && f == 2
                        [H,p]=ttest2(stdGlucoses(:,1),stdGlucoses(:,2))
                        [l2,icons]=legend(['p= ' sprintf('%0.2g', p)],'location','NorthEastOutside');
                        delete(icons(2))
                        l2.Color = 'none';
                    end
            else
                errorbar(inset2, uniqueFactors(f),Y, semY, semY, 'ok')
                if f == numFactors && f > 2
                    x2fit = uniqueFactors(~isnan(uniqueFactors));
                    y2fit = nanmean(stdGlucoses)';
                    linFit = fit(x2fit,y2fit,'poly1');
                    [rho,p]=corr(x2fit,y2fit);
                    y2plot = linFit(x2fit);
                    hold on; plot(inset2,x2fit,y2plot,'-k')
                    params= coeffvalues(linFit);
                    [l2,icons]=legend(['r= ' sprintf('%0.2g', rho) newline ' p= ' sprintf('%0.2g',p)],'location','NorthEastOutside');
                    delete(icons(2))
                    l2.Color = 'none';
                elseif f == numFactors && f == 2
                        [H,p]=ttest2(stdGlucoses(:,1),stdGlucoses(:,2))
                        [l2,icons]=legend(['p= ' sprintf('%0.2g', p)],'location','NorthEastOutside');
                        delete(icons(2))
                        l2.Color = 'none';
                end
            end
            
            % Bar chart of glucose coefficient of variation for each group
            subplot(5,2,10) 
                xlim([0,numFactors+1])
                Y = nanmean(cvGlucoses(:,f));
                semY = nanstd(cvGlucoses(:,f))/sum(~isnan(cvGlucoses(:,f)));
                hold on; rectangle('Position', [f-.48 , 0, .96, Y],'FaceColor',colors(f,:))
                hold on; errorbar(f, Y, semY, semY, '.k')
                
                title('CV of glucose concentration')
                ylabel('CV([Glucose]) mg/DL')
                if iscategorical(uniqueFactors)||iscell(uniqueFactors)
                    xticklabels({})
                end
                
            % plot how selected factor influences glucose coefficient of
            % variation in inset:
            if iscategorical(uniqueFactors)||iscell(uniqueFactors)       
                errorbar(inset3, f,Y, semY, semY, 'ok')
                    if f == numFactors && f > 2
                    x2fit = [1:numFactors]';
                    y2fit = nanmean(cvGlucoses)';
                    linFit = fit(x2fit,y2fit,'poly1');
                    [rho,p]=corr(x2fit,y2fit);
                    y2plot = linFit(x2fit);
                    hold on; plot(inset3,x2fit,y2plot,'-k')
                    params= coeffvalues(linFit);
                    [l3,icons]=legend(['r= ' sprintf('%0.2g', rho) newline ' p= ' sprintf('%0.2g',p)],'location','NorthEastOutside');
                    delete(icons(2))
                    l3.Color = 'none';
                    elseif f == numFactors && f == 2
                        [H,p]=ttest2(cvGlucoses(:,1),cvGlucoses(:,2))
                        [l3,icons]=legend(['p= ' sprintf('%0.2g', p)],'location','NorthEastOutside');
                        delete(icons(2))
                        l3.Color = 'none';
                    end
            else
                errorbar(inset3, uniqueFactors(f),Y, semY, semY, 'ok')
                if f == numFactors && f > 2
                    x2fit = uniqueFactors(~isnan(uniqueFactors));
                    y2fit = nanmean(cvGlucoses)';
                    linFit = fit(x2fit,y2fit,'poly1');
                    [rho,p]=corr(x2fit,y2fit);
                    y2plot = linFit(x2fit);
                    hold on; plot(inset3,x2fit,y2plot,'-k')
                    params= coeffvalues(linFit);
                    [l3,icons]=legend(['r= ' sprintf('%0.2g', rho) newline ' p= ' sprintf('%0.2g',p)],'location','NorthEastOutside');
                    delete(icons(2))
                    l3.Color = 'none';
                elseif f == numFactors && f == 2
                    [H,p]=ttest2(cvGlucoses(:,1),cvGlucoses(:,2))
                    [l3,icons]=legend(['p= ' sprintf('%0.2g', p)],'location','NorthEastOutside');
                    delete(icons(2))
                    l3.Color = 'none';
                end
            end
            
            subplot(5,2,[9]) % Time in range
                xlim([0,numFactors+1])
                Y = nanmean(timeInRanges(:,f));
                semY = nanstd(timeInRanges(:,f))/sum(~isnan(timeInRanges(:,f)));
                hold on; rectangle('Position', [f-.48 , 0, .96, Y],'FaceColor',colors(f,:))
                hold on; errorbar(f, Y, semY, semY, '.k')
                
                title('Time in range (70-180mg/dL)')
                ylabel('% of time')
                ylim([0,100])
                
                if iscategorical(uniqueFactors)||iscell(uniqueFactors)
                    xticklabels({})
                    if f == numFactors && f > 2
                        x2fit = [1:numFactors]';
                        y2fit = nanmean(timeInRanges)';
                        [rho,p]=corr(x2fit,y2fit);
                        [l4,icons]=legend(['r= ' sprintf('%0.2g', rho) newline ' p= ' sprintf('%0.2g',p)],'location','NorthEastOutside');
                        delete(icons(2))
                        l4.Color = 'none';
                    elseif f == numFactors && f == 2
                        [H,p]=ttest2(timeInRanges(:,1),timeInRanges(:,2))
                        [l4,icons]=legend(['p= ' sprintf('%0.2g', p)],'location','NorthEastOutside');
                        delete(icons(2))
                        l4.Color = 'none';
                    end
                else
                    if f == numFactors && f > 2
                        x2fit = uniqueFactors(~isnan(uniqueFactors));
                        y2fit = nanmean(timeInRanges)'; 
                        [rho,p]=corr(x2fit,y2fit);
                        [l4,icons]=legend(['r= ' sprintf('%0.2g', rho) newline ' p= ' sprintf('%0.2g',p)],'location','NorthEastOutside');
                        delete(icons(2))
                        l4.Color = 'none';
                    elseif f == numFactors && f == 2
                        [H,p]=ttest2(timeInRanges(:,1),timeInRanges(:,2))
                        [l4,icons]=legend(['p= ' sprintf('%0.2g', p)],'location','NorthEastOutside');
                        delete(icons(2))
                        l4.Color = 'none';
                    end
                end
                
            %Plot mean daily glucose fluctuations:
            subplot(5,2,[2,4]) 
                stdPooled = [];
                SEMPooled = [];
                for n = 1:size(HourlyGlucoseLevels,2)
                    stdPooled = [stdPooled; sqrt(nansum(HourlyGlucoseStd(:,n).^2.*(HourlyGlucoseN(:,n) -1))/sum((HourlyGlucoseN(:,n) -1)))];
                    SEMPooled = [SEMPooled; stdPooled(end) * sqrt(nansum(1./(HourlyGlucoseN(:,n) -1)))];
                end
                if size(HourlyGlucoseLevels,1)>1
                    hold on; plots.shadedErrorBar([1:24], nanmean(HourlyGlucoseLevels),SEMPooled,'lineProps',{'-o','Color',colors(f,:)})
                else
                    hold on; plots.shadedErrorBar([1:24], HourlyGlucoseLevels,SEMPooled,'lineProps',{'-o','Color',colors(f,:)})
                end
                xticks(linspace(0, 24,5))
                xticklabels({'12AM', '6AM', '12PM', '6PM', '12AM'})
                ylabel('[Glucose] (mg/dL)')
                title('Daily glucose rhythm (from CGM)')
                set(gca, 'xticklabelmode','Manual','ylim',[100 275])
                pause(.1)
        end
        end
    
        
    end
end

% print(8888,[titleStr '.png'],'-dpng','-r300','-noui')
% print(8888,[titleStr '.png'],'-dpng','-r300')
