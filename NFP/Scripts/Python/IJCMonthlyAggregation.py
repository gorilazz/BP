import csv

with open('C:\\Users\\yuzhan\\Git\\Predictions\\IJC\\GroundTruth\\IJC.csv', 'rt', encoding='utf-8') as ijc_weekly_file, \
open('C:\\Users\\yuzhan\\Git\\Predictions\\IJC\\GroundTruth\\IJC.csv', 'rt', encoding='utf-8') as ijc_month_file:
	
	ijc_weekly = csv.reader(ijc_weekly_file, delimiter=",")

	next(ijc_weekly)

	for row in ijc_weekly:
		