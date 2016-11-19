object = ImPreprocessing

$(object).so : $(object).cpp
	g++ -fPIC -shared $(object).cpp -o $(object).so -I/usr/include/python2.7 -lpython2.7
