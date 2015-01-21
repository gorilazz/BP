# Generate consensus from #NFPGuess

source('../../Utility/utility.R');
source('../../Utility/learning_utility.R');
source('../../Utility/automation_utility.R');

date_start = c("2013-10-05", "2013-11-02", "2013-12-07", "2014-01-04", "2014-02-08", "2014-03-08", "2014-04-05", "2014-05-03", "2014-06-07", "2014-07-05", "2014-08-02", "2014-09-06", "2014-10-04", "2014-11-08", "2014-12-06");
date_end = c("2013-10-28", "2013-12-02", "2013-12-30", "2014-02-03", "2014-03-03", "2014-03-31", "2014-04-28", "2014-06-02", "2014-06-30", "2014-07-28", "2014-09-01", "2014-09-29", "2014-11-03", "2014-12-01", "2014-01-05");


path_prediction = "../Model/NFPGuess/201412/NFPGuess_Prediction.txt";
path_consensus = "../Model/NFPGuess/201412/NFPGuess_Consensus_Mon.txt";

tweetsPrediction = read.csv(file=path_prediction, quote = "", head=TRUE, sep="\t");

# for(i in 1:nrow(tweetsPrediction))
# {
# 	tweetsPrediction[i,"Time_datetime"] = strptime(strsplit(tweetsPrediction[i,"ReceivedTimePT"],"[' ']")[0],"%m/%d/%Y");
# }

for(i in 1:nrow(tweetsPrediction))
{
	tweetsPrediction[i,'date'] = strsplit(as.character(tweetsPrediction[i, 'ReceivedTimePT']),"[' ']")[[1]][1];
}

taggedPrediction = matrix(nrow=0, ncol=(ncol(tweetsPrediction)+1));

for(i in length(date_start))
{
	a = tweetsPrediction[strptime(tweetsPrediction$date,"%m/%d/%Y")>=strptime(date_start[i],"%Y-%m-%d"),];
	a = tweetsPrediction[strptime(a$date,"%m/%d/%Y")<=strptime(date_end[i],"%Y-%m-%d"),];
	a = cbind(a, strsplit(date_start,'[-]')[[1]][-3]);
	taggedPrediction = rbind(taggedPrediction, a);
}



write.table(taggedPrediction,file=path_consensus,sep='\t');