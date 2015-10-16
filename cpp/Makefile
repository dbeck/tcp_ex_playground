
all: RequestReply ThrottleCpp HeadRest SyncAck

RequestReply: RequestReply.cc
	g++ -o RequestReply -O3 -std=c++11 -Wall RequestReply.cc

ThrottleCpp: ThrottleCpp.cc
	g++ -o ThrottleCpp -O3 -std=c++11 -Wall ThrottleCpp.cc

HeadRest: HeadRest.cc
	g++ -o HeadRest -O3 -std=c++11 -Wall HeadRest.cc

SyncAck: SyncAck.cc
	g++ -o SyncAck -O3 -std=c++11 -Wall SyncAck.cc

clean:
	rm -f RequestReply ThrottleCpp
