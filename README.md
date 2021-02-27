# RTP

## Laboratory 1: Streaming Twitter sentiment analysis system

### Setting Up: 

1. Make a pull request to a remote Docker container: docker pull alexburlacu/rtp-server:faf18x;
2. Then, run this container: docker run -p 4000:4000 --rm alexburlacu/rtp-server:faf18x;
3. If needed, configure the project dependencies: mix deps.get.
4. Compile and run the project: mix run --no-halt.

### Requirements: 

* Read 2 SSE streams of actual Twitter API tweets in JSON format using the following project: https://github.com/cwc/eventsource_ex;
* Create the following entitties: Worker, Router, Connection, Supervisor;
* Route the messages to a group of workers;
* Make a sentiment analysis for each of the tweets;
* Check for panic messages. 

![](output.gif)
