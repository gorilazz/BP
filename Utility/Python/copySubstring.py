import csv

with open('C:\\Users\\yuzhan\\Desktop\\Book1.csv', 'rt', encoding = 'UTF-8') as data, \
open('C:\\Users\\yuzhan\\Desktop\\Book1_clean.txt', 'wt', encoding = 'UTF-8') as clean_data:

	d = csv.reader(data, delimiter='\t')

	next(d)

	output = []

	for row in d:
		output.append(row[0].strip()+'\t\t'+'1:'+row[0].strip()+'\t'+'travel,trip,tour'+'\t')

	clean_data.write('\n'.join(output))

	clean_data.close()
