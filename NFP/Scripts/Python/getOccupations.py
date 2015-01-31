from numpy import *
import inflect
import csv

def main():
	raw_data = open('C:\\Users\\yuzhan\\Git\\Predictions\\NFP\\ResourceData\\Occupations.txt','rt',encoding='utf-8')
	parsed_data = open('C:\\Users\\yuzhan\\Git\\Predictions\\NFP\\ResourceData\\Occupations_BySection.txt','wt',encoding='utf-8')
	parsed_data_unified = open('C:\\Users\\yuzhan\\Git\\Predictions\\NFP\\ResourceData\\Occupations_All.txt','wt',encoding='utf-8')

	occupations = csv.reader(raw_data,delimiter='\t')

	next(occupations)

	jobs = {}

	jobs_all = set()

	p = inflect.engine()

	for row in occupations:
		sector_name = row[1].lower()
		job_name = [item.strip() for item in row[4].lower().split(',')[0].strip().split('and')]
		job_number = int(row[5].replace(',',''))
		synonyms = row[6:]
		synonyms = [item.lower().split('(')[0].strip() for item in synonyms]

		if job_number<100000:
			continue

		jobs[sector_name] = jobs.get(sector_name,set())

		for title in job_name:
			job = title.split(' of ')[0].split(' ')[-1].split('/')[0].strip() if ' of ' in title else title.split(' ')[-1].split('/')[0].strip()	
			if len(job)<3:
				continue		
			singular = p.singular_noun(job) if p.singular_noun(job) else ''
			if singular and not singular in jobs[sector_name]:
				jobs[sector_name].add(singular)
			if singular and not singular in jobs_all:
				jobs_all.add(singular)
			if job and not job in jobs[sector_name]:
				jobs[sector_name].add(job)
			if job and not job in jobs_all:
				jobs_all.add(job)

		for title in synonyms:
			job = title.split(' of ')[0].split(' ')[-1].split('/')[0].strip() if ' of ' in title else title.split(' ')[-1].split('/')[0].strip()
			if len(job)<3:
				continue
			plural = p.plural(job)
			if plural and not plural in jobs[sector_name]:
				jobs[sector_name].add(plural)
			if plural and not plural in jobs_all:
				jobs_all.add(plural)
			if job and not job in jobs[sector_name]:
				jobs[sector_name].add(job)
			if job and not job in jobs_all:
				jobs_all.add(job)

	for sector in jobs:
		parsed_data.write(sector + '\t' + ','.join(jobs[sector]) + '\n')

	parsed_data_unified.write(','.join(jobs_all) + '\n')

	parsed_data.close()
	parsed_data_unified.close()


if __name__ == '__main__':
	main()