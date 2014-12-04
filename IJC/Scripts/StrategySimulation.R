# Generate the ensemble model month by month and validate it

source('../../Utility/utility.R');
source('../../Utility/learning_utility.R');
source('../../Utility/automation_utility.R');


L1Threshold = 15;
DirectionalWinThreshold=20;
WinThreshold=0;


#readin data & initialization
path_prediction = "../Prediction/201411/Model_1a_NFP_Predictions.csv";
path_consensus = "../GroundTruth/Consensus.csv";
path_featureAR = "../Features/AR/Features_AR_Delta.csv";

path_outMetric_mean = paste("../Simulation/201411/Model_1a_NFP_Predictions","mean.csv",sep='_');
path_outMetric_median = paste("../Simulation/201411/Model_1a_NFP_Predictions","median.csv",sep='_');

# read in data
predictionFull = read.csv(file=path_prediction, head=TRUE, sep=",");

featureAR = read.csv(file=path_featureAR, head=TRUE, sep=",");
featureAR$Date = as.character(featureAR$Date);
for(i in 1:nrow(featureAR))
{
	featureAR[i,'Date'] = DateToWeekTag(featureAR[i,'Date']);
}

consensus = read.csv(file=path_consensus, head=TRUE, sep=",");
consensus$Date = as.character(consensus$Date);
for(i in 1:nrow(consensus))
{
	consensus[i,'Date'] = DateToWeekTag(consensus[i,'Date']);
}

labels = featureAR$Label;

week_start = "20140418";	# the first week to simulate
week_end = "20141107";	# the last week to simulate

index_start = grep(week_start, colnames(predictionFull));
index_end = grep(week_end, colnames(predictionFull));

simulationResults_mean = data.frame(Week=character(),"Prediction"=character(),"L1"=character(),"Win"=character(),"DWin"=character(),stringsAsFactors=FALSE);
simulationResults_median = data.frame(Week=character(),"Prediction"=character(),"L1"=character(),"Win"=character(),"DWin"=character(),stringsAsFactors=FALSE);

for(index_week in index_start:index_end)
{
	candidates = c();
	pos = 1;
	testing_start = index_week-30;
	testing_end = index_week-1;

	testing_start_week = colnames(predictionFull)[testing_start]
	testing_start_week = paste(unlist(strsplit(testing_start_week,'X')),collapse="")
	testing_end_week = colnames(predictionFull)[testing_end]
	testing_end_week = paste(unlist(strsplit(testing_end_week,'X')),collapse="")

	simulate_week = colnames(predictionFull)[index_week];
	simulate_week = paste(unlist(strsplit(simulate_week,'X')),collapse="")

	testing_labels = labels[which(featureAR$Date==testing_start_week)[1] : which(featureAR$Date==testing_end_week)[1]];
	testing_consensus = consensus[which(consensus$Date==testing_start_week)[1] : which(consensus$Date==testing_end_week)[1],];
	testing_consensus = testing_consensus$DeltaConsensus;

	simulate_label = labels[which(featureAR$Date==simulate_week)[1]]
	simulate_consensus = consensus[which(consensus$Date==simulate_week)[1],]$DeltaConsensus;

	for(i in 1:length(predictionFull$Features))
	{
		print(paste(index_week,i,sep=':'));
		combo = predictionFull$Features[i];

		predictions = predictionFull[i,];
		predictions = unlist(predictions[testing_start:(testing_end+1)]);

		result = ComputeMetrics_Prediction(predictions,testing_labels,testing_consensus);

		if(result[1]<=L1Threshold && result[5]>=WinThreshold && result[6]>=DirectionalWinThreshold)
		{
			candidates[pos] = result[8];
			pos = pos+1;
		}
	}

	mean_prediction = mean(candidates);
	median_prediction = median(candidates);

	mean_L1 = abs(mean_prediction-simulate_label);
	median_L1 = abs(median_prediction-simulate_label);

	mean_Win = mean_L1 < abs(simulate_label-simulate_consensus);
	median_Win = median_L1 < abs(simulate_label-simulate_consensus);

	mean_DWin = (mean_prediction-simulate_consensus)*(simulate_label-simulate_consensus)>0;
	median_DWin = (median_prediction-simulate_consensus)*(simulate_label-simulate_consensus)>0;

	simulationResults_mean[nrow(simulationResults_mean)+1,] <- c(simulate_week, mean_prediction, mean_L1, mean_Win, mean_DWin);
	simulationResults_median[nrow(simulationResults_median)+1,] <- c(simulate_week, median_prediction, median_L1, median_Win, median_DWin);
}

write.csv(simulationResults_mean, file = path_outMetric_mean);
write.csv(simulationResults_median, file = path_outMetric_median);