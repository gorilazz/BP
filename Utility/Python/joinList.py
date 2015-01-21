import csv

in_file = open('C:\\Users\\yuzhan\\Desktop\\mexico_cities.txt','rt',encoding='utf-8')
out_file = open('C:\\Users\\yuzhan\\Desktop\\mexico_cities_out.txt','wt',encoding='utf-8')

data = csv.reader(in_file,delimiter='\t')

name = []


for row in data:
	name.append(row[1])

out_file.write(','.join(name))

out_file.close()