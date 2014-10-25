#==========================================
# Wearable computing Data Analysis Project
#==========================================

#--------------------------------------------------------------
## Code to munge the data into tidy dataset. Specifically:

## * Merges the training and the test sets to create one data set.
## * Extracts only the measurements on the mean and standard deviation 
## for each measurement. 
## * Uses descriptive activity names to name the activities in the data set
## * Appropriately labels the data set with descriptive variable names. 
## * From the data set above, creates a second, independent tidy data 
## set with the average of each variable for each activity and each subject.
#--------------------------------------------------------------

#--------------------------------------------------------------
# 0) Preliminaries: load libraries and set up directory locations
#--------------------------------------------------------------

library(plyr) # for data munging/ manipulation
library(LaF) # for reading massive flat files really quickly

# get working directory needed to reference relative path
wd <- getwd()

train_location <- paste(wd,'UCI HAR Dataset/train',sep='/')
test_location <- paste(wd,'UCI HAR Dataset/test',sep='/')
meta_location <- paste(wd,'UCI HAR Dataset',sep='/') # where we get info about the features

#--------------------------------------------------------------
# 1) Extracts only the measurements on the mean and standard deviation 
# for each measurement.
#--------------------------------------------------------------

# getting column names
setwd(meta_location)
vars <- read.table('features.txt', header=FALSE, sep=" ")

# find which vars are like mean() and std()
mean_std_vars <- regexpr('std', vars[,2],fixed=TRUE)
mean_std_vars <- ifelse(mean_std_vars==-1, regexpr('mean', vars[,2],fixed=TRUE), mean_std_vars)
ind <- mean_std_vars != -1

#--------------------------------------------------------------
# 2) Merges the training and the test sets to create one data set and
# Appropriately labels the data set with descriptive variable names. 
#--------------------------------------------------------------

# training dataset
#--------------------
setwd(train_location)

# obtain the features
X_train <- laf_open_fwf('X_train.txt', column_widths=c(rep(16, 561)), column_names=as.character(vars$V2), 
                        column_types = c(rep("double",561))) # the column names come from above metadata

X_train <- X_train[,ind] # to extract just mean and stdev columns using ind from above

# obtain the outcomes
y_train <- laf_open_fwf('y_train.txt', column_types = "integer", column_widths=1, column_names="Activity")
y_train <- y_train[,]

# obtain the subjects
sub_train <- read.table('subject_train.txt', col.names="Subject")


# test dataset
#-------------
setwd(test_location)

X_test <- laf_open_fwf('X_test.txt', column_widths=c(rep(16, 561)), column_names=as.character(vars$V2), 
                       column_types = c(rep("double",561))) # the column names come from above metadata

X_test <- X_test[,ind] # to extract just mean and stdev columns

y_test <- laf_open_fwf('y_test.txt', column_types = "integer", column_widths=1, column_names="Activity")
y_test <- y_test[,]

# obtain the subjects
sub_test <- read.table('subject_test.txt', col.names="Subject")

# flag the data to indicate train and test
#-------------------------------------------
X_train$train_flag <- 1
X_test$train_flag <- 0

# combine train and test
#--------------------------
X_dat <- rbind(X_train, X_test)
y_dat <- rbind(y_train, y_test)
sub_dat <- rbind(sub_train, sub_test)

dat <- cbind(sub_dat, X_dat, y_dat) # so now we have combined all our train and test datasets


#--------------------------------------------------------------
# 3) Uses descriptive activity names to name the activities in the data set
#--------------------------------------------------------------

setwd(meta_location)
activity_labels <- read.table('activity_labels.txt', header=FALSE, sep=" ", col.names = c("label","Activity"))
names(activity_labels) = c("Activity","Activity_Desc")

# join to dataset y column with plyr, this gives us activity descriptions instead of integers
dat <- join(dat, activity_labels, by = "Activity", type = "left")
dat[,82] <- NULL


#--------------------------------------------------------------
# 4) From the data set in step 4, creates a second, independent tidy data set 
# with the average of each variable for each activity and each subject.
#--------------------------------------------------------------

# use split to split the data by subject and activity
# ldply(split, mean) from plyr package to apply the mean for each column
# each record will be an individual, with mean and std vars mean

splitDat <- split(dat[,-c(82)], list(dat$Subject, dat$Activity_Desc))
means_dat <- ldply(splitDat, colMeans)

means_dat <- arrange(means_dat, .id)

#--------------------------------------------------------------
# 5) output this summarised dataset 
#--------------------------------------------------------------

setwd(wd)

# summarised dataset
write.table(means_dat, 'means_dat.txt', row.name=FALSE)

# codebook
data_names <- as.data.frame(names(means_dat))
write.table(data_names, 'codebook.txt', row.name=FALSE)
