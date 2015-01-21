import timeit

def seqSearch(a,num):
	if len(a)==0:
		return False

	for i in range(0,len(a)):
		if num==a[i]:
			return True

	return False

def bSearch(a, num):
	if len(a)<=0:
		return False

	midpoint = len(a)//2
	if a[midpoint] == num:
		return True
	if a[midpoint] > num:
		return bSearch(a[:midpoint],num)
	else:
		return bSearch(a[midpoint+1:],num)


testlist = [0,1,2,8,13,17,19,32,42]

start = timeit.default_timer()
print(seqSearch(testlist,42))
stop = timeit.default_timer()
print(stop-start)

start = timeit.default_timer()
print(bSearch(testlist,42))
stop = timeit.default_timer()
print(stop-start)
