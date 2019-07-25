addpath('DataTables')

%%
clear all
ImportHDeviceIssue
save('DataTables/HDeviceIssue.mat', 'HDeviceIssue')
display('Finished loading HDeviceIssue')
pause(1)
 
%%
clear all
ImportHLocalHbA1c
save('DataTables/HLocalHbA1c.mat', 'HLocalHbA1c')
display('Finished loading HLocalHbA1c')
pause(1)
% 
%%
clear all
ImportHScreening
save('DataTables/HScreening.mat', 'HScreening')
display('Finished loading HScreening')
pause(1)
% 
%% 
clear all
ImportHPtRoster
save('DataTables/HPtRoster.mat', 'HPtRoster')
display('Finished loading HPtRoster')
pause(1)

%%
clear all
ImportHDeviceBGM
save('DataTables/HDeviceBGM.mat', 'HDeviceBGM')
display('Finished loading HDeviceBGM')
pause(1)

%%
clear all
ImportHDeviceBolus
save('DataTables/HDeviceBolus.mat', 'HDeviceBolus')
display('Finished loading HDeviceBolus')
pause(1)

%%
clear all
ImportHDeviceCGM
save('DataTables/HDeviceCGM.mat', 'HDeviceCGM')
display('Finished loading HDeviceCGM')
pause(1)

%%
clear all
ImportHMedication
save('DataTables/HMedication.mat', 'HMedication')
display('Finished loading HDeviceCGM')
pause(1)

%%
clear all
ImportHMedicalCondition
save('DataTables/HMedicalCondition.mat', 'HMedicalCondition')
display('Finished loading HDeviceCGM')
pause(1)

clear all

%% Patient roster
display('Task (1/12): Incorporating clinical trial meta data into structure')

load('DataTables/HPtRoster.mat')
for subjIdx  = 1:size(HPtRoster,1)
    S(subjIdx).PtID = HPtRoster.PtID(subjIdx);
    S(subjIdx).SiteID = HPtRoster.SiteID(subjIdx);
    S(subjIdx).Age = HPtRoster.AgeAsOfEnrollDt(subjIdx);
    S(subjIdx).AgeDecade = floor(HPtRoster.AgeAsOfEnrollDt(subjIdx)/10)*10;
    S(subjIdx).TrtGroup = HPtRoster.TrtGroup(subjIdx);
    S(subjIdx).PtStatus = HPtRoster.PtStatus(subjIdx); % Might want to consider dropping incomplete
    
    if mod(subjIdx,10) == 0
        display([num2str(100*subjIdx/size(HPtRoster,1)) '% of records complete'])
    end
end




%% Demographics
display('Task (2/12): Incorporating demographic information into structure')

load('DataTables/HScreening.mat')
for recIdx=1:size(HScreening,1)
    subjIdx = find(HScreening.PtID(recIdx)==[S.PtID]);
    S(subjIdx).Gender = HScreening.Gender(recIdx);
    S(subjIdx).Weight = HScreening.Weight(recIdx);
    S(subjIdx).Height = HScreening.Height(recIdx);
    S(subjIdx).BMI = 10000*HScreening.Weight(recIdx)/(HScreening.Height(recIdx)^2);
    
    S(subjIdx).DiagAge = HScreening.DiagAge(recIdx);
    
    % Education level
    if HScreening.EduLevel(recIdx)==cellstr("High school graduate/diploma/GED")
        S(subjIdx).EduLevel = categorical(cellstr("A) High school graduate/diploma/GED"));
    elseif HScreening.EduLevel(recIdx)==cellstr("Some college but no degree")
        S(subjIdx).EduLevel = categorical(cellstr("B) Some college but no degree"));
    elseif HScreening.EduLevel(recIdx)==cellstr("Associate Degree")
        S(subjIdx).EduLevel = categorical(cellstr("C) Associate Degree"));
    elseif HScreening.EduLevel(recIdx)==cellstr("Bachelor's Degree")
        S(subjIdx).EduLevel = categorical(cellstr("D) Bachelor's Degree"));
    elseif HScreening.EduLevel(recIdx)==cellstr("Master's Degree")
        S(subjIdx).EduLevel = categorical(cellstr("E) Master's Degree"));
    elseif HScreening.EduLevel(recIdx)==cellstr("Professional Degree")
        S(subjIdx).EduLevel = categorical(cellstr("F) Professional Degree"));
    elseif HScreening.EduLevel(recIdx)==cellstr("Doctorate Degree")
        S(subjIdx).EduLevel = categorical(cellstr("G) Doctorate Degree"));
    else
        S(subjIdx).EduLevel = categorical(cellstr(""));
    end
        
    
    % Annual Income
    if HScreening.AnnualInc(recIdx)==cellstr("Less than $25,000")
        S(subjIdx).AnnualInc = categorical(cellstr("A) <25k"));
    elseif HScreening.AnnualInc(recIdx)==cellstr("$25,000 - $35,000")
        S(subjIdx).AnnualInc = categorical(cellstr("B) 25k - 35k"));
    elseif HScreening.AnnualInc(recIdx)==cellstr("$35,000 - less than $50,000")
        S(subjIdx).AnnualInc = categorical(cellstr("C) 35k - 50k"));
    elseif HScreening.AnnualInc(recIdx)==cellstr("$50,000 - less than $75,000")
        S(subjIdx).AnnualInc = categorical(cellstr("D) 50k - 75k"));
    elseif HScreening.AnnualInc(recIdx)==cellstr("$75,000 - less than $100,000")
        S(subjIdx).AnnualInc = categorical(categorical(cellstr("E) 75k - 100k")));
    elseif HScreening.AnnualInc(recIdx)==cellstr("$100,000 - less than $200,000")
        S(subjIdx).AnnualInc = categorical(cellstr("F) 100k - 200k"));
    elseif HScreening.AnnualInc(recIdx)==cellstr("$200,000 or more ")
        S(subjIdx).AnnualInc = categorical(cellstr("G) >200k"));
    else
        S(subjIdx).AnnualInc = categorical(cellstr(""));
    end
    
    if mod(recIdx,10) == 0
        display([num2str(100*recIdx/size(HScreening,1)) '% of records complete'])
    end
end

%% Prexisting conditions
display('Task (3/12): Incorporating Medical Conditions into structure')

load('DataTables/HMedicalCondition.mat')
S(1).MedConds = {''};
for recIdx = 1:size(HMedicalCondition,1)
    subjIdx = find(HMedicalCondition.PtId(recIdx)==[S.PtID]);
    S(subjIdx).MedConds(1,end+1) = {HMedicalCondition.MedCond(recIdx)};
    if mod(recIdx,50) == 0
        display([num2str(100*recIdx/size(HScreening,1)) '% of records complete'])
    end
%     categories(HMedicalCondition.MedCond)
end

%% HbA1c Levels
display('Task (4/12): Incorporating HbA1c data into structure')

load('DataTables/HLocalHbA1c.mat')

for recIdx=1:size(HLocalHbA1c,1)
    subjIdx = find(HLocalHbA1c.PtID(recIdx)==[S.PtID]);
    if HLocalHbA1c.Visit(recIdx) == 'Screening Visit'
        
        S(subjIdx).ScreeningVisitHbA1cTestRes = HLocalHbA1c.HbA1cTestRes(recIdx);
        S(subjIdx).ScreeningVisitHbA1cTestDay = HLocalHbA1c.HbA1cTestDtDaysAfterEnroll(recIdx);
    elseif HLocalHbA1c.Visit(recIdx) == 'Randomization'
        S(subjIdx).RandomizationHbA1cTestRes = HLocalHbA1c.HbA1cTestRes(recIdx);
        S(subjIdx).RandomizationHbA1cTestDay = HLocalHbA1c.HbA1cTestDtDaysAfterEnroll(recIdx);
    
    elseif HLocalHbA1c.Visit(recIdx) == 'Week 13 Visit'
        S(subjIdx).Week13VisitHbA1cTestRes = HLocalHbA1c.HbA1cTestRes(recIdx);
        S(subjIdx).Week13VisitHbA1cTestDay = HLocalHbA1c.HbA1cTestDtDaysAfterEnroll(recIdx);
    
    elseif HLocalHbA1c.Visit(recIdx) == 'Week 26 Visit'
        S(subjIdx).Week26VisitHbA1cTestRes = HLocalHbA1c.HbA1cTestRes(recIdx);
        S(subjIdx).Week26VisitHbA1cTestDay = HLocalHbA1c.HbA1cTestDtDaysAfterEnroll(recIdx);
    end
    
    if mod(recIdx,50) == 0
        display([num2str(100*recIdx/size(HLocalHbA1c,1)) '% of records complete'])
    end
end

%% Bolus 
display('Task (5/12): Incorporating Bolus data into structure')

load('DataTables/HDeviceBolus.mat')
subjids = unique(HDeviceBolus.PtID);

for s = 1:numel(subjids)
    subjid = subjids(s); 
    idxs = find(HDeviceBolus.PtID==subjid);
    Bolus = table(HDeviceBolus.DeviceDtTmDaysFromEnroll(idxs),HDeviceBolus.DeviceTm(idxs),HDeviceBolus.Normal(idxs),HDeviceBolus.BolusType(idxs),HDeviceBolus.Duration(idxs),...
    'VariableNames', {'Day', 'Time', 'Normal', 'BolusType', 'Duration'});

    subjIdx = find(subjid==[S.PtID]);
    Bolus = sortrows(Bolus,{'Day','Time'});
    S(subjIdx).Bolus = Bolus;
    
    if mod(s,3) == 0
        display([num2str(100*s/numel(subjids)) '% of subjects complete'])
    end
end

clear BolusTable

%% BGM
display('Task (6/12): Incorporating BGM data into structure')

load('DataTables/HDeviceBGM.mat')
subjids = unique(HDeviceBGM.PtID);

for s = 1:numel(subjids)
    subjid = subjids(s); 
    idxs = find(HDeviceBGM.PtID==subjid);
    BGM = table(HDeviceBGM.DeviceDtTmDaysFromEnroll(idxs),HDeviceBGM.DeviceTm(idxs),HDeviceBGM.GlucoseValue(idxs),...
    'VariableNames', {'Day', 'Time', 'GlucoseValue'});
    
    subjIdx = find(subjid==[S.PtID]);
    BGM = sortrows(BGM,{'Day','Time'});
    S(subjIdx).BGM = BGM;
    
    if mod(s,3) == 0
        display([num2str(100*s/numel(subjids)) '% of subjects complete'])
    end
end

%% CGM
display('Task (7/12): Incorporating CGM data into structure')

load('DataTables/HDeviceCGM.mat')
subjids = unique(HDeviceCGM.PtID);
for s = 1:numel(subjids)
    subjid = subjids(s); 
    idxs = find(HDeviceCGM.PtID==subjid);
    CGM = table(HDeviceCGM.DeviceDtTmDaysFromEnroll(idxs),HDeviceCGM.DeviceTm(idxs),HDeviceCGM.GlucoseValue(idxs),...
    'VariableNames', {'Day', 'Time', 'GlucoseValue'});
    
    subjIdx = find(subjid==[S.PtID]);
    CGM = sortrows(CGM,{'Day','Time'});
    S(subjIdx).CGM = CGM;
    
    display([num2str(100*s/numel(subjids)) '% of subjects complete'])
end
clearvars -except S

%% Incorporate summary CGM values into structure
display('Task (8/12): Summarizing CGM data for each subject')


times = [datetime('00:00:00','Format', 'HH:mm:ss'):minutes(5):datetime('23:55:00','Format', 'HH:mm:ss')];
times.Day = 1; 

for subjIdx = 1:numel(S)
Days = unique(S(subjIdx).CGM.Day);
glucoseLevels_5minutes=nan(numel(Days),numel(times));
for d = 1:numel(Days)
    idx =find(S(subjIdx).CGM.Day==Days(d)); 
    time = dateshift(S(subjIdx).CGM.Time(idx),'start','minute');
    time.Minute = 5 * floor(time.Minute/5);
    time.Day=1;
%     hold on; plot(time,S(s).CGM.GlucoseValue(idx))
    for i = 1:numel(idx)
        tIdx = find(times==time(i));
        glucoseLevels_5minutes(d,tIdx) = S(subjIdx).CGM.GlucoseValue(idx(i));
    end
end

glucoseLevelsHourly = nan(numel(Days),24);
for h = 1:24
    for d = 1:numel(Days)
        glucoseLevelsHourly(d,h) = nanmean(glucoseLevels_5minutes(d,12*(h-1)+1:12*(h-1)+12));
    end
end

    glucoseLevelsMean = nanmean(glucoseLevelsHourly);
    glucoseLevelsStd = nanstd(glucoseLevelsHourly);
    glucoseLevelsN = sum(~isnan(glucoseLevelsHourly));

    err = glucoseLevelsStd./sqrt(glucoseLevelsN); 
    glucoseLevelsTime = [0:23]; %need it in numeric format for shadedErrorbar
    
    showPlot = 1;
    if showPlot == 1
        figure(1)
        hold on; plots.shadedErrorBar(glucoseLevelsTime,glucoseLevelsMean,err)
        xticks(linspace(0, 24,5))
        xticklabels({'12AM', '6AM', '12PM', '6PM', '12AM'})
        ylabel('Glucose concentration (mg/dL)')
        set(gca, 'xticklabelmode','Manual')
        pause(.01)
    end
    
    S(subjIdx).glucoseLevelsMean = glucoseLevelsMean; 
    S(subjIdx).glucoseLevelsStd = glucoseLevelsStd; 
    S(subjIdx).glucoseLevelsN = glucoseLevelsN;
    S(subjIdx).glucoseLevelsTime = glucoseLevelsTime; 
    
    if mod(subjIdx,10) == 0
        display([num2str(100*subjIdx/numel(S)) '% of subjects complete'])
    end
end


%%
excludeIdx = find(~([S.PtStatus] == 'Completed'));
S(excludeIdx) = [];
S = sortStruct(S,'PtID',1);
save('S.mat', 'S')
clearvars -except S








