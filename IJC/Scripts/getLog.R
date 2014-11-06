input_paths = c('../Features/201409/Features_All_candiate_seperated');

for(i in 1:length(input_paths))
{
	input_path = paste(input_paths[i],'.csv',sep='');
	output_path = paste(input_paths[i],'_Log.csv',sep='');
	featureSocialFull = read.csv(file=input_path, head=TRUE, sep=",");

	header = featureSocialFull$Date;

	logvalue = log(featureSocialFull[1:nrow(featureSocialFull),2:ncol(featureSocialFull)]+1);

	logFeatureFull=cbind(header,logvalue);
	names(logFeatureFull)[1] = 'Date';

	write.csv(logFeatureFull, file = output_path,row.names=F);
}