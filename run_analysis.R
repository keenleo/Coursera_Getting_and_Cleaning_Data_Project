## Require libraries
library(reshape2)
library(plyr)
## Import data
features <- read.table("features.txt")
featureCols <- t(features)
x_test <-read.table("X_test.txt")
y_test <-read.table("Y_test.txt")
x_train <-read.table("X_train.txt")
y_train <-read.table("Y_train.txt")
s_train <-read.table("subject_train.txt")
actLabs <-read.table("activity_labels.txt")
## Get mean and std features
colnames(actLabs)[2] <- "Activity"
colnames(actLabs)[1] <- "activityID"
meanStd <- rbind(features[grep("mean", features[[2]]),], features[grep("std", features[[2]]),])
allSets <- rbind(x_test,x_train)
meanStdData <- allSets[meanStd[[1]]]

## Change feature names
mean_std_colnames <- gsub("\\()","",meanStd$V2)
mean_std_colnames <- gsub("Gyro","Gyroscope",mean_std_colnames)
mean_std_colnames <- gsub("Acc","Acceleration",mean_std_colnames)
mean_std_colnames <- gsub("Mag","Magnitude",mean_std_colnames)
mean_std_colnames <- gsub("mean","Mean",mean_std_colnames)
mean_std_colnames <- gsub("MeanFreq","MeanFrequency",mean_std_colnames)
mean_std_colnames <- gsub("std","StandardDeviation",mean_std_colnames)
mean_std_colnames <- gsub("-","_",mean_std_colnames)
mean_std_colnames <- gsub("^t","Time_",mean_std_colnames)
mean_std_colnames <- gsub("^f","Frequency_",mean_std_colnames)
mean_std_colnames <- gsub("BodyBody","Body",mean_std_colnames)
mean_std_colnames <- as.data.frame(mean_std_colnames)
meanStd <- cbind(meanStd,mean_std_colnames)

## Transform data
colnames(meanStdData) <- meanStd[[3]]
meanStdData <- cbind(rbind(s_test,s_train),rbind(y_test,y_train),meanStdData)
colnames(meanStdData)[1] <- "Subject"
colnames(meanStdData)[2] <- "activityID"
## Sort data
meanStdData <- meanStdData[order(meanStdData$activity),]
meanStdData <- merge(actLabs, meanStdData, by="activityID")
meanStdData <- subset(meanStdData, select = -activityID )

## Uncomment line below to export the first dataset
##write.table(meanStdData, "dataSet1.txt", sep=",")

## Create 2nd data file
dataSet2 <- melt(meanStdData, id.vars=c("Activity", "Subject"))
dataSet2 <- ddply(dataSet2, c("Activity", "Subject", "variable"), summarise, Mean = mean(value))
data.wide <- dcast(dataSet2, Subject + Activity ~ variable, value.var="Mean")
write.table(data.wide, "tidyDataSet.txt", sep=",", row.name=FALSE) 