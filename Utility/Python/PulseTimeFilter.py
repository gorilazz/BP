import csv
from datetime import datetime


pulseFile = open('C:\\Users\\yuzhan\\SkyDrive\\Data\\BingPrediction\\EOY\\Travel\\MonthlyCounts.txt','rt',encoding='utf-8')
pulseFile_clean = open('C:\\Users\\yuzhan\\SkyDrive\\Data\\BingPrediction\\EOY\\Travel\\MonthlyCounts_clean.txt','wt',encoding='utf-8')

pulse = csv.reader(pulseFile,delimiter='\t')
header = next(pulse)

startTime = datetime.strptime('01/01/2013', '%m/%d/%Y')

cleanedPulse = []

cleanedPulse.append('\t'.join(header))

for row in pulse:
	date = row[1][0:4]+' '+row[1][4:6]
	curDate = datetime.strptime(date,'%Y %m')
	if curDate>=startTime:
		cleanedPulse.append('\t'.join(row))

pulseFile_clean.write('\n'.join(cleanedPulse))
pulseFile.close()