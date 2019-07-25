function individualGMDataExplorer()
global S
load('S.mat')

figure(9999); 
set(gcf, 'Position', [138 26 1251 740],'Name','Individual subject glucose levels')

subjects = strsplit(num2str([S.PtID]))'; 

% selectionVarNames = fieldnames(S);
% selectionVarNames = selectionVarNames(2:13);
% 
% subjectFilterBox = uicontrol('style','text',...
%             'String','Filter criteria:',...
%             'Position', [100 10 100 35]);
% subjectFilter = uicontrol('Style', 'popup',...
%            'String', ['Criteria'; selectionVarNames],...
%            'Position', [100 -20 100 50,...
%             'Callback',@refilter];
%             subjectFilter.Value = 1;

subjectSelectBox = uicontrol('style','text',...
            'String','Subject:',...
            'Position', [100 10 100 35]);
subjectSelect = uicontrol('Style', 'popup',...
           'String', ['Subjects'; subjects],...
           'Position', [100 -20 100 50],...
           'Callback',@makePlots);
            subjectSelect.Value = 1;

            


    function makePlots(source, event)
        global showBolusButton timeVectorBolus CGMGlucoseValue timeVectorCGM
        try
            delete(showBolusButton)
        catch
        end
        subjIdx = subjectSelect.Value - 1;
        %% Plot subject's CGM data (since enrollment): 
        subplot(3,4,[1:3]) %CGM values     
            cla
            timeVectorCGM = [S(subjIdx).CGM.Day]+(60*hour([S(subjIdx).CGM.Time])+minute([S(subjIdx).CGM.Time]))/1440;
            timeVectorBolus = [S(subjIdx).Bolus.Day]+(60*hour([S(subjIdx).Bolus.Time])+minute([S(subjIdx).Bolus.Time]))/1440;
            timeVectorBolus = timeVectorBolus(timeVectorBolus>0); 
        %     timeVectorCGM = timeVectorCGM(timeVectorCGM>0);


            CGMGlucoseValue = [S(subjIdx).CGM.GlucoseValue];
            excludeIdxs = [find(timeVectorCGM<0); find(CGMGlucoseValue< 40 | CGMGlucoseValue> 400)]; % Exclude data prior to enrollment
            timeVectorCGM(excludeIdxs) = [];
            CGMGlucoseValue(excludeIdxs) = [];

%             idx = find([0; diff(timeVectorCGM)]>.035); %determine CGM replacement time
%             CGMReplacementTime = timeVectorCGM(idx);

            plot(timeVectorCGM, CGMGlucoseValue,'b'); 
            set(gca, 'TickDir', 'out', 'FontSize', 11, 'box', 'off','xlim', [timeVectorCGM(end)-14 timeVectorCGM(end)],'ylim',[0,400])
            xlabel('Days since enrollment')
            ylabel('Glucose Value (mg/dL)')
            title({['Subject ' num2str(S(subjIdx).PtID)], 'CGM Glucose Values'})

            % Create a button to plot bolus
            showBolusButton = uicontrol('Style','radiobutton',...
            'String','ShowBolus',...
            'Position', [725 690 100 30],...
            'Callback',@showBolus);
            showBolusButton.Value = 0;

        subplot(3,4,[5:7]) % BGM values
            cla
            timeVectorBGM = [S(subjIdx).BGM.Day]+(60*hour([S(subjIdx).BGM.Time])+minute([S(subjIdx).BGM.Time]))/1440;
            BGMGlucoseValue = [S(subjIdx).BGM.GlucoseValue];
            excludeIdxs = [find(timeVectorBGM<0); find(BGMGlucoseValue< 40 | BGMGlucoseValue> 400)]; % Exclude data prior to enrollment
            timeVectorBGM(excludeIdxs) = [];

            BGMGlucoseValue(excludeIdxs) = [];
            plot(timeVectorBGM, BGMGlucoseValue, 'r'); 
            set(gca, 'TickDir', 'out', 'FontSize', 11, 'box', 'off','xlim', [timeVectorCGM(end)-14 timeVectorCGM(end)])
            xlabel('Days since enrollment')
            ylabel('Glucose Value (mg/dL)')
            title('BGM Glucose Values')

        subplot(3,4,4) % Histogram of overall CGM and BGM values
            cla
            histogram(CGMGlucoseValue,'binWidth', 10, 'Normalization','probability','EdgeColor', [.7 .7 .7],'FaceColor','b')
            hold on; histogram(BGMGlucoseValue, 'binWidth', 10, 'Normalization','probability','EdgeColor', [.7 .7 .7],'FaceColor','r')

            xlim([0 500])
            set(gca, 'TickDir', 'out', 'FontSize', 11, 'box', 'off')
            legend({'CGM', 'BGM'},'Location', 'NorthEast','EdgeColor', 'none')
            xlabel('Glucose Value (mg/dL)')
            ylabel('Probability')
            title('Distribution of Glucose Values')

        %     coeffVarInset=axes('Position', [.87 .75 .05 .05]);
        %     CGMCoeffVar = std(CGMGlucoseValue)/mean(CGMGlucoseValue);
        %     SE_CGMCoeffVar = CGMCoeffVar/sqrt(2*numel(CGMGlucoseValue));%     
        %     BGMCoeffVar = std(BGMGlucoseValue)/mean(BGMGlucoseValue);
        %     SE_BGMCoeffVar = BGMCoeffVar/sqrt(2*numel(BGMGlucoseValue));

        %     bar([1 2], [CGMCoeffVar, BGMCoeffVar])
        %     hold on; errorbar([1 2], [CGMCoeffVar, BGMCoeffVar],[SE_CGMCoeffVar, SE_BGMCoeffVar],...
        %         [SE_CGMCoeffVar, SE_BGMCoeffVar],'.')
        %     xlim([0,3])
        %     xticks([1,2])
        %     xticklabels({'CGM','BGM'}); xtickangle(45)
        %     title({'Coeff. of','Variation'},'FontSize',10)
        %     set(gca,'TickDir', 'out', 'box', 'off')


        %% Check if device was properly calibrated the last 7 days

        subplot(3,4,8) % Correlation of BGM value with CGM value in the last 6 minutes: data from 7 days
            cla
            timeStart = floor(timeVectorBGM(end) - 7);
            % timeEnd = (timeVectorBGM(end));
            validInterval = 6/1440; %6 minutes in units of days
            idxs = find(timeVectorBGM>timeStart);
            x = [];
            y = [];
            CGMdeviations = [];
            CGMdeviationsPercent = [];

            timeCGMDeviation = [];
            lastBGMTime = 0; 

            for i = 1:numel(idxs)
                %Only examine the first BGM value if doing multiple sequentially:
                if diff([lastBGMTime, timeVectorBGM(idxs(i))]) < 10/1440 
                    continue
                end
                %1 Only examine BGM values if no Boluses in the last __ minutes
        %         if diff([lastBGMTime, timeVectorBGM(idxs(i))) < 150/1440
        %             continue
        %         end


                idx2 = find(timeVectorCGM < timeVectorBGM(idxs(i)),1,'last');
                if ~isempty(idx2)
                    if diff([timeVectorCGM(idx2),timeVectorBGM(idxs(i))]) <= validInterval
                        x = [x, BGMGlucoseValue(idxs(i))]; 
                        y = [y, CGMGlucoseValue(idx2)];

                        CGMdeviation = CGMGlucoseValue(idx2) - BGMGlucoseValue(idxs(i));
                        timeCGMDeviation =[timeCGMDeviation, timeVectorCGM(idx2)];
                        CGMdeviations =[CGMdeviations, CGMdeviation];
                        CGMdeviationsPercent =[CGMdeviationsPercent, 100*CGMdeviation/BGMGlucoseValue(idxs(i))];
                        lastBGMTime =  timeVectorBGM(idxs(i));
                    end
                end
            end
            spec = 20; % Assume < 10% error is desirable
            percentRecordsOutOfSpec = 100*(numel(find(abs(CGMdeviationsPercent)>spec))/numel(CGMdeviationsPercent));
            MARD_7d = mean(abs(CGMdeviationsPercent));
            scatter(x,y,'.')
            hold on; plot([0 500],[0 500],'k') 
            hold on; plot([0 500],(1+.01*spec)*([0 500]),'-r') % error upper limit
            hold on; plot([0 500],(1-.01*spec)*([0 500]),'-r')% error lower limit

            if MARD_7d > spec
                % This occurs for subject 229
                warning(['Subject ', num2str(S(subjIdx).PtID), ': MARD=',...
                    num2str(MARD_7d) '%. Ensure that device is working.'])
                text(500, 600, 'Device status:','FontSize',13,'color','k')
                text(500, 555, 'Not Working','FontSize',13,'FontWeight','bold','color','r')
            else
                text(500, 600, 'Device status:','FontSize',13,'color','k')
                text(500, 555, 'OK','FontSize',13,'FontWeight','bold','color','g')
            end


            text(100, 25, [num2str(percentRecordsOutOfSpec) '% of CGM vals out of spec'])
            title('CGM vs. BGM values (7 days)')
            xlabel('BGM glucose value (mg/dL)')
            ylabel('CGM glucose value (mg/dL)')
            set(gca, 'TickDir', 'out', 'box', 'off')

            deviationsHist7d_Inset = axes('Position', [.77 .57 .05 .05]);
                cla
                hold on; histogram(CGMdeviationsPercent,'Normalization','Probability','binWidth',5)
                text(0,.4, ['\sigma: ' sprintf('%0.3g',std(CGMdeviationsPercent)) ,'%'])
                text(40,.25, ['MARD: ' sprintf('%0.3g',MARD_7d) ,'%'])
                xlim([-50,50])
                ylim([0,.5])
                xlabel('% deviation')
                ylabel('probability')
                set(gca, 'TickDir', 'out', 'box', 'off','FontSize',8)


        %% Assess how the device performed over time compared to BGM

        subplot(3,4,12) % Correlation of BGM value with CGM value in the last 6 minutes: Data since enrollment
            cla
            timeStart = 0;
            % timeEnd = (timeVectorBGM(end));
            validInterval = 6/1440; %6 minutes in units of days
            idxs = find(timeVectorBGM>timeStart);
            x = [];
            y = [];
            CGMdeviations = [];
            CGMdeviationsPercent = [];

            timeCGMDeviation = [];
            lastBGMTime = 0; 

            for i = 1:numel(idxs)
                if diff([lastBGMTime, timeVectorBGM(idxs(i))]) < 10/1440 %Only examine the first BGM value if doing multiple sequentially
                    continue
                end

                idx2 = find(timeVectorCGM < timeVectorBGM(idxs(i)),1,'last');
                if ~isempty(idx2)
                    if diff([timeVectorCGM(idx2),timeVectorBGM(idxs(i))]) <= validInterval
                        x = [x, BGMGlucoseValue(idxs(i))]; 
                        y = [y, CGMGlucoseValue(idx2)];

                        CGMdeviation = CGMGlucoseValue(idx2) - BGMGlucoseValue(idxs(i));
                        timeCGMDeviation =[timeCGMDeviation, timeVectorCGM(idx2)];
                        CGMdeviations =[CGMdeviations, CGMdeviation];
                        CGMdeviationsPercent =[CGMdeviationsPercent, 100*CGMdeviation/BGMGlucoseValue(idxs(i))];
                        lastBGMTime =  timeVectorBGM(idxs(i));
                    end
                end
            end
            spec = 20; % Assume < 10% error is desirable
            percentRecordsOutOfSpec = 100*(numel(find(abs(CGMdeviationsPercent)>spec))/numel(CGMdeviationsPercent));
            MARD_overall = mean(abs(CGMdeviationsPercent));
            scatter(x,y,'.')
            hold on; plot([0 500],[0 500],'k') 
            hold on; plot([0 500],(1+.01*spec)*([0 500]),'-r') % error upper limit
            hold on; plot([0 500],(1-.01*spec)*([0 500]),'-r')% error lower limit

        %     if percentRecordsOutOfSpec > 25
        %         warning(['Subject ', num2str(S(subjIdx).PtID), ': ',...
        %             num2str(percentRecordsOutOfSpec) '% of CGM values are less than ' num2str(100-spec) '% accurate'])
        %     end

            text(100, 25, [num2str(percentRecordsOutOfSpec) '% of CGM vals out of spec'])
            title('CGM vs. BGM values (Since enrollment)')
            xlabel('BGM glucose value (mg/dL)')
            ylabel('CGM glucose value (mg/dL)')
            set(gca, 'TickDir', 'out', 'box', 'off')

        subplot(3,4,[9:11]) % plot deviations since enrollment
            cla
            hold on; plot(timeCGMDeviation, CGMdeviationsPercent,'-k.','MarkerFaceColor', 'k','MarkerSize', 1)
        %     for i = 1:numel(CGMReplacementTime)
        %         plots.arrow([CGMReplacementTime(i) -75], [CGMReplacementTime(i) -50],'tipangle',10,'length', 15)
        %     end
        %     text(timeCGMDeviation(end)/2, -90, 'Replaced CGM device')
            hold on; plot([timeCGMDeviation(1) timeCGMDeviation(end)], [0 0], '--k','color', [.5 .5 .5])
            xlabel('Days since enrollment')
            ylabel('% deviation')
            title({'% Deviation of CGM from BGM glucose values'})
            set(gca, 'TickDir', 'out', 'FontSize', 11, 'box', 'off','xlim', [timeVectorCGM(end)-14 timeVectorCGM(end)])

        % CGMDeviationsSinceDeviceReplacement_Inset = axes('Position', [.4 .27 .2 .05]);
        %     cla
        %     CGMDeviationsSinceDeviceReplacement = nan(numel(CGMReplacementTime)-1,200);
        %     TimeSinceDeviceReplacement = nan(numel(CGMReplacementTime)-1,200);
        %     for i = 1:numel(CGMReplacementTime)-1
        %         idxs = find(timeCGMDeviation>CGMReplacementTime(i) & timeCGMDeviation<CGMReplacementTime(i+1));
        %         CGMDeviationsSinceDeviceReplacement(i,1:numel(idxs)) = CGMdeviationsPercent(idxs);
        %         TimeSinceDeviceReplacement(i,1:numel(idxs)) = (timeCGMDeviation(idxs)- CGMReplacementTime(i))*1440;
        %     end
        %     timeHist = 150:300:20000;
        %     CGMDeviationsSinceDeviceReplacementHist = nan(1,numel(timeHist));
        %     CGMDeviationsSinceDeviceReplacementHistSEM = nan(1,numel(timeHist));
        %     c = 1; 
        %     for t = timeHist
        %         i= find(TimeSinceDeviceReplacement>t-149 & TimeSinceDeviceReplacement<t+150);
        %         if ~isempty(i)
        %             CGMDeviationsSinceDeviceReplacementHist(c) = nanmean(CGMDeviationsSinceDeviceReplacement(i));
        %             CGMDeviationsSinceDeviceReplacementHistSEM(c) = nanstd(CGMDeviationsSinceDeviceReplacement(i))/sqrt(numel(i));
        %         end
        %         c = c+1;
        %     end
        %     errorbar(timeHist, CGMDeviationsSinceDeviceReplacementHist,CGMDeviationsSinceDeviceReplacementHistSEM,CGMDeviationsSinceDeviceReplacementHistSEM)
        %     hold on; plot(xlim, [0 0], 'color', [.5 .5 .5])
        %     xlabel('Time since device replacement (minutes)')
        %     ylabel({'Mean', 'deviation (%)'})
        %     set(gca, 'TickDir', 'out', 'box', 'off','FontSize',8)



        deviationsHistOverall_Inset = axes('Position', [.77 .27 .05 .05]);
            cla
            hold on; histogram(CGMdeviationsPercent,'Normalization','Probability','binWidth',5)
            text(0,.4, ['\sigma: ' sprintf('%0.3g',std(CGMdeviationsPercent)) ,'%'])
            text(40,.25, ['MARD: ' sprintf('%0.3g',MARD_overall) ,'%'])
            xlim([-50,50])
            ylim([0,.5])
            xlabel('% deviation')
            ylabel('probability')
            set(gca, 'TickDir', 'out', 'box', 'off','FontSize',8)
        % clearvars -except S
    end

    function showBolus(source,event)
        global timeVectorBolus CGMGlucoseValue timeVectorCGM showBolusButton
        showBolusButtonVal = showBolusButton.Value;
        switch showBolusButtonVal
            case 0
                try
%                 delete(findobj('Tag','arrows'))
                delete(findobj('tag','quivertag'))
                catch
                    keyboard
                end
            case 1

                subplot(3,4,[1:3])
                for i = 1:numel(timeVectorBolus)
                    idx = find(timeVectorCGM>timeVectorBolus(i),1);
                    if ~isempty(idx)
                        if idx >1
%                             figure
                            hold on; quiver(timeVectorBolus(i), CGMGlucoseValue(idx-1)+25, 0, -25,0,'tag','quivertag','color','g','MarkerSize', 30,'MaxHeadSize', .04,'lineWidth',2);
                            
%                             plots.arrow([timeVectorBolus(i) CGMGlucoseValue(idx-1)+25], [timeVectorBolus(i) CGMGlucoseValue(idx-1)],'color','g','tipangle',15,'length', 7.5,'tag','arrows')
                        else
                            hold on; quiver(timeVectorBolus(i), CGMGlucoseValue(idx)+25, 0, -25,0,'tag','quivertag','color','g','MarkerSize', 30,'MaxHeadSize', .04,'lineWidth',2);
%                             plots.arrow([timeVectorBolus(i) CGMGlucoseValue(idx)+25], [timeVectorBolus(i) CGMGlucoseValue(idx)],'color','g','tipangle',15,'length', 7.5,'tag','arrows')
                        end
                    else
                        hold on; quiver(timeVectorBolus(i), CGMGlucoseValue(idx)+25, 0, -25,0,'tag','quivertag','color','g','MarkerSize', 30,'MaxHeadSize', .04,'lineWidth',2);
%                         plots.arrow([timeVectorBolus(i) CGMGlucoseValue(idx-1)+25], [timeVectorBolus(i) CGMGlucoseValue(end-1)],'color','g','tipangle',15,'length', 7.5)
                    end
            %         hold on; plot([timeVectorBolus(i) timeVectorBolus(i)],[ylim],'-g')
                end
%                 hold on; plots.arrow([timeVectorCGM(end)-1 350],[timeVectorCGM(end)-1 325],'color','g','tipangle',15,'length', 7.5)
%                 hold on; text(timeVectorCGM(end)-.8, 337,'Bolus', 'FontWeight', 'bold', 'FontSize', 14,'Color', 'g')
%                 rectangle('Position', [timeVectorCGM(end)-1.2 320 1.2 40],'FaceColor','none')
        end
    end    
end

% print(9999,['IndividualData' '_229' '.png'],'-dpng','-r300')
