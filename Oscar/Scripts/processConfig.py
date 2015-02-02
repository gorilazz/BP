import csv
import re

def main():
	oscar_file = open('C:\\Users\\yuzhan\\Desktop\\testout_update.txt', 'rt', encoding='utf-8')
	parsed_2012 = open('C:\\Users\\yuzhan\\Git\\Predictions\\Oscar\\Data\\Oscar_2012.txt', 'wt', encoding='utf-8')
	parsed_2013 = open('C:\\Users\\yuzhan\\Git\\Predictions\\Oscar\\Data\\Oscar_2013.txt', 'wt', encoding='utf-8')
	parsed_2014 = open('C:\\Users\\yuzhan\\Git\\Predictions\\Oscar\\Data\\Oscar_2014.txt', 'wt', encoding='utf-8')
	oscar_list = csv.reader(oscar_file, delimiter='\t')

	for line in oscar_list:
		year = int(line[0])
		award = line[1].lower()
		candidate = re.split(r'[:,]',line[2].lower())
		character = re.split(r'[:,]',line[3].lower())
		note = re.split(r'[:,]',line[4].lower())
		candidates = candidate+character+note
		candidates = [item.strip() for item in candidates if item and len(re.findall(r' by ', item))==0 and len(re.findall(r'production design', item))==0 and len(re.findall(r'set decoration', item))==0]
		win = int(line[5])
		if year==2011:
			parsed_2012.write(' '.join(candidate)+'-'+award+'\t'+'1,2:'+','.join(candidates)+'\t'+'oscar'+'|'+award.split()[0]+'\t'+'\n')
		elif year==2012:
			parsed_2013.write(' '.join(candidate)+'-'+award+'\t'+'1,2:'+','.join(candidates)+'\t'+'oscar'+'|'+award.split()[0]+'\t'+'\n')
		elif year==2013:
			parsed_2014.write(' '.join(candidate)+'-'+award+'\t'+'1,2:'+','.join(candidates)+'\t'+'oscar'+'|'+award.split()[0]+'\t'+'\n')

	parsed_2012.close()
	parsed_2013.close()
	parsed_2014.close()

if __name__=='__main__':
	main()