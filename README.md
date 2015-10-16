TcpExPlayground
===============

This project holds experiences in the Elixir TCP world. They all have a few corresponding blog entries and also a git branch. The git branches are then merged into master too:

 - [01_request_reply branch](https://github.com/dbeck/tcp_ex_playground/tree/01_request_reply) is documented [here](http://dbeck.github.io/simple-TCP-message-performance-in-Elixir/). This is a very basic TCP Request/Reply client and server example. The C++ client is [here](https://github.com/dbeck/tcp_ex_playground/blob/master/cpp/RequestReply.cc). The Elixir server is [here](https://github.com/dbeck/tcp_ex_playground/blob/master/lib/request_reply_handler.ex). The result is **22k msgs/sec** on my laptop.

 - [02_throttled_acks branch](https://github.com/dbeck/tcp_ex_playground/tree/02_throttled_acks) is documented [here](http://dbeck.github.io/Four-Times-Speedup-By-Throttling/). This is an attempt to improve performance by changing the messaging pattern that allows combining and delaying ACK messages. The C++ client is [here](https://github.com/dbeck/tcp_ex_playground/blob/master/cpp/ThrottleCpp.cc). The Elixir server is [here](https://github.com/dbeck/tcp_ex_playground/blob/master/lib/throttle_ack_handler.ex). The result is **90k msgs/sec** on my laptop.

 - [03_head_rest_pattern branch](https://github.com/dbeck/tcp_ex_playground/tree/03_head_rest_pattern) is documented [here](http://dbeck.github.io/Over-Two-Times-Speedup-By-Better-Elixir-Code/). By better using the Elixir pattern matching on binariy messages I had 2x performance gain. The C++ client is [here](https://github.com/dbeck/tcp_ex_playground/blob/master/cpp/HeadRest.cc). The Elixir server is [here](https://github.com/dbeck/tcp_ex_playground/blob/master/lib/head_rest_handler.ex). The result is **250k msgs/sec** on my laptop.

 - [04_synch_ack branch](https://github.com/dbeck/tcp_ex_playground/tree/04_synch_ack) is documented [here](http://dbeck.github.io/Passing-Millions-Of-Small-TCP-Messages-in-Elixir/). By removing a bottleneck from the code I achieved significant performance gain. The C++ client is [here](https://github.com/dbeck/tcp_ex_playground/blob/master/cpp/SyncAck.cc). The Elixir server is [here](https://github.com/dbeck/tcp_ex_playground/blob/master/lib/sync_ack_handler.ex). The result is over **2M msgs/sec** on my laptop.
 

 


