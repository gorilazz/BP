def jugWater(a,b,visited,nhop):
	a_max = len(visited)-1
	b_max = len(visited[0])-1
	if (a>a_max) or (b>b_max):
		return False
	if visited[a][b] == True:
		if nhop[a][b]:
			return True
		else:
			return False

	visited[a][b] = True
	print([a,b])

	if a==2:
		nhop[a][b] = [a,b]
		return True
	else:
		if jugWater(0,b,visited,nhop):
			nhop[a][b] = [0,b]
			return True
		if jugWater(max(a-b_max+b,0),min(a+b,b_max),visited,nhop):
			nhop[a][b] = [max(a-b_max+b,0),min(a+b,b_max)]
			return True
		if jugWater(a_max,b,visited,nhop):
			nhop[a][b] = [a_max,b]
			return True
		if jugWater(a,0,visited,nhop):
			nhop[a][b] = [a,0]
			return True
		if jugWater(a,b_max,visited,nhop):
			nhop[a][b] = [a,b_max]
			return True
		if jugWater(min(a+b,a_max),max(b-a_max+a,0),visited,nhop):
				nhop[a][b] = [min(a+b,a_max),max(b-a_max+a,0)]
				return True
		
		return False

visited = []
nhop = []

for i in range(0,9):
	visited.append([None]*6)
	nhop.append([None]*6)

a = jugWater(0,0,visited,nhop)
print(a)
print(nhop)