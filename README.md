TcpExPlayground
===============

This project holds experiences in the Elixir TCP world. They all have a few corresponding blog entries and also a git branch. The git branches are then merged into master too:

 - [01_request_reply branch](https://github.com/dbeck/tcp_ex_playground/tree/01_request_reply) is documented [here](http://dbeck.github.io/simple-TCP-message-performance-in-Elixir/). This is a very basic TCP Request/Reply client and server example. The C++ client is [here](https://github.com/dbeck/tcp_ex_playground/blob/master/cpp/RequestReply.cc). The Elixir server is [here](https://github.com/dbeck/tcp_ex_playground/blob/master/lib/request_reply_handler.ex). The result is **22k msgs/sec** on my laptop.

 - [02_throttled_acks branch](https://github.com/dbeck/tcp_ex_playground/tree/02_throttled_acks) is documented [here](http://dbeck.github.io/Four-Times-Speedup-By-Throttling/). This is an attempt to improve performance by changing the messaging pattern that allows combining and delaying ACK messages. The C++ client is [here](https://github.com/dbeck/tcp_ex_playground/blob/master/cpp/ThrottleCpp.cc). The Elixir server is [here](https://github.com/dbeck/tcp_ex_playground/blob/master/lib/throttle_ack_handler.ex). The result is **90k msgs/sec** on my laptop.

 - [03_head_rest_pattern branch](https://github.com/dbeck/tcp_ex_playground/tree/03_head_rest_pattern) is documented [here](http://dbeck.github.io/Over-Two-Times-Speedup-By-Better-Elixir-Code/). By better using the Elixir pattern matching on binariy messages I had 2x performance gain. The C++ client is [here](https://github.com/dbeck/tcp_ex_playground/blob/master/cpp/HeadRest.cc). The Elixir server is [here](https://github.com/dbeck/tcp_ex_playground/blob/master/lib/head_rest_handler.ex). The result is **250k msgs/sec** on my laptop.

 - [04_synch_ack branch](https://github.com/dbeck/tcp_ex_playground/tree/04_synch_ack) is documented [here](http://dbeck.github.io/Passing-Millions-Of-Small-TCP-Messages-in-Elixir/). By removing a bottleneck from the code I achieved significant performance gain. The C++ client is [here](https://github.com/dbeck/tcp_ex_playground/blob/master/cpp/SyncAck.cc). The Elixir server is [here](https://github.com/dbeck/tcp_ex_playground/blob/master/lib/sync_ack_handler.ex). The result is over **2M msgs/sec** on my laptop.
 
 - [05_asynch_ack branch](https://github.com/dbeck/tcp_ex_playground/tree/05_asynch_ack) is documented [here](http://dbeck.github.io/Wrapping-up-my-Elixir-TCP-experiments/). In this latest experiment I retried moving the ACK sending to and independent process. With that I achieved **3M request per sec** on my MacBook Air laptop. When I tried it on an old Linux machine and an EC2 Amazon instance, this last code was slower than the previous **04_synch_ack** experiment. Looks like at this performance range one needs to consider the actual hardware too where the code is going to run. Memory and CPU speed both impacts heavily the speed of passing data between Elixir processes. The client code is available  [here](https://github.com/dbeck/tcp_ex_playground/blob/master/cpp/AsyncAck.cc). The Elixir server is [here](https://github.com/dbeck/tcp_ex_playground/blob/master/lib/async_ack_handler.ex).

License
=======

Copyright (c) 2015 [David Beck](http://dbeck.github.io)

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.