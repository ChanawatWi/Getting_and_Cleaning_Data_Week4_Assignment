library(tidyverse)
library(lubridate)

if (!file.exists("./data")) {
        dir.create("./data")
}

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(fileUrl, destfile = "./data/data.zip", )

zipFile <- file.choose()
unzip(zipFile, exdir = "./data")

datapath <- file.path("./data", "UCI HAR Dataset")

#features data
features = read.table(file.path(datapath, "features.txt"),header = FALSE)

#activity labels data
activityLabels = read.table(file.path(datapath, "activity_labels.txt"),header = FALSE)

colnames(activityLabels) <- c('activityId','activityType')

#train data
xtrain = read.table(file.path(datapath, "train", "X_train.txt"),header = FALSE)
ytrain = read.table(file.path(datapath, "train", "y_train.txt"),header = FALSE)
subject_train = read.table(file.path(datapath, "train", "subject_train.txt"),header = FALSE)

colnames(xtrain) <- features[,2]
colnames(ytrain) <- "activityId"
colnames(subject_train) <- "subjectId"

#test data
xtest = read.table(file.path(datapath, "test", "X_test.txt"),header = FALSE)
ytest = read.table(file.path(datapath, "test", "y_test.txt"),header = FALSE)
subject_test = read.table(file.path(datapath, "test", "subject_test.txt"),header = FALSE)

colnames(xtest) <- features[,2]
colnames(ytest) <- "activityId"
colnames(subject_test) <- "subjectId"

#merge
merge_test <- cbind(subject_test, ytest, xtest)
merge_train <- cbind(subject_train, ytrain, xtrain)
merge_data <- rbind(merge_test, merge_train)

col_names <- colnames(merge_data)
target_col <- (grepl("activityId" , col_names) | grepl("subjectId" , col_names) | grepl("mean.." , col_names) | grepl("std.." , col_names))
target_data <- merge_data[, target_col]
complete_data <- merge(target_data, activityLabels, by = "activityId", all.x = TRUE)

tidydata <- target_data %>% group_by(subjectId, activityId) %>% summarize_all(funs(mean))
tidydata <- merge(tidydata, activityLabels, by = "activityId", all.x = TRUE)
tidydata <- tidydata %>% arrange(subjectId, activityId)
write.table(tidydata, "./data/UCI HAR Dataset/tidydata.txt", row.names = FALSE, col.names = TRUE)
