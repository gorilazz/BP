bootstrapping_mean = read.csv("../Model/201410/experiments_AR_Social_Model_13_mean.csv");

bootstrapping_median = read.csv("../Model/201410/experiments_AR_Social_Model_13_median.csv");

rollingtest_model_13 = read.csv("../Model/201410/experiments_AR_Social_Model_13.csv");

candidate_mean = bootstrapping_mean[bootstrapping_mean$L1<=50,];
candidate_mean = candidate_mean[candidate_mean$Win1>=5.5,];
candidate_mean = candidate_mean[candidate_mean$DirectionalWin1>=5.5,];

candidate_median = bootstrapping_median[bootstrapping_median$L1<=50,];
candidate_median = candidate_median[candidate_median$Win1>=6,];
candidate_median = candidate_median[candidate_median$DirectionalWin1>=6,];

ensemble_mean = rollingtest_model_13[rollingtest_model_13$Features %in% candidate_mean$Features,];
ensemble_median = rollingtest_model_13[rollingtest_model_13$Features %in% candidate_median$Features,];

write.csv(ensemble_mean, file = "../Model/201410/experiments_AR_Social_Model_13_mean_bestmodels_bootstrapping.csv");
write.csv(ensemble_median, file = "../Model/201410/experiments_AR_Social_Model_13_median_bestmodels_bootstrapping.csv");