test = CApiTest

$(test).so : $(test).cpp
	g++ -fPIC -shared $(test).cpp -o $(test).so -I/usr/include/python2.7 -lpython2.7
