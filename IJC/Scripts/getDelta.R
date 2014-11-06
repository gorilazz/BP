input_paths = c('../Features/201410_2/Features_All_candiate_seperated');

for(i in 1:length(input_paths))
{
	input_path = paste(input_paths[i],'_Absolute.csv',sep='');
	output_path = paste(input_paths[i],'_AbsoluteDelta.csv',sep='');

	featureSocialFull = read.csv(file=input_path, head=TRUE, sep=",");

	featureSocialFull$WeekId = as.character(featureSocialFull$WeekId);

	deltaFeatureFull = data.frame(matrix(ncol=ncol(featureSocialFull)),stringsAsFactors=FALSE);


	names(deltaFeatureFull) = names(featureSocialFull);
	for(j in 2:nrow(featureSocialFull))
	{
		prev = featureSocialFull[j-1,];
		current = featureSocialFull[j,];

		header = current[1];

		delta = current[2:ncol(current)] - prev[2:ncol(current)];
		deltaFeatureFull = rbind(deltaFeatureFull, c(header,delta));
	}

	deltaFeatureFull = deltaFeatureFull[complete.cases(deltaFeatureFull),];

	write.csv(deltaFeatureFull, file = output_path,row.names=F);
}