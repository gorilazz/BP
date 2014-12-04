input_paths = c('../Features/201411/DaysBack_7_Features_All_candiate_seperated_Absolute');

for(i in 1:length(input_paths))
{
	input_path = paste(input_paths[i],'.csv',sep='');
	output_path = paste(input_paths[i],'Delta.csv',sep='');

	featureSocialFull = read.csv(file=input_path, head=TRUE, sep=",");

	deltaFeatureFull = data.frame();
	for(i in 2:nrow(featureSocialFull))
	{
		prev = featureSocialFull[i-1,];
		current = featureSocialFull[i,];

		header = current[2];

		delta = current[3:ncol(current)] - prev[3:ncol(current)];
		deltaFeatureFull = rbind(deltaFeatureFull, c(header,delta));
	}

	deltaFeatureFull = deltaFeatureFull[1:ncol(deltaFeatureFull)];

	write.csv(deltaFeatureFull, file = output_path,row.names=F);
}
