#readin data
featureARFull = read.csv(file="ARDelta_Full.csv", head=TRUE, sep=",");
featureSocialFull = read.csv(file="../201408/DaysBack_7_Window2_Log_Delta.csv", head=TRUE, sep=",");

data_length = nrow(featureSocialFull);

featureAR = featureARFull[171:(171+data_length-1),];

featureSocial = featureSocialFull[1:(1+data_length-1),];
featureSocial_clean = featureSocial[,4:ncol(featureSocial)];

label = featureAR$Label;

corr = cor(featureSocial_clean,label);