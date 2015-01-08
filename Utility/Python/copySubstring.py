import csv

with open('D:\\src\\relevanceprojects\\private\\SocialRelevance\\TSS\\Static.Data\\EOY\\TopFashion.txt', 'rt', encoding = 'UTF-8') as data, \
open('D:\\src\\relevanceprojects\\private\\SocialRelevance\\TSS\\Static.Data\\EOY\\TopFashion_clean.txt', 'wt', encoding = 'UTF-8') as clean_data:

	d = csv.reader(data, delimiter='\t')

	next(d)

	output = []
	dest = {}

	conditions = []

	for row in d:
		loc = row[0].strip("\"").split(',')[0]
		if len(row)>=3:
			alias = row[2].strip('1:').split(',')
			alias = [x for x in alias if x]
		else:
			alias = []

		if loc in dest:
			dest[loc].extend(alias)
		else:
			if not alias:
				dest[loc] = [loc]
			else:
				dest[loc] = alias

	for loc in dest:
		output.append(loc+'\t\t'+':'+','.join(dest[loc])+'\t'+','.join(conditions)+'\t')

	clean_data.write('\n'.join(output))

	clean_data.close()
