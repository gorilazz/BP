def reverseList(l):
	if len(l)<=1:
		return l
	else:
		return l[len(l)-1:]+reverseList(l[0:len(l)-1])


l = [1,2,3,4,5]
print(reverseList(l))