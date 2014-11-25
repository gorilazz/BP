# Get predictions for each individual model
start = Sys.time();

lambda = 0.0;
aggregationType = c("median","mean");

source('../../Utility/IJC_utility.R');
source('../../Utility/utility.R');
source('../../Utility/learning_utility.R');
source('../../Utility/automation_utility.R');


#readin data & initialization
path_featureAR = "../Features/AR/Features_AR_Delta.csv";
path_featureSocial = "../Features/201411/Features_NFP_All_candiate_seperated_AbsoluteFull.csv";
path_consensus = "../GroundTruth/Consensus.csv";
path_outMetric = "../Prediction/201411/Model_1a_NFP.csv";


featureARFull = read.csv(file=path_featureAR, head=TRUE, sep=",");
featureARFull$Date = as.character(featureARFull$Date)
for(i in 1:nrow(featureARFull))
{
	featureARFull[i,'Date'] = DateToWeekTag(featureARFull[i,'Date']);
}

featureSocialFull = read.csv(file=path_featureSocial, head=TRUE, sep=",");
featureSocialFull$WeekId = as.character(featureSocialFull$WeekId)
for(i in 1:nrow(featureSocialFull))
{
	date = strsplit(featureSocialFull[i,'WeekId'], "[-]");
	weekid = paste(date[[1]][2],date[[1]][3],date[[1]][1],sep="/");
	featureSocialFull[i,'Date'] = DateToWeekTag(weekid);
}

consensusFull = read.csv(file=path_consensus, head=TRUE, sep=",");
consensusFull$Date = as.character(consensusFull$Date)
for(i in 1:nrow(consensusFull))
{
	consensusFull[i,'Date'] = DateToWeekTag(consensusFull[i,'Date']);
}

start_date = "20120106";	#earliest data to use
end_date = "20140411";	#latest data to use

featureAR = featureARFull[which(featureARFull$Date==start_date)[1]:which(featureARFull$Date==end_date)[1],];
featureSocial = featureSocialFull[which(featureSocialFull$Date==start_date)[1]:which(featureSocialFull$Date==end_date)[1],];
consensus = consensusFull[which(consensusFull$Date==start_date)[1]:which(consensusFull$Date==end_date)[1],];

label = featureAR$Label;


#prepare feature combos
featureARCombos = PrepareFeatureCombos_AR(featureAR);
featureSocialCombos = PrepareFeatureCombos_Social();
featureConsensusCombos = PrepareFeatureCombos_Consensus();

featureFull = merge(featureAR, featureSocial, by="Date");
featureFull = merge(featureFull, consensus, by="Date");

#train model and output metrics
featureFullCombos = list();
pos = 1;
for(i in 1:length(featureARCombos))
{
	for(j in 1:length(featureConsensusCombos))
	{
		for(k in 1:length(featureSocialCombos))
		{
			print(c(i,j,k));
			currentFeatureCombo = c(featureARCombos[[i]], featureConsensusCombos[[j]], featureSocialCombos[[k]]);
			if(length(currentFeatureCombo)==0)
			{
				next;
			}

			featureFullCombos[[pos]] = currentFeatureCombo;
			pos = pos+1;
		}
	}
}

# options(warn=2)

metricList = CompileTrainingResults_RandomSampling(featureFull,featureFullCombos,label,consensus$DeltaConsensus,lambda,directionalConstraint=TRUE,aggregationType);

for(type in aggregationType)
{
	path_outMetric_type = gsub(".csv", paste(paste("_",type,sep=""),".csv",sep=""), path_outMetric);
	write.csv(metricList[[type]], file = path_outMetric_type);
}


# LearningIJC = function()
# {
# 	require('glmnet');
# 	#readin data & initialization
# 	path_featureAR = "../Features/AR/Features_AR_Delta.csv";
# 	path_featureSocial = "../Features/201410_2/Features_All_candiate_seperated_AbsoluteFull.csv";
# 	path_consensus = "../GroundTruth/Consensus.csv";
# 	path_outMetric = "../Model/201410/experiments_Model_3.csv";
# 	path_outPrediction = "../Model/201410/experiments_Model_3_Prediction.csv";

# 	featureARFull = read.csv(file=path_featureAR, head=TRUE, sep=",");
# 	featureARFull$Date = as.character(featureARFull$Date)
# 	for(i in 1:nrow(featureARFull))
# 	{
# 		featureARFull[i,'WeekId'] = DateToWeekTag(featureARFull[i,'Date']);
# 	}

# 	featureSocialFull = read.csv(file=path_featureSocial, head=TRUE, sep=",");
# 	featureSocialFull$WeekId = as.character(featureSocialFull$WeekId)
# 	for(i in 1:nrow(featureSocialFull))
# 	{
# 		featureSocialFull[i,'WeekId'] = DateToWeekTag(featureSocialFull[i,'WeekId']);
# 	}

# 	consensusFull = read.csv(file=path_consensus, head=TRUE, sep=",");
# 	consensusFull$Date = as.character(consensusFull$Date)
# 	for(i in 1:nrow(consensusFull))
# 	{
# 		consensusFull[i,'WeekId'] = DateToWeekTag(consensusFull[i,'Date']);
# 	}

# 	start_date = "20120106";
# 	end_date = "20141010";

# 	featureAR = featureARFull[which(featureARFull$WeekId==start_date)[1]:which(featureARFull$WeekId==end_date)[1],];
# 	featureSocial = featureSocialFull[which(featureSocialFull$WeekId==start_date)[1]:which(featureSocialFull$WeekId==end_date)[1],];
# 	featureConsensus = consensusFull[which(consensusFull$WeekId==start_date)[1]:which(consensusFull$WeekId==end_date)[1],];

# 	featureFull = merge(featureAR, featureSocial, by="WeekId");
# 	featureFull = merge(featureFull, featureConsensus, by="WeekId");

# 	featureFull = subset(featureFull, select=-c(Date.x,Date.y));

# 	# Partition data into training and testing sets
# 	bound = floor(nrow(featureFull)/4*3);
# 	data_training = featureFull[1:bound,];
# 	data_testing = featureFull[(bound+1):nrow(featureFull),];

# 	y_training = data_training$Label;
# 	y_testing = data_testing$Label;

# 	consensus_training = data_training$DeltaConsensus;
# 	consensus_testing = data_testing$DeltaConsensus;

# 	x_training = subset(data_training, select=-c(WeekId,Label));
# 	x_testing = subset(data_testing, select=-c(WeekId,Label));

# 	# options(warn=2)

# 	cvfit = cv.glmnet(as.matrix(x_training), y_training, type.measure="mse", nfolds=nrow(x_training), parallel=TRUE, alpha=1);

# 	predictions = predict(cvfit, newx=as.matrix(x_testing), s="lambda.min");

# 	residuals = abs(predictions-y_testing);

# 	L1 = mean(residuals);
# 	medianL1 = median(residuals);
# 	L2 = sqrt(mean(residuals^2));
# 	medianL2 = sqrt(median(residuals^2));
# 	Win = sum(residuals<abs(consensus_testing-y_testing));
# 	DirectionalWin = sum((predictions-consensus_testing)*(y_testing-consensus_testing)>0);
# 	WeightedWin = sum((-1)^((residuals<abs(consensus_testing-y_testing))-1)*abs(residuals-abs(consensus_testing-y_testing)));

# 	metricList = data.frame(Features=character(),"L1"=character(),"medianL1"=character(),"L2"=character(),"medianL2"=character(),"Win"=character(),"DirectionalWin"=character(),"WeightedWin"=character(),stringsAsFactors=FALSE);

# 	results = data.frame(Predictions=predictions, Label=y_testing, Consensus=consensus_testing);

# 	write.csv(results, file = path_outPrediction);
	
# 	metricList[1,] = c("Performance",L1,medianL1,L2,medianL2,Win,DirectionalWin,WeightedWin);

# 	write.csv(metricList, file = path_outMetric);
# }

# LearningIJC_PCA = function()
# {
# 	require('glmnet');
# 	#readin data & initialization
# 	load("scaledFeatureFull_20120106_20141010.Rdata");
# 	featureFull = projected.featureFull;
# 	load("label_20120106_20141010.Rdata");
# 	path_consensus = "../GroundTruth/Consensus.csv";
# 	path_outMetric = "../Model/201410/experiments_Model_4.csv";
# 	path_outPrediction = "../Model/201410/experiments_Model_4_Prediction.csv";

# 	consensusFull = read.csv(file=path_consensus, head=TRUE, sep=",");
# 	consensusFull$Date = as.character(consensusFull$Date)
# 	for(i in 1:nrow(consensusFull))
# 	{
# 		consensusFull[i,'WeekId'] = DateToWeekTag(consensusFull[i,'Date']);
# 	}

# 	start_date = "20120106";
# 	end_date = "20141010";

# 	featureConsensus = consensusFull[which(consensusFull$WeekId==start_date)[1]:which(consensusFull$WeekId==end_date)[1],];

# 	# Partition data into training and testing sets
# 	bound = floor(nrow(featureFull)/4*3);
# 	x_training = featureFull[1:bound,];
# 	x_testing = featureFull[(bound+1):nrow(featureFull),];

# 	y_training = label[1:bound,];
# 	y_testing = label[(bound+1):nrow(label),];

# 	consensus_training = featureConsensus[1:bound,]$DeltaConsensus;
# 	consensus_testing = featureConsensus[(bound+1):nrow(featureConsensus),]$DeltaConsensus;

# 	# options(warn=2)

# 	cvfit = cv.glmnet(as.matrix(x_training), y_training, type.measure="mse", nfolds=nrow(x_training), parallel=TRUE, alpha=1);

# 	predictions = predict(cvfit, newx=as.matrix(x_testing), s="lambda.min");

# 	residuals = abs(predictions-y_testing);

# 	L1 = mean(residuals);
# 	medianL1 = median(residuals);
# 	L2 = sqrt(mean(residuals^2));
# 	medianL2 = sqrt(median(residuals^2));
# 	Win = sum(residuals<abs(consensus_testing-y_testing));
# 	DirectionalWin = sum((predictions-consensus_testing)*(y_testing-consensus_testing)>0);
# 	WeightedWin = sum((-1)^((residuals<abs(consensus_testing-y_testing))-1)*abs(residuals-abs(consensus_testing-y_testing)));

# 	metricList = data.frame(Features=character(),"L1"=character(),"medianL1"=character(),"L2"=character(),"medianL2"=character(),"Win"=character(),"DirectionalWin"=character(),"WeightedWin"=character(),stringsAsFactors=FALSE);

# 	results = data.frame(Predictions=predictions, Label=y_testing, Consensus=consensus_testing);

# 	write.csv(results, file = path_outPrediction);
	
# 	metricList[1,] = c("Performance",L1,medianL1,L2,medianL2,Win,DirectionalWin,WeightedWin);

# 	write.csv(metricList, file = path_outMetric);
# }

# LearningIJC_RollingTesting_PCA = function()
# {

# 	#readin data & initialization
# 	path_featureAR = "../Features/AR/Features_AR_Delta.csv";
# 	path_featureSocial = "../Features/201410/Features_All_candiate_seperated_AbsoluteFull.csv";
# 	path_consensus = "../GroundTruth/Consensus.csv";
# 	path_outMetric = "../Model/201410/experiments_Model_5.csv";

# 	featureARFull = read.csv(file=path_featureAR, head=TRUE, sep=",");
# 	featureARFull$Date = as.character(featureARFull$Date)
# 	for(i in 1:nrow(featureARFull))
# 	{
# 		featureARFull[i,'WeekId'] = DateToWeekTag(featureARFull[i,'Date']);
# 	}

# 	featureSocialFull = read.csv(file=path_featureSocial, head=TRUE, sep=",");
# 	featureSocialFull$WeekId = as.character(featureSocialFull$WeekId)
# 	for(i in 1:nrow(featureSocialFull))
# 	{
# 		featureSocialFull[i,'WeekId'] = DateToWeekTag(featureSocialFull[i,'WeekId']);
# 	}

# 	consensusFull = read.csv(file=path_consensus, head=TRUE, sep=",");
# 	consensusFull$Date = as.character(consensusFull$Date)
# 	for(i in 1:nrow(consensusFull))
# 	{
# 		consensusFull[i,'WeekId'] = DateToWeekTag(consensusFull[i,'Date']);
# 	}

# 	start_date = "20120106";
# 	end_date = "20141010";

# 	start_consensus_testing = "20140131";
# 	end_consensus_testing = "20141003";

# 	featureAR = featureARFull[which(featureARFull$WeekId==start_date)[1]:which(featureARFull$WeekId==end_date)[1],];
# 	featureSocial = featureSocialFull[which(featureSocialFull$WeekId==start_date)[1]:which(featureSocialFull$WeekId==end_date)[1],];
# 	featureConsensus = consensusFull[which(consensusFull$WeekId==start_date)[1]:which(consensusFull$WeekId==end_date)[1],];

# 	consensus = consensusFull[which(consensusFull$WeekId==start_consensus_testing)[1]:which(consensusFull$WeekId==end_consensus_testing)[1],];


# 	label = featureAR$Label;

# 	featureFull = merge(featureAR, featureSocial, by="WeekId");
# 	featureFull = merge(featureFull, featureConsensus, by="WeekId");

# 	featureFull = subset(featureFull, select=-c(Date.x,Date.y));

# 	featureFull = featureFull[3:ncol(featureFull)];
# 	scaled.featureFull = scale(featureFull);
# 	featureFull.pca = prcomp(scaled.featureFull, center=TRUE, scale.=TRUE);
# 	projected.featureFull = as.data.frame(scaled.featureFull%*%featureFull.pca$rotation);

# 	#train model and output metrics
# 	featureFullCombos = list();
# 	for(i in 1:30)
# 	{
# 		currentFeatureCombo = paste("PC",1:i,sep="");
# 		featureFullCombos[[i]] = currentFeatureCombo;
# 	}

# 	# options(warn=2)

# 	metricList = CompileTrainingResults(projected.featureFull,featureFullCombos,label,consensus);

# 	write.csv(metricList, file = path_outMetric);
# }