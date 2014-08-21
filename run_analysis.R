
run_analysis <- function() {

	## Load the features:
	features = read.table("./features.txt");
	features = features[,2];

	## Load test and train data:
	cat("LOADING DATA... ", "\n");
	subject_test = read.table("./test/subject_test.txt", sep=" ", header=FALSE);
	x_test = read.table("./test/X_test.txt");
	y_test = read.table("./test/y_test.txt");
	## Replace the activity numbers with the activity names:
	y_test = factor(y_test$V1, labels = c("WALKING", "WALKING_UPSTAIRS" , "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LAYING"))
	y_test = as.vector(y_test);

	colnames(x_test) = features;

	subject_train = read.table("./train/subject_train.txt", sep=" ", header=FALSE);
	x_train = read.table("./train/X_train.txt");
	y_train = read.table("./train/y_train.txt");
	## Replace the activity numbers with the activity names:
	y_train = factor(y_train$V1, labels = c("WALKING", "WALKING_UPSTAIRS" , "WALKING_DOWNSTAIRS", "SITTING", "STANDING", "LAYING"))
	y_train = as.vector(y_train);

	colnames(x_train) = features

	## Add the subjects to the test and training data
    test_data = cbind(subject_test, y_test, x_test);
    train_data = cbind(subject_train, y_train, x_train);

	## Set the activity and users column names	
	colnames(test_data)[1] = "User";
	colnames(test_data)[2] = "Activity";
	colnames(train_data)[1] = "User";
	colnames(train_data)[2] = "Activity";

	## Merge test and training
	cat("MERGING... ", "\n");
	data = rbind(test_data, train_data);
	
	## Loop through to remove all the columns that are not std or mean
	cat("REMOVING COLUMNS THAT ARE NOT STD OR MEAN... ", "\n");
	columns_number = 0;
	for (colname in colnames(data)) {
		if (!grepl("mean",colname) && !grepl("std",colname) && colname!="User" && colname!="Activity") {
			## Remove this column
			data[colname] = NULL
		} else {
			columns_number = columns_number + 1;
		}
	}

	temp_result <- c();
	User = c();
	Activity = c();
	rows_counter = 1;
	cat("BUILDING TIDY RESULT... ", "\n");
	## Build a new dataframe with this information
    for (current_activity in levels(data$Activity)) {
    	for (current_user in 1:30) {
    		if (length(data[data$Activity==current_activity & data$User==current_user,])>0) {
    			rows = data[(data$Activity==current_activity & data$User==current_user),];
    			User = c(User, current_user);
    			Activity = c(Activity, current_activity);
    			rows$Activity = NULL;
    			rows$User = NULL;
				temp_result = c(temp_result, as.data.frame(sapply(rows, mean))[,1]); 
				rows_counter = rows_counter + 1;   			
    		}
    	}
    }
    temp_result = matrix(temp_result, ncol = columns_number - 2);
    result = as.data.frame(temp_result);

    result$Activity = Activity;
    result$User = User;
    
    user_index = columns_number;
    activity_index = columns_number - 1;
    result = result[, c(user_index, activity_index, 1:activity_index - 1)];
    colnames(result) = colnames(data);
    result;
}

#source("run_analysis.R")
#result = run_analysis()