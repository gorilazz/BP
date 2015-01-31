source('utility.R');

path_inPrediction = "../Model/201410/experiments_AR_Social_Model_13_median_bestmodels_bootstrapping.csv";

predictionsFull = read.csv(file=path_inPrediction, head=TRUE, sep=",");

predictions = predictionsFull$Prediction;

result_mean = ConfidenceInterval(predictions, 0.95, "mean");
result_median = ConfidenceInterval(predictions, 0.95, "median");