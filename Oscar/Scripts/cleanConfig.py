import csv

def main():
	parsed_2012 = open('C:\\Users\\yuzhan\\Git\\Predictions\\Oscar\\Data\\Oscar_2012.txt', 'rt', encoding='utf-8')
	parsed_2013 = open('C:\\Users\\yuzhan\\Git\\Predictions\\Oscar\\Data\\Oscar_2013.txt', 'rt', encoding='utf-8')
	parsed_2014 = open('C:\\Users\\yuzhan\\Git\\Predictions\\Oscar\\Data\\Oscar_2014.txt', 'rt', encoding='utf-8')

	clean_2012 = open('C:\\Users\\yuzhan\\Git\\Predictions\\Oscar\\Data\\Oscar_2012_clean.txt', 'wt', encoding='utf-8')
	clean_2013 = open('C:\\Users\\yuzhan\\Git\\Predictions\\Oscar\\Data\\Oscar_2013_clean.txt', 'wt', encoding='utf-8')
	clean_2014 = open('C:\\Users\\yuzhan\\Git\\Predictions\\Oscar\\Data\\Oscar_2014_clean.txt', 'wt', encoding='utf-8')	

	for line in parsed_2012:
		toks = line.split('\t')
		toks.insert(1,'')
		# print(toks)
		clean_2012.write('\t'.join(toks))

	for line in parsed_2013:
		toks = line.split('\t')
		toks.insert(1,'')
		clean_2013.write('\t'.join(toks))

	for line in parsed_2014:
		toks = line.split('\t')
		toks.insert(1,'')
		clean_2014.write('\t'.join(toks))

	clean_2012.close()
	clean_2013.close()
	clean_2014.close()

if __name__ == '__main__':
	main()