#get weoking directory
getwd()
#set working directory
setwd("c:/datascience")
#unzip files
unzip(zipfile="./data/getdata_projectfiles_UCI HAR Dataset.zip",exdir="./assignment");

install.packages("dplyr")
install.packages("data.table")
install.packages("tidyr")
###Load required packages
library(dplyr)
library(data.table)
library(tidyr)

#filepath

filesPath <- "C:/datascience/assignment/UCI HAR Dataset"
# Read subject files

# Read subject files
GetdataSubjectTrain <- tbl_df(read.table(file.path(filesPath, "train", "subject_train.txt")))
GetdataSubjectTest  <- tbl_df(read.table(file.path(filesPath, "test" , "subject_test.txt" )))

# Read activity files
GetdataActivityTrain <- tbl_df(read.table(file.path(filesPath, "train", "Y_train.txt")))
GetdataActivityTest  <- tbl_df(read.table(file.path(filesPath, "test" , "Y_test.txt" )))

#Read data files.
GetdataTrain <- tbl_df(read.table(file.path(filesPath, "train", "X_train.txt" )))
GetdataTest  <- tbl_df(read.table(file.path(filesPath, "test" , "X_test.txt" )))




# for both Activity and Subject files this will merge the training and the test sets by row binding 
#and rename variables "subject" and "activityNum"
alldataSubject <- rbind(GetdataSubjectTrain, GetdataSubjectTest)
setnames(alldataSubject, "V1", "subject")
alldataActivity<- rbind(GetdataActivityTrain, dataActivityTest)
setnames(alldataActivity, "V1", "activityNum")

#combine the DATA training and test files
MydataTable <- rbind(GetdataTrain, GetdataTest)

# name variables according to feature e.g.(V1 = "tBodyAcc-mean()-X")
dataFeatures <- tbl_df(read.table(file.path(filesPath, "features.txt")))
setnames(dataFeatures, names(dataFeatures), c("featureNum", "featureName"))
colnames(MydataTable) <- dataFeatures$featureName

#column names for activity labels
activityLabels<- tbl_df(read.table(file.path(filesPath, "activity_labels.txt")))
setnames(activityLabels, names(activityLabels), c("activityNum","activityName"))

# Merge columns
alldataSubjAct<- cbind(alldataSubject, alldataActivity)
MydataTable <- cbind(alldataSubjAct, MydataTable)





# Reading "features.txt" and extracting only the mean and standard deviation
dataFeaturesMeanStd <- grep("mean\\(\\)|std\\(\\)",dataFeatures$featureName,value=TRUE) #var name

# Taking only measurements for the mean and standard deviation and add "subject","activityNum"

dataFeaturesMeanStd <- union(c("subject","activityNum"), dataFeaturesMeanStd)
MydataTable<- subset(MydataTable,select=dataFeaturesMeanStd) 
MydataTable[1]

##enter name of activity into MydataTable
MydataTable <- merge(activityLabels, MydataTable , by="activityNum", all.x=TRUE)
MydataTable$activityName <- as.character(MydataTable$activityName)

## create MydataTable with variable means sorted by subject and Activity
MydataTable$activityName <- as.character(MydataTable$activityName)
dataAggr<- aggregate(. ~ subject - activityName, data = MydataTable, mean) 
MydataTable<- tbl_df(arrange(dataAggr,subject,activityName))



#Names before
head(str(MydataTable),2)


names(MydataTable)<-gsub("std()", "SD", names(MydataTable))
names(MydataTable)<-gsub("mean()", "MEAN", names(MydataTable))
names(MydataTable)<-gsub("^t", "time", names(MydataTable))
names(MydataTable)<-gsub("^f", "frequency", names(MydataTable))
names(MydataTable)<-gsub("Acc", "Accelerometer", names(MydataTable))
names(MydataTable)<-gsub("Gyro", "Gyroscope", names(MydataTable))
names(MydataTable)<-gsub("Mag", "Magnitude", names(MydataTable))
names(MydataTable)<-gsub("BodyBody", "Body", names(MydataTable))
# Names after
head(str(MydataTable),6)


##write to text file on disk
write.table(MydataTable, "MyTidyData.txt", row.name=FALSE)