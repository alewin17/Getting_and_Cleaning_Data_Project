# Here are the data for the project:
#   
#   https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip  
# 
# You should create one R script called run_analysis.R that does the following. 
# 
# 1)Merges the training and the test sets to create one data set.
# 2)Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3)Uses descriptive activity names to name the activities in the data set
# 4)Appropriately labels the data set with descriptive variable names. 
# 5)From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# if (!require("data.table")) {
#   install.packages("data.table")
# }
# 
# if (!require("reshape2")) {
#   install.packages("reshape2")
# }

library("data.table")
library("reshape2")

file_path_pref = "/Users/lex/Desktop/coursera_getting_clean_data/UCI HAR Dataset/"

# read activity lables 
activity_labels <- read.table(paste0(file_path_pref, "activity_labels.txt"))[,2]

# read features
features <- read.table(paste0(file_path_pref, "features.txt"))[,2]

# get mean and standard deviation from features
get_features <- grepl("mean|std", features)

# read test data 
X_test <- read.table(paste0(file_path_pref, "test/X_test.txt"))
y_test <- read.table(paste0(file_path_pref, "test/y_test.txt"))
subject_test <- read.table(paste0(file_path_pref, "test/subject_test.txt"))

names(X_test) = features

# read mean and standard deviation from x_test
X_test = X_test[,get_features]

# read activity labels
y_test[,2] = activity_labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

# merge tables test x & y
test_table <- cbind(as.data.table(subject_test), y_test, X_test)

# Load and process X_train & y_train data.
X_train <- read.table(paste0(file_path_pref, "train/X_train.txt"))
y_train <- read.table(paste0(file_path_pref, "train/y_train.txt"))

subject_train <- read.table(paste0(file_path_pref, "train/subject_train.txt"))

names(X_train) = features

# read mean and standard deviation from y_test
X_train = X_train[,get_features]

# read activity data
y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

# merge tables train x & y
train_table <- cbind(as.data.table(subject_train), y_train, X_train)

# add train table to test table
df = rbind(test_table, train_table)

id_names = c("subject", "Activity_ID", "Activity_Label")
df_names = setdiff(colnames(df), id_names)
df_melt  = melt(df, id = id_names, measure.vars = df_names)

# add mean to melted dataset
result_data   = dcast(df_melt, subject + Activity_Label ~ variable, mean)

# write output file 
write.table(result_data, file = paste0(file_path_pref, "/run_analysis_result_data.txt"))
            