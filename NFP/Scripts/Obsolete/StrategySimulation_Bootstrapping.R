# Generate the ensemble model month by month and validate it

rm(list=ls());

source('../../Utility/utility.R');
source('../../Utility/learning_utility.R');
source('../../Utility/automation_utility.R');


L1Threshold = 50;
DirectionalWinThreshold=5;
WinThreshold=0;



#readin data & initialization
path_prediction = "../Prediction/201411/Model_14_unrevised_Predictions.csv";
path_bootstrapping_metric = "../Model/201410/CV/experiments_AR_Social_Model_14_unrevised_mean.csv";
path_consensus = "../GroundTruth/Consensus.csv";
path_featureAR = "../Features/AR/ARDelta_Full.csv";

path_outDir = "../Simulation/201411/CV";
if(!file.exists(path_outDir))
{
	dir.create(path_outDir);
}
file_outMetric = paste("Model_14_unrevised_mean_models_Ensemble","median.csv",sep='_');
path_outMetric = file.path(path_outDir,file_outMetric);

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

bootstrappingMetric = read.csv(file=path_bootstrapping_metric, head=TRUE, sep=",");
candidateCombos = bootstrappingMetric[bootstrappingMetric$L1<=L1Threshold,];
candidateCombos = candidateCombos[candidateCombos$DirectionalWin>DirectionalWinThreshold,];

candidateCombos = data.frame(candidateCombos$Features);
colnames(candidateCombos) = c("Features");

candidatePredictions = merge(candidateCombos, predictionFull, by="Features");


month_start = "201309";	# the first month to simulate
month_end = "201411";	# the last month to simulate

index_start = grep(month_start, colnames(candidatePredictions));
index_end = grep(month_end, colnames(candidatePredictions));

simulationResults_median = data.frame(Month=character(),"Prediction"=character(),"L1"=character(),"Win"=character(),"DWin"=character(),stringsAsFactors=FALSE);

for(index_month in index_start:index_end)
{
	simulate_month = colnames(candidatePredictions)[index_month];
	simulate_month = paste(unlist(strsplit(simulate_month,'X')),collapse="");

	simulate_label = labels[which(featureAR$Date==simulate_month)[1]]
	simulate_consensus = consensus[which(consensus$Date==simulate_month)[1],]$Consensus1;

	median_prediction = median(candidatePredictions[[index_month]]);

	median_L1 = abs(median_prediction-simulate_label);

	median_Win = median_L1 < abs(simulate_label-simulate_consensus);

	median_DWin = (median_prediction-simulate_consensus)*(simulate_label-simulate_consensus)>0;

	simulationResults_median[nrow(simulationResults_median)+1,] <- c(simulate_month, median_prediction, median_L1, median_Win, median_DWin);
}

write.csv(simulationResults_median, file = path_outMetric);