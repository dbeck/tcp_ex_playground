// inet_addr
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/uio.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>

#include <iostream>
#include <functional>
#include <cstdint>
#include <chrono>

namespace
{
  struct on_destruct
  {
    std::function<void()> fun_;
    on_destruct(std::function<void()> fun) : fun_(fun) {}
    ~on_destruct() { fun_(); }
  };
  
  struct timer
  {
    typedef std::chrono::high_resolution_clock      highres_clock;
    typedef std::chrono::time_point<highres_clock>  timepoint;
    
    timepoint  start_;
    uint64_t   iteration_;
    
    timer(uint64_t iter) : start_{highres_clock::now()}, iteration_{iter} {}
      
    ~timer()
    {
      using namespace std::chrono;
      timepoint now{highres_clock::now()};
      
      uint64_t  usec_diff     = duration_cast<microseconds>(now-start_).count();
      double    call_per_ms   = iteration_*1000.0     / ((double)usec_diff);
      double    call_per_sec  = iteration_*1000000.0  / ((double)usec_diff);
      double    us_per_call   = (double)usec_diff     / (double)iteration_;
      
      std::cout << "elapsed usec=" << usec_diff
                << " avg(usec/call)=" << us_per_call
                << " avg(call/msec)=" << call_per_ms
                << " avg(call/sec)=" << call_per_sec
                << std::endl;
    }
  };
}


int main(int argc, char ** argv)
{
  try
  {
    // create a TCP socket
    int sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if( sockfd < 0 )
    {
      throw "can't create socket";
    }
    on_destruct close_sockfd( [sockfd](){ close(sockfd); } );
    
    // server address (127.0.0.1:8000)
    struct sockaddr_in server_addr;
    ::memset(&server_addr, 0, sizeof(server_addr));
    
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    server_addr.sin_port = htons(8000);  
    
    // connect to server
    if( connect(sockfd, (struct sockaddr *)&server_addr, sizeof(struct sockaddr)) == -1 )
    {
      throw "failed to connect to server at 127.0.0.1:8000";
    }
    
    // prepare data
    char      data[]  = "Hello";
    uint64_t  id      = 0;
    uint32_t  len     = htonl(5);
      
    struct iovec data_iov[3] = {
      { (char *)&id,   8 }, // id
      { (char *)&len,  4 }, // len
      { data,          5 }  // data
    };
    
    for( int i=0; i<100; ++i )
    {
      timer t(10000);
      // send data in a loop
      for( id = 0; id<10000; ++id )
      {
        if( writev(sockfd, data_iov, 3) != 17 ) throw "failed to send data";
        uint64_t response = 0;
        if( recv(sockfd, &response, 8, 0) != 8 ) throw "failed to receive data";
        if( response != id ) throw "invalid response received";
      }
    }
    
  }
  catch( const char * msg )
  {
    perror(msg);
  }
  return 0;
}
