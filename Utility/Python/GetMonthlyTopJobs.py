import csv
import string
from collections import OrderedDict

blackList_match = ['job posting','job postings','job opening','job openings','job opportunity', 'job opportunities', 'full time','good fit','fit job','apply today','join team','latest job','sad news','hiring people','hiring employees', \
'hiring talent','employment job','career search','search job','search employment','job search','entry level','job vacancy', 'make money', 'money home', 'part time', 'send resume', 'search results', '']

blackList_contain = ['united kingdom', 'united states', 'york ny','london', 'money']

def PartialMatch(ngram, blacklist):
	for item in blacklist:
		if item in ngram:
			return True

	return False

def GetJobCount(ngrams):
	ngramList = ngrams.split('||')

	topNgrams = [ngram.split('|')[0] for ngram in ngramList]

	counts = [ngram.split(':')[1] for ngram in ngramList]

	topNgrams_counts = {topNgrams[i]:int(counts[i]) for i in range(0,len(topNgrams))}

	return topNgrams_counts

def ProcessNgrams(ngrams,whiteList):
	ngramList = ngrams.split('||')

	topNgrams = [ngram.split('|')[0] for ngram in ngramList]

	counts = [ngram.split(':')[1] for ngram in ngramList]

	topNgrams_counts = {topNgrams[i]:int(counts[i]) for i in range(0,len(topNgrams))}

	category_counts = {}

	count = 0

	for key in topNgrams_counts.keys():
		if key in whiteList.keys():
			if not whiteList[key] in category_counts.keys():
				category_counts[whiteList[key]] = topNgrams_counts[key]
			else:
				category_counts[whiteList[key]] = category_counts[whiteList[key]] + topNgrams_counts[key]

	sorted(category_counts, key=category_counts.get)

	return category_counts

with open('C:\\Users\\yuzhan\\Git\\Predictions\\NFP\\Pulse\\201410\\All_True_MonthlyCountsWithNgrams_1k.txt', 'rt', encoding='UTF-8') as MonthlyPulse, \
open('C:\\Users\\yuzhan\\Git\\Predictions\\NFP\\Pulse\\201410\\All_True_Category_Counts.csv', 'wt', encoding='UTF-8') as Category_Counts, \
open('C:\\Users\\yuzhan\\Git\\Predictions\\NFP\\Pulse\\201410\\All_True_CommonTopCategories.txt', 'rt', encoding='UTF-8') as Jobs, \
open('C:\\Users\\yuzhan\\Git\\Predictions\\NFP\\Pulse\\201410\\All_True_TopJobs_Category.txt', 'wt', encoding='UTF-8') as TopJobs_Category:

	jobs = Jobs.read().splitlines()

	categories = {}

	for row in jobs:
		category = row.split('\t')[0]
		positions = row.split('\t')[1].split(',')
		for position in positions:
			categories[position] = category

	pulse = csv.reader(MonthlyPulse,delimiter="\t")
	next(pulse)

	result = {}

	keyset = []

	monthlyJobCounts = {}

	for row in pulse:
		filter = row[0]
		monthid = int(row[1])
		if filter=='all':
			processedRow = ProcessNgrams(row[14],categories)
			result[monthid] = processedRow
			monthlyJobCounts[monthid] = GetJobCount(row[14])
			if not keyset:
				keyset = processedRow.keys()

	jobNames = ",".join(sorted(keyset))

	Category_Counts.write(" "+","+jobNames)

	Category_Counts.write("\n")

	for key in result.keys():
		counts = ','.join(str(val) for (k,val) in result[key].items())
		Category_Counts.write(str(key)+","+counts)
		Category_Counts.write("\n")

	Category_Counts.close()

	totalJobCounts = {}

	for month in monthlyJobCounts.keys():
		for job in monthlyJobCounts[month].keys():
			if not job in categories.keys():
				continue
			category = categories[job]
			if not category in totalJobCounts.keys():
				totalJobCounts[category] = {}
				totalJobCounts[category][job] = monthlyJobCounts[month][job]
			else:
				if not job in totalJobCounts[category].keys():
					totalJobCounts[category][job] = monthlyJobCounts[month][job]
				else:
					totalJobCounts[category][job] = totalJobCounts[category][job] + monthlyJobCounts[month][job]

	for category in totalJobCounts.keys():
		jobs = [[k, val] for (k, val) in totalJobCounts[category].items()]
		jobs.sort(key = lambda x:x[1], reverse = True)
		jobs = [job[0]+':'+str(job[1]) for job in jobs]
		TopJobs_Category.write("%s\n" % (category+"\t"+','.join(jobs)))

	TopJobs_Category.close()



