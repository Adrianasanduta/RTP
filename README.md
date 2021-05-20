# RTP

## Lab 1

1. You will have to read 2 SSE streams of actual Twitter API tweets in JSON format. For Elixir use this project to read SSE: https://github.com/cwc/eventsource_ex
2. The streams are available from a Docker container, alexburlacu/rtp-server:faf18x, just like Lab 1 PR, only now it's on port 4000
3. To make things interesting, the rate of messages varies by up to an order of magnitude, from 100s to 1000s.
4. Then, you route the messages to a group of workers that need to be autoscaled, you will need to scale up the workers (have more) when the rate is high, and less actors when the rate is low
5. Route/load balance messages among worker actors in a round robin fashion
6. Occasionally you will receive "kill messages", on which you have to crash the workers.
7. To continue running the system you will have to have a supervisor/restart policy for the workers.
8. The worker actors also must have a random sleep, in the range of 50ms to 500ms, normally distributed. This is necessary to make the system behave more like a real one + give the router/load balancer a bit of a hard time + for the optional speculative execution. The output will be shown as log messages.

![](output.gif)

## Lab 2

1. You will have to reuse the first Lab, with some additions.
2. You will be required to copy the Dynamic Supervisor + Workers that compute the sentiment score and adapt this copy of the system to compute the Engagement Ratio per Tweet. Notice that some tweets are actually retweets and contain a special field retweet_status​ . You will have to extract it and treat it as a separate tweet. The Engagement Ratio will be computed as: (#favorites + #retweets) / #followers​ .
3. Your workers now print sentiment scores, but for this lab, they will have to send it to a dedicated aggregator actor where the sentiment score, the engagement ratio, and the original tweet will be merged together. Hint: you will need special ids to recombine everything properly because synchronous communication is forbidden.
4. Finally, you will have to load everything into a database, for example Mongo, and given that writing messages one by one is not efficient, you will have to implement a backpressure mechanism called adaptive batching​​. Adaptive batching means that you write/send data in batches if the maximum batch size is reached, for example 128 elements, or the time is up, for example a window of 200ms is provided, whichever occurs first. This will be the responsibility of the sink actor(s).
5. To make things interesting, you will have to split the tweet JSON into users and tweets and keep them in separate collections/tables in the DB.
6. Of course, don't forget about using actors and supervisors for your system to keep it running.

## Lab 3

1. For the minimal passing grade, you have to develop a message broker with support for multiple topics. The message broker should be a dedicated async TCP/UDP server written in the language of the previous 2 labs. You must connect the second lab to it so that the lab will publish messages on the message broker which can be subscribed to using a tool like telnet or netcat. Given that you will have at least 2 separated applications, docker-compose is mandatory.
2. For a 6 you must do all of the above + have a more-or-less sound software design, where the messages in your code are represented as structures/classes and not as just maps or strings. Of course, this implies you will need to serialize these messages at some point, to send them via network.
3. Normally you are expected to implement all of the above tasks and ensure reliable message delivery using Persistent Messages with subscriber acknowledgments and Durable queues.

## Start

Just run: `docker-compose up --build` in the root directory
