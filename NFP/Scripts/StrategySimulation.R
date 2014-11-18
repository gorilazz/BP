# Generate the ensemble model month by month and validate it

source('../../Utility/utility.R');
source('../../Utility/learning_utility.R');
source('../../Utility/automation_utility.R');


L1Threshold = 45;
DirectionalWin1Threshold=9;
DirectionalWin2Threshold=7;
Win1Threshold=8;
Win2Threshold=6;
WeightedWin1Threshold=70;


#readin data & initialization
path_prediction = "../Prediction/201410/Model_14_unrevised_Predictions.csv";
path_consensus = "../GroundTruth/Consensus.csv";
path_featureAR = "../Features/AR/ARDelta_Full.csv";

path_outMetric_mean = paste("../Simulation/201410/Model_14_unrevised_Ensemble_45","mean.csv",sep='_');
path_outMetric_median = paste("../Simulation/201410/Model_14_unrevised_Ensemble_45","median.csv",sep='_');

# read in data
predictionFull = read.csv(file=path_prediction, head=TRUE, sep=",");

featureAR = read.csv(file=path_featureAR, head=TRUE, sep=",");
featureAR$Date = as.character(featureAR$Date);
for(i in 1:nrow(featureAR))
{
	featureAR[i,'Date'] = DateToMonthTag(featureAR[i,'Date']);
}

consensus = read.csv(file=path_consensus, head=TRUE, sep=",");
consensus$Date = as.character(consensus$Date);
for(i in 1:nrow(consensus))
{
	consensus[i,'Date'] = DateToMonthTag(consensus[i,'Date']);
}

labels = featureAR$Label;

month_start = "201311";	# the first month to simulate
month_end = "201410";	# the last month to simulate

index_start = grep(month_start, colnames(predictionFull));
index_end = grep(month_end, colnames(predictionFull));

simulationResults_mean = data.frame(Month=character(),"Prediction"=character(),"L1"=character(),"Win1"=character(),"DWin1"=character(),stringsAsFactors=FALSE);
simulationResults_median = data.frame(Month=character(),"Prediction"=character(),"L1"=character(),"Win1"=character(),"DWin1"=character(),stringsAsFactors=FALSE);

for(index_month in index_start:index_end)
{
	candidates = c();
	pos = 1;
	testing_start = index_month-12;
	testing_end = index_month-1;

	testing_start_month = colnames(predictionFull)[testing_start]
	testing_start_month = paste(unlist(strsplit(testing_start_month,'X')),collapse="")
	testing_end_month = colnames(predictionFull)[testing_end]
	testing_end_month = paste(unlist(strsplit(testing_end_month,'X')),collapse="")

	simulate_month = colnames(predictionFull)[index_month];
	simulate_month = paste(unlist(strsplit(simulate_month,'X')),collapse="")

	testing_labels = labels[which(featureAR$Date==testing_start_month)[1] : which(featureAR$Date==testing_end_month)[1]];
	testing_consensus = consensus[which(consensus$Date==testing_start_month)[1] : which(consensus$Date==testing_end_month)[1],];

	simulate_label = labels[which(featureAR$Date==simulate_month)[1]]
	simulate_consensus = consensus[which(consensus$Date==simulate_month)[1],]$Consensus1;

	for(i in 1:length(predictionFull$Features))
	{
		print(paste(index_month,i,sep=':'));
		combo = predictionFull$Features[i];

		predictions = predictionFull[i,];
		predictions = unlist(predictions[testing_start:(testing_end+1)]);

		result = ComputeMetrics_Prediction(predictions,testing_labels,testing_consensus);

		if(result[1]<=L1Threshold && result[5]>=Win1Threshold && result[6]>=Win2Threshold && result[7]>=DirectionalWin1Threshold && result[8]>=DirectionalWin2Threshold)
		{
			candidates[pos] = result[11];
			pos = pos+1;
		}
	}

	mean_prediction = mean(candidates);
	median_prediction = median(candidates);

	mean_L1 = abs(mean_prediction-simulate_label);
	median_L1 = abs(median_prediction-simulate_label);

	mean_Win1 = mean_L1 < abs(simulate_label-simulate_consensus);
	median_Win1 = median_L1 < abs(simulate_label-simulate_consensus);

	mean_DWin1 = (mean_prediction-simulate_consensus)*(simulate_label-simulate_consensus)>0;
	median_DWin1 = (median_prediction-simulate_consensus)*(simulate_label-simulate_consensus)>0;

	simulationResults_mean[nrow(simulationResults_mean)+1,] <- c(simulate_month, mean_prediction, mean_L1, mean_Win1, mean_DWin1);
	simulationResults_median[nrow(simulationResults_median)+1,] <- c(simulate_month, median_prediction, median_L1, median_Win1, median_DWin1);
}

write.csv(simulationResults_mean, file = path_outMetric_mean);
write.csv(simulationResults_median, file = path_outMetric_median);