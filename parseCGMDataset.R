library(tidyverse)
library(dplyr)
library(chron)
setwd('~/ReplaceBG/')


## Roster:
RosterDataset<- read.csv('DataTables/HPtRoster.txt', sep = '|',header = TRUE, stringsAsFactors = F)
RosterDataset = RosterDataset[order(RosterDataset$PtID), c(2,6,7,8)]
RosterDataset= RosterDataset %>%
  group_by(PtID) %>%
    nest()
RosterDataset = rename(RosterDataset, RosterData = data)

head(RosterDataset)

## Demographics:
DemographicDataset<- read.csv('DataTables/HScreening.txt', sep = '|',header = TRUE, stringsAsFactors = F)
DemographicDataset = DemographicDataset[order(DemographicDataset$PtID), c(2,6,8,9, 17, 20, 36, 37)] 
DemographicDataset= DemographicDataset %>%
  group_by(PtID) %>%
  nest()
DemographicDataset = rename(DemographicDataset, DemographicData = data)

head(DemographicDataset)


## HbA1c:
HbA1cDataset<- read.csv('DataTables/HLocalHbA1c.txt', sep = '|',header = TRUE, stringsAsFactors = F)

HbA1cDataset = HbA1cDataset[order(HbA1cDataset$PtID, HbA1cDataset$Visit), ]

HbA1cDataset = HbA1cDataset %>%
  group_by(PtID) %>%
    nest()
HbA1cDataset = rename(HbA1cDataset, HbA1cData = data)
head(HbA1cDataset)

## BGM: 
BGMdataset<- read.csv('DataTables/HDeviceBGM.txt', sep = '|',header = TRUE, stringsAsFactors = F)
BGMdataset$DeviceTm = chron(times =BGMdataset$DeviceTm)
BGMdataset = BGMdataset[order(BGMdataset$PtID, BGMdataset$DeviceDtTmDaysFromEnroll, BGMdataset$DeviceTm), c(3,5,6,9)]
BGMdataset = BGMdataset[BGMdataset$DeviceDtTmDaysFromEnroll >= 0, ]

BGMdataset = BGMdataset %>%
  group_by(PtID) %>%
    nest()
BGMdataset = rename(BGMdataset, BGMdata = data)
head(BGMdataset)

# Should we nest GM dataset by days? Like so: 
# by_day = BGM$data[[1]] %>%
#   group_by(DeviceDtTmDaysFromEnroll) %>%
#   nest()

## CGM:
CGMdataset<- read.csv('DataTables/HDeviceCGM.txt', sep = '|',header = TRUE, stringsAsFactors = F) 
CGMdataset$DeviceTm = chron(times =CGMdataset$DeviceTm)
CGMdataset = CGMdataset[order(CGMdataset$PtID, CGMdataset$DeviceDtTmDaysFromEnroll, CGMdataset$DeviceTm), c(3,5,6,10)]
CGMdataset = CGMdataset[CGMdataset$DeviceDtTmDaysFromEnroll >= 0, ]

CGMdataset = CGMdataset %>%
  group_by(PtID) %>%
    nest()
CGMdataset = rename(CGMdataset, CGMdata = data)
head(BGMdataset)

## Insulin bolus:

BolusDataset<- read.csv('DataTables/HDeviceBolus.txt', sep = '|',header = TRUE, stringsAsFactors = F)
BolusDataset$DeviceTm = chron(times =BolusDataset$DeviceTm)
BolusDataset = BolusDataset[order(BolusDataset$PtID, BolusDataset$DeviceDtTmDaysFromEnroll, BolusDataset$DeviceTm), c(3,5,6)]

BolusDataset = BolusDataset %>%
  group_by(PtID) %>%
    nest()
BolusDataset = rename(BolusDataset, BolusData = data)
head(BolusDataset)


ReplaceBGDataset = RosterDataset %>% 
  inner_join(DemographicDataset, by="PtID") %>%
    inner_join(HbA1cDataset, by="PtID") %>%
      inner_join(BGMdataset, by="PtID") %>%
        inner_join(CGMdataset, by="PtID") %>%
          inner_join(BolusDataset, by="PtID")
  
## To show the 5th patient's CGMdata:
# ReplaceBGDataset$CGMdata[[5]]
# hist(ReplaceBGDataset$CGMdata[[5]]$GlucoseValue)

## To show the 5th patient's Week 26 HbA1c results:
# ReplaceBGDataset$HbA1cData[[5]]$HbA1cTestRes[4]

save(file = 'DataTables/ReplaceBGDataset.Rdata', list = "ReplaceBGDataset")





