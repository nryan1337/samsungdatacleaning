---
title: "README for Wearable Computing Assignment"
---

## Run location

- Run the script from the same location the "UCI HAR Dataset" folder is in.
- Relative paths are determined from this location
- This may require setting your working directory to be the same as the "UCI HAR Dataset"

## Script 

0) The script will load libraries and determine locations of the meta data, training and test data folders. The LaF package simply burns through loading up the flat files, and the plyr package is great for the latter data munging.

1) The script will load up a file containing the features then subset using regular expressions for variables containing "mean" or "std".

2) Information about the subjects, and the training and test datasets is merged to form one dataset, but the training and test parts of the data are flagged. At this stage most of the variables in the original file are not carried forward. Only the "mean" or "std" vars will be on the file. 

3) The script loads up descriptions of activities and joins this to the data. This is used instead of the simple integer.

4) Means of each variable are computed for each subject and for each activity.

5) The resulting tidy dataset is output to a text file for inspection.


