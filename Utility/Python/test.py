import csv
import string

blackList_match = ['job posting','job postings','job opening','job openings','job opportunity', 'job opportunities', 'full time','good fit','fit job','apply today','join team','latest job','sad news','hiring people','hiring employees', \
'hiring talent','employment job','career search','search job','search employment','job search','entry level','job vacancy', 'make money', 'money home', 'part time', 'send resume', 'search results', 'apply today', 'united kingdom', \
'united states', 'united arab', 'los angeles', 'las vegas', 'des moines', 'fort worth', 'palo alto', 'work home', 'accepting applications', 'aspen dental', 'assistant store', 'baker hughes', 'baylor health', 'charles schwab', \
'care system','hiring software', 'liberty mutual insurance', 'robert half finance', 'citizens financial group', 'citizens financial', 'half finance' ,'senior account', 'senior financial', 'accountable healthcare','kraft foods']

blackList_contain = ['fresenius','accounts', 'home', 'arab', 'saudi', 'singapore', 'south', 'job', 'years', 'year', 'st', 'san', 'santa', 'city', 'united', 'qatar', 'needed', 'colorado', 'england', 'midlands', 'ireland', 'vancouver', \
'washington', 'chicago', 'houston', 'north', 'apply', 'york','london', 'money', 'canada', 'ma', 'tn', 'ne', 'il', 'ca', 'ny', 'fl', 'wa', 'va', 'tx', 'md', 'al', 'ga', 'nj', 'mo', \
'ut', 'mi', 'nc', 'de', 'ab', 'ky', 'wi', 'nv', 'az', 'pa', 'mn', 'qc']

def PartialMatch(ngram, blacklist):
	for item in blacklist:
		if item in ngram.split(' '):
			return True

	return False


def ProcessNgrams(ngrams):
	ngramList = ngrams.split('||')

	topNgrams = [ngram.split('|')[0] for ngram in ngramList]

	topNgrams = [ngram for ngram in topNgrams if not ngram in blackList_match]

	topNgrams = [ngram for ngram in topNgrams if not PartialMatch(ngram, blackList_contain)]

	topNgrams.sort()

	return topNgrams

with open('C:\\Users\\yuzhan\\Git\\Predictions\\NFP\\Pulse\\201410\\All_True_MonthlyCountsWithNgrams_1k.txt', 'rt', encoding='UTF-8') as MonthlyPulse, \
open('C:\\Users\\yuzhan\\Git\\Predictions\\NFP\\Pulse\\201410\\All_True_CommonTopJobs_1k_2014.csv', 'wt', encoding='UTF-8') as CommonTopJobs:

	pulse = csv.reader(MonthlyPulse,delimiter="\t")
	next(pulse)

	result = {}

	keyset = []

	for row in pulse:
		filter = row[0]
		monthid = int(row[1])
		if monthid<201401:
			continue
		if filter=='all':
			processedRow = ProcessNgrams(row[14])
			if not keyset:
				keyset = processedRow
			else:
				keyset = [ngram for ngram in keyset if ngram in processedRow]

	for job in keyset:
		CommonTopJobs.write("%s\n" % job)

	CommonTopJobs.close()
