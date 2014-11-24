# Generate the ensemble model month by month and validate it

source('../../Utility/utility.R');
source('../../Utility/learning_utility.R');
source('../../Utility/automation_utility.R');


#readin data & initialization
path_prediction = "../Prediction/201410/SingleCombo/Model_10_unrevised_Predictions.csv";
path_consensus = "../GroundTruth/Consensus.csv";
path_featureAR = "../Features/AR/ARDelta_Full.csv";

path_outMetric = "../Simulation/201410/SingleCombo/Model_10_unrevised_Metrics.csv";

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

simulationResults = data.frame(Month=character(),"Prediction"=character(),"L1"=character(),"Win1"=character(),"DWin1"=character(),stringsAsFactors=FALSE);

predictions = unlist(predictionFull[1,]);

for(index_month in index_start:index_end)
{
	simulate_month = colnames(predictionFull)[index_month];
	simulate_month = paste(unlist(strsplit(simulate_month,'X')),collapse="")

	simulate_label = labels[which(featureAR$Date==simulate_month)[1]]
	simulate_consensus = consensus[which(consensus$Date==simulate_month)[1],]$Consensus1;

	prediction = predictions[index_month];

	L1 = abs(prediction-simulate_label);

	Win1 = L1 < abs(simulate_label-simulate_consensus);

	DWin1 = (prediction-simulate_consensus)*(simulate_label-simulate_consensus)>0;

	simulationResults[nrow(simulationResults)+1,] <- c(simulate_month, prediction, L1, Win1, DWin1);
}

write.csv(simulationResults, file = path_outMetric);
