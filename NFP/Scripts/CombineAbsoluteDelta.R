require('plyr');


input_paths = c('../Features/201411/DaysBack_7_Features_All_candiate_seperated_Absolute');

for(i in 1:length(input_paths))
{

	input_path_a = paste(input_paths[i],'.csv',sep='');
	input_path_d = paste(input_paths[i],'Delta.csv',sep='');
	output_path = paste(input_paths[i],'Full.csv',sep='');

	Features_A = read.csv(file=input_path_a, head=TRUE, sep=",");
	Features_D = read.csv(file=input_path_d, head=TRUE, sep=",");

	names_a = names(Features_A);
	names_a = paste(names_a,'Absolute',sep='_');
	names_a[1]='Date';
	colnames(Features_A)<-names_a;

	names_d = names(Features_D);
	names_d = paste(names_d,'AbsoluteDelta',sep='_');
	names_d[1]='Date';
	colnames(Features_D)<-names_d;


	Features_Full = join_all(list(Features_A,Features_D),by='Date',type='full');

	write.csv(Features_Full, file=output_path,row.names=F);
}