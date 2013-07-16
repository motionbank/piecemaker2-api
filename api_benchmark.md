# ab benchmark

## Summary

 * Ruby
   * always between 40-50MB memory footprint
   * about 90-100% cpu 
   * 2 threads
   * 450 - 510 requests/seconds (even under heavy load)
 * Node
   * breaks under heavy load
   * probably memory leaks
   * about 90-100% cpu 
   * 3 threads
   * memory footprint, if no errors: 40-50MB, with errors > 1.4GB

## ab -c 3 -n 5000

### ruby 90-100%, 2 threads, 40-44MB
```
Server Software:        Goliath
Server Hostname:        127.0.0.1
Server Port:            9080

Document Path:          /v1/users
Document Length:        36 bytes

Concurrency Level:      3
Time taken for tests:   9.763 seconds
Complete requests:      5000
Failed requests:        0
Write errors:           0
Total transferred:      805000 bytes
HTML transferred:       180000 bytes
Requests per second:    512.15 [#/sec] (mean)
Time per request:       5.858 [ms] (mean)
Time per request:       1.953 [ms] (mean, across all concurrent requests)
Transfer rate:          80.52 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.1      0       3
Processing:     2    6   5.4      5     129
Waiting:        2    5   5.2      4     129
Total:          3    6   5.4      5     129

Percentage of the requests served within a certain time (ms)
  50%      5
  66%      5
  75%      5
  80%      5
  90%     14
  95%     19
  98%     20
  99%     21
 100%    129 (longest request)
```

### node 90-100%, 3 threads, 40-50MB
```
Server Software:        
Server Hostname:        127.0.0.1
Server Port:            9050

Document Path:          /users
Document Length:        36 bytes

Concurrency Level:      3
Time taken for tests:   4.827 seconds
Complete requests:      5000
Failed requests:        0
Write errors:           0
Total transferred:      930000 bytes
HTML transferred:       180000 bytes
Requests per second:    1035.82 [#/sec] (mean)
Time per request:       2.896 [ms] (mean)
Time per request:       0.965 [ms] (mean, across all concurrent requests)
Transfer rate:          188.15 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.0      0       2
Processing:     1    3   1.2      3      30
Waiting:        1    3   1.2      2      29
Total:          2    3   1.2      3      30

Percentage of the requests served within a certain time (ms)
  50%      3
  66%      3
  75%      3
  80%      3
  90%      4
  95%      4
  98%      6
  99%      7
 100%     30 (longest request)
 ```

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


# wrk
https://github.com/wg/wrk

### API 2 (node-orm)
```
$ wrk -t5 -c10000 -d30s http://127.0.0.1:9050/users
Running 30s test @ http://127.0.0.1:9050/users
  5 threads and 10000 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   196.02ms   37.40ms 255.61ms   45.56%
    Req/Sec   360.35    295.91   732.00     46.18%
  44146 requests in 30.07s, 8.04MB read
  Socket errors: connect 9752, read 15776, write 0, timeout 140647
Requests/sec:   1468.31
Transfer/sec:    273.87KB
```

### API 2 (ruby)

```
$ wrk -t5 -c10000 -d30s http://127.0.0.1:9080/v1/users
Running 30s test @ http://127.0.0.1:9080/v1/users
  5 threads and 10000 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     1.09s   212.23ms   1.32s    87.94%
    Req/Sec    56.67     71.95   221.00     78.80%
  14082 requests in 30.07s, 2.16MB read
  Socket errors: connect 9752, read 14518, write 0, timeout 138527
Requests/sec:    468.36
Transfer/sec:     73.64KB
```