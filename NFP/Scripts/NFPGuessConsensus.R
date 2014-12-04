# Generate consensus from #NFPGuess

source('../../Utility/utility.R');
source('../../Utility/learning_utility.R');
source('../../Utility/automation_utility.R');

month = 11;

date_start = "2014-11-08";	
date_end = "2014-12-04";

path_prediction = "../Model/NFPGuess/201411/NFPGuess_Prediction.txt";
path_consensus = paste(paste("../Model/NFPGuess/201411/NFPGuess_Consensus", month, sep='_'), ".csv", sep='');

tweetsPrediction = read.csv(file=path_prediction, head=TRUE, sep="\t");

# for(i in 1:nrow(tweetsPrediction))
# {
# 	tweetsPrediction[i,"Time_datetime"] = strptime(strsplit(tweetsPrediction[i,"ReceivedTimePT"],"[' ']")[0],"%m/%d/%Y");
# }

tweetsPrediction = tweetsPrediction[strptime(strsplit(as.character(tweetsPrediction$ReceivedTimePT),"[' ']")[0],"%m/%d/%Y")>=strptime(date_start,"%Y-%m-%d"),];
tweetsPrediction = tweetsPrediction[strptime(strsplit(as.character(tweetsPrediction$ReceivedTimePT),"[' ']")[0],"%m/%d/%Y")<=strptime(date_end,"%Y-%m-%d"),];

tweetsPrediction = tweetsPrediction$NFPPrediction;