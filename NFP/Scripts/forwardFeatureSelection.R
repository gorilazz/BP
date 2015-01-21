# Do the forward feature selection to select the best features based on certain metric, e.g. L1 or DWin, evaluated with cross-validation
rm(list=ls());
start = Sys.time();

source('../../Utility/NFP_utility.R');
source('../../Utility/utility.R');
source('../../Utility/learning_utility.R');
source('../../Utility/automation_utility.R');

lambda = 0.0;
aggregationType = c("mean");
metricType = "DWin";
num_features = 10;

path_featureAR = "../Features/AR/ARDelta_Full.csv";
path_featureSocial = "../Features/201412/DaysBack_7_Features_All_candidate_seperated_AbsoluteFull.csv";
path_consensus = "../GroundTruth/Consensus.csv";
path_IJC = "../Features/IJC/IJC_3_weeks.csv";
path_label = "../GroundTruth/NonFarmPayrollHistoryDelta.csv"
path_outMetric = paste(paste("../Features/201412/ForwardSelection/Features_All", metricType, sep="_"),".csv",sep="");

# read in data
featureARFull = read.csv(file=path_featureAR, head=TRUE, sep=",");
featureARFull$Date = as.character(featureARFull$Date);
for(i in 1:nrow(featureARFull))
{
	featureARFull[i,'Date'] = DateToMonthTag(featureARFull[i,'Date']);
}

featureSocialFull = read.csv(file=path_featureSocial, head=TRUE, sep=",");

consensusFull = read.csv(file=path_consensus, head=TRUE, sep=",");
consensusFull$Date = as.character(consensusFull$Date);
for(i in 1:nrow(consensusFull))
{
	consensusFull[i,'Date'] = DateToMonthTag(consensusFull[i,'Date']);
}

IJCFull = read.csv(file=path_IJC, head=TRUE, sep=",");
IJCFull$Date = as.character(IJCFull$Date);
for(i in 1:nrow(IJCFull))
{
	IJCFull[i,'Date'] = DateToMonthTag(IJCFull[i,'Date']);
}

labelFull = read.csv(file=path_label, head=TRUE, sep=",");
labelFull$Date = as.character(labelFull$Date);
for(i in 1:nrow(labelFull))
{
	labelFull[i,'Date'] = DateToMonthTag(labelFull[i,'Date']);
}

# get the data
data_start = "201103";		# earliest data to use	
data_end = "201408";	# latest data to use for testing

# subset the data frames to get the right segments
start_featureAR = which(featureARFull$Date==data_start)[1];
end_featureAR = which(featureARFull$Date==data_end)[1];
start_featureSocial = which(featureSocialFull$Date==data_start)[1];
end_featureSocial = which(featureSocialFull$Date==data_end)[1];
start_featureIJC = which(IJCFull$Date==data_start)[1];
end_featureIJC = which(IJCFull$Date==data_end)[1];
start_consensus = which(consensusFull$Date==data_start)[1];
end_consensus = which(consensusFull$Date==data_end)[1];
start_label = which(labelFull$Date==data_start)[1];
end_label = which(labelFull$Date==data_end)[1];


featureAR = featureARFull[start_featureAR:end_featureAR,];
featureSocial = featureSocialFull[start_featureSocial:end_featureSocial,];
featureIJC = IJCFull[start_featureIJC:end_featureIJC,];
consensus = consensusFull[start_consensus:end_consensus,];		#consensus to be used for testing

label = labelFull[start_label:end_label,]$Delta_Unrevised;

# merge AR, social, consensus, IJC features to get the full feature set
featureFull = merge(featureSocial, consensus, by="Date");
featureFull = merge(featureFull, featureIJC, by="Date");

allFeatureNames = names(featureFull);
allFeatureNames = allFeatureNames[! allFeatureNames %in% c('Consensus2')];

selectedFeatureNames = c();	

for(i in 1:num_features)
{
	leftFeatureNames = allFeatureNames[! allFeatureNames %in% selectedFeatureNames];
	featureFullCombos = list();
	pos = 1;
	for(f in leftFeatureNames)
	{
		curCombo = c(selectedFeatureNames, f);
		featureFullCombos[[pos]] = curCombo;
		pos = pos+1;
		print(pos);
	}

	metricList = CompileTrainingResults_CV(featureFull,featureFullCombos,label,consensus$Consensus1,lambda,directionalConstraint=TRUE, aggregationType, 7);

	metric = metricList[["mean"]];
	if(metricType=="L1")
	{
		idx = which.min(metric[,2]);
		candidate = metric[idx,];
		if(length(candidate)>15)
		{
			bestCombo = candidate[which.max(candidate[,7])][1];
		}
		else
		{
			bestCombo = candidate[1];
		}
		
	}
	else
	{
		idx = which.max(metric[,7]);
		candidate = metric[idx,];
		if(length(candidate)>15)
		{
			bestCombo = candidate[which.min(candidate[,2])][1];
		}
		else
		{
			bestCombo = candidate[1];
		}
	}

	selectedFeatureNames = strsplit(bestCombo,'[+]')[[1]];
}

write.csv(selectedFeatureNames, file = path_outMetric);