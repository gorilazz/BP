require('plyr');


input_paths = c('../Features/201411/Features_All_candiate_seperated_Absolute','../Features/201411/Features_NFP_All_candiate_seperated_Absolute');

for(i in 1:length(input_paths))
{

	input_log_path = paste(input_paths[i],'.csv',sep='');
	input_log_delta_path = paste(input_paths[i],'Delta.csv',sep='');
	output_path = paste(input_paths[i],'Full.csv',sep='');

	Log_Features = read.csv(file=input_log_path, head=TRUE, sep=",");
	LogDelta_Features = read.csv(file=input_log_delta_path, head=TRUE, sep=",");

	names_log = names(Log_Features);
	names_log = paste(names_log,'_Absolute',sep='');
	names_log[1]='WeekId';
	colnames(Log_Features)<-names_log;

	names_logdelta = names(LogDelta_Features);
	names_logdelta = paste(names_logdelta,'_AbsoluteDelta',sep='');
	names_logdelta[1]='WeekId';
	colnames(LogDelta_Features)<-names_logdelta;


	Features_Full = join_all(list(Log_Features,LogDelta_Features),by='WeekId',type='full');

	Features_Full = Features_Full[complete.cases(Features_Full),];

	write.csv(Features_Full, file=output_path,row.names=F);
}