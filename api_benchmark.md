# ab benchmark

## ab -c 5 -n 15000

### ruby 90-100%, 2 threads, 40-44MB

```
Server Software:        Goliath
Server Hostname:        127.0.0.1
Server Port:            9080

Document Path:          /v1/users
Document Length:        36 bytes

Concurrency Level:      5
Time taken for tests:   30.316 seconds
Complete requests:      15000
Failed requests:        0
Write errors:           0
Total transferred:      2415000 bytes
HTML transferred:       540000 bytes
Requests per second:    494.79 [#/sec] (mean)
Time per request:       10.105 [ms] (mean)
Time per request:       2.021 [ms] (mean, across all concurrent requests)
Transfer rate:          77.79 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.2      0      19
Processing:     3   10   6.7      9     200
Waiting:        3    8   6.2      7     199
Total:          3   10   6.7      9     200

Percentage of the requests served within a certain time (ms)
  50%      9
  66%      9
  75%     10
  80%     10
  90%     19
  95%     23
  98%     24
  99%     27
 100%    200 (longest request)
```

### node > 95%; 1 thread, 1,44 GB
```
Benchmarking 127.0.0.1 (be patient)
Send request failed!
Send request failed!
apr_socket_recv: Connection reset by peer (54)
Total of 5 requests completed
```

## ab -c 5 -n 20000

### ruby 90-100%, 2 threads, 40-44MB

```
Server Software:        Goliath
Server Hostname:        127.0.0.1
Server Port:            9080

Document Path:          /v1/users
Document Length:        36 bytes

Concurrency Level:      5
Time taken for tests:   42.270 seconds
Complete requests:      20000
Failed requests:        0
Write errors:           0
Total transferred:      3220000 bytes
HTML transferred:       720000 bytes
Requests per second:    473.15 [#/sec] (mean)
Time per request:       10.567 [ms] (mean)
Time per request:       2.113 [ms] (mean, across all concurrent requests)
Transfer rate:          74.39 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.3      0      26
Processing:     3   10   7.0      9     141
Waiting:        3    8   6.3      7     140
Total:          3   11   7.1      9     141

Percentage of the requests served within a certain time (ms)
  50%      9
  66%      9
  75%     10
  80%     15
  90%     20
  95%     24
  98%     34
  99%     35
 100%    141 (longest request)
```
 

### node 90-100%, 3 threads, 55-60MB

```
Benchmarking 127.0.0.1 (be patient)
Completed 2000 requests
Completed 4000 requests
Completed 6000 requests
Completed 8000 requests
Completed 10000 requests
Completed 12000 requests
Completed 14000 requests
Completed 16000 requests
apr_socket_recv: Operation timed out (60)
Total of 16362 requests completed
```
