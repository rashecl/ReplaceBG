% Generate MARD for each subject between CGM and BGM
load('S.mat')
CGM_RD_All = [];
CGM_MARD_All = [];

for subjIdx=1:numel(S)
        timeCGM = [S(subjIdx).CGM.Day]+(60*hour([S(subjIdx).CGM.Time])+minute([S(subjIdx).CGM.Time]))/1440;
        timeBGM = [S(subjIdx).BGM.Day]+(60*hour([S(subjIdx).BGM.Time])+minute([S(subjIdx).BGM.Time]))/1440;
        BGMGlucoseValue = [S(subjIdx).BGM.GlucoseValue];
        CGMGlucoseValue = [S(subjIdx).CGM.GlucoseValue];
        timeStart = 0;
        validInterval = 6/1440; %6 minutes in units of days

        CGM_RD_Subj = [];
        lastBGMTime = 0; 

        idxs = find(timeBGM>timeStart);
        for i = 1:numel(idxs)
            % Only examine the first BGM value if multiple BGMs were done sequentially
            % Only examine if BGM values were valid (i.e. > 20)
            if diff([lastBGMTime, timeBGM(idxs(i))]) < 10/1440 || BGMGlucoseValue(idxs(i))<20 
                continue
            end

            idx2 = find(timeCGM < timeBGM(idxs(i)),1,'last');
            if ~isempty(idx2)
                if diff([timeCGM(idx2),timeBGM(idxs(i))]) <= validInterval && diff([timeCGM(idx2),timeBGM(idxs(i))]) > 0
                    CGMdeviation = CGMGlucoseValue(idx2) - BGMGlucoseValue(idxs(i));
                    CGM_RD_Subj =[CGM_RD_Subj; 100*CGMdeviation/BGMGlucoseValue(idxs(i))];
                    lastBGMTime =  timeBGM(idxs(i));
                end
            end
        end
        CGM_MARD = mean(abs(CGM_RD_Subj));

        CGM_RD_All = [CGM_RD_All; CGM_RD_Subj];
        CGM_MARD_All = [CGM_MARD_All; CGM_MARD];
    if mod(subjIdx,10) == 0 
        subjIdx
    end
end

%% Assess the reliability of CGM sensors
% close all
figure(1); 
set(gcf,'Position', [440 345 387 453])
subplot(1,2,1)
    hold on; histogram(abs(CGM_RD_All),'FaceColor','b','edgeColor','none','BinWidth',2)
    pause(.1)
    xlim([0 50])
    xticks([0:25:50])
    ytickformat('%g')
    ylabel('Number of measurements')
    xlabel('Absolute relative difference (%)')
    set(gca,'tickDir','out','FontSize',12,'ylim',[0 120000])
    pause(.1)
    yyaxis right 
    plot([0:.1:50],exppdf([0:.1:50],expfit(abs(CGM_RD_All))),'-k','lineWidth',2)
    text(12, .06, ['\mu= ' sprintf('%.4g',expfit(abs(CGM_RD_All)))],'FontSize',14)
    set(gca,'ycolor','k','ylim',[0 .3])
    ylabel('Probability')
    title('Inter-test reliability')
    % 14.4% chance of >20% error in measurement

subplot(1,2,2) % Mean abs relative differences for each subject
    hold on; histogram(CGM_MARD_All,'FaceColor','b','edgeColor','none','BinWidth',2)
    xlabel('Mean absolute relative difference (%)')
    ylabel('Number of subjects')
    xlim([0 36])
    ylim([0 80])
    set(gca,'tickDir','out','FontSize',12)
    title('MARD of CGM for each subject')
% fit data:
    yyaxis right
    [phat,~] = lognfit(CGM_MARD_All);
    [MARD,varARD]=lognstat(phat(1),phat(2));
    x = 0:.1:35;
    y = lognpdf(x,phat(1),phat(2));
    hold on;plot(x,y,'-k','lineWidth',2)
    set(gca,'ycolor','k')
    ylabel('Probability')
    pause(.1)
    yyaxis left
    plots.arrow([mean(CGM_MARD_All) 75],[mean(CGM_MARD_All) 60])
    text(mean(CGM_MARD_All)+1, 75, ['\mu= ' sprintf('%.4g',mean(CGM_MARD_All)) ', \sigma^{2}= ' sprintf('%.2g',varARD)],'FontSize',14)
%     print('Inter-test reliability.png','-dpng', '-r300')

%% Demonstrate that CGM only increases HbA1c compared to CGM+BGM
figure(2)
    set(gcf,'Position', [440 553 610 245])

    subplot(1,2,1)
    
    BGMGroupIdxs = find([S.Age]< 35 & [S.Gender] == 'F' & [S.TrtGroup]== 'CGM+BGM');
    CGMGroupIdxs = find([S.Age]< 35 & [S.Gender] == 'F' & [S.TrtGroup]== 'CGM Only');
    err1 = std([S(CGMGroupIdxs).ScreeningVisitHbA1cTestRes])/sqrt(numel([S(CGMGroupIdxs).ScreeningVisitHbA1cTestRes]))
    err2 = std([S(BGMGroupIdxs).ScreeningVisitHbA1cTestRes])/sqrt(numel([S(BGMGroupIdxs).ScreeningVisitHbA1cTestRes]))
    hold on; bar([1 2], [mean([S(CGMGroupIdxs).ScreeningVisitHbA1cTestRes]) mean([S(BGMGroupIdxs).ScreeningVisitHbA1cTestRes])],'FaceColor',[.6 .8 .6])
    hold on; errorbar([1 2], [mean([S(CGMGroupIdxs).ScreeningVisitHbA1cTestRes]) mean([S(BGMGroupIdxs).ScreeningVisitHbA1cTestRes])],...
        [err1, err2],'.k')
    xticks([1 2])
    xticklabels({'CGM Only', 'CGM+BGM'})
    
    [H,P]=ttest2([S(BGMGroupIdxs).ScreeningVisitHbA1cTestRes],[S(CGMGroupIdxs).ScreeningVisitHbA1cTestRes])
    text(1.5, 8.5, ['p= ' num2str(P)],'FontSize',12)
    ylabel('HbA1c mmol/mL')
    set(gca,'TickDir', 'out', 'FontSize',14,'ylim', [0 10])
    title('Screening HbA1c levels')
    
    subplot(1,2,2)
    
    BGMGroupIdxs = find([S.Age]< 35 & [S.Gender] == 'F' & [S.TrtGroup]== 'CGM+BGM');
    CGMGroupIdxs = find([S.Age]< 35 & [S.Gender] == 'F' & [S.TrtGroup]== 'CGM Only');
    err1 = std([S(CGMGroupIdxs).Week26VisitHbA1cTestRes])/sqrt(numel([S(CGMGroupIdxs).Week26VisitHbA1cTestRes]));
    err2 = std([S(BGMGroupIdxs).Week26VisitHbA1cTestRes])/sqrt(numel([S(BGMGroupIdxs).Week26VisitHbA1cTestRes]));
    hold on; bar([1 2], [mean([S(CGMGroupIdxs).Week26VisitHbA1cTestRes]) mean([S(BGMGroupIdxs).Week26VisitHbA1cTestRes])],'FaceColor',[.8 .6 .6])
    hold on; errorbar([1 2], [mean([S(CGMGroupIdxs).Week26VisitHbA1cTestRes]) mean([S(BGMGroupIdxs).Week26VisitHbA1cTestRes])],...
        [err1, err2],'.k')
    [H,P]=ttest2([S(BGMGroupIdxs).Week26VisitHbA1cTestRes],[S(CGMGroupIdxs).Week26VisitHbA1cTestRes])

    text(1.5, 8.5, ['p= ' num2str(P)],'FontSize',12)
    ylabel('HbA1c mmol/mL')
    set(gca,'TickDir', 'out', 'FontSize',14,'ylim', [0 10])
    title('Week 26 HbA1c levels')
    xticks([1 2])
    xticklabels({'CGM Only', 'CGM+BGM'})
% print(2, 'Fig2-HbA1cTest.png','-dpng', '-r300')
   
