import csv
import string

category_dict = {"business":["business", "marketing", "sales", 'brand', 'administrative', 'human resource', 'hr manager','data entry','assistant','operations','recruiter','associate'], \
"finance":["finance","financial","account",'insurance','real estate', 'accounting', 'audit', 'branch','tax', 'mortgage', 'loan', 'front office', 'front desk','advisor','fund'], \
"health":["nurse","medical","therapy","therapist","health", 'care', 'nursing', 'hospital', 'clinic', 'clinical', 'physicial', 'pharmacy', 'medicine', 'pathology', 'pathologist', 'dental', 'dietary','radiology','psychology',\
'psychologist','massage','biology','biologist','practitioner'], \
"engineering":["developer","software", 'system', 'test', 'database', 'big data', 'technical', 'ux designer', 'web designer', 'user experience', 'sql server', 'architect', 'quality', 'programming', 'programmer', 'product', \
'maintenance', 'information', 'graphic', 'front end','data analyst'], \
"customer service":["support","call center", 'customer', 'service', 'relationship', 'relation','delivery']
"misc":["manager","director","assistant",'specialist','management','managing','analyst','project','engineering','engineer','driver','agent','estimator','electrician','coordinator']
"construction":["civil","construction",'painter','carpenter','plumber','observer','estimator']}

with open('C:\\Users\\yuzhan\\Git\\Predictions\\NFP\\Pulse\\201410\\All_True_CommonTopJobs_1k_2014.csv', 'rt', encoding='UTF-8') as Jobs, \
open('C:\\Users\\yuzhan\\Git\\Predictions\\NFP\\Pulse\\201410\\All_True_CommonTopCategories_1k_2014.txt', 'wt', encoding='UTF-8') as Categories:

	jobs = Jobs.read().splitlines()

	categories = {"business":[], "finance":[], "engineering":[], "health":[], "social service":[], "misc":[], "customer service":[]}

	for job in jobs:
		flag = 0
		for category in category_dict.keys():
			if flag==0:
				ngrams = [ngram for ngram in category_dict[category] if ngram in job]
				if ngrams:
					categories[category].append(job)
					flag=1

		if flag==0:
			categories["misc"].append(job)

	for category in categories.keys():
		print('%s\n' % (category+'\t'+','.join(categories[category])))
		Categories.write('%s\n' % (category+'\t'+','.join(categories[category])))

	Categories.close()