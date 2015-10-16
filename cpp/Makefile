
all: RequestReply ThrottleCpp HeadRest

RequestReply: RequestReply.cc
	g++ -o RequestReply -O3 -std=c++11 -Wall RequestReply.cc

ThrottleCpp: ThrottleCpp.cc
	g++ -o ThrottleCpp -O3 -std=c++11 -Wall ThrottleCpp.cc

HeadRest: HeadRest.cc
	g++ -o HeadRest -O3 -std=c++11 -Wall HeadRest.cc

clean:
	rm -f RequestReply ThrottleCpp
