:fromto_query
=============

```
X = utc_timestamp
- = duration span

time   |    5    10   15   20   25   30   35   40   45   50
       |''''''''''''''''''''''''''''''''''''''''''''''''''
Event1 |       X--------
Event2 |            X---------
Event3 |                X---------
Event4 |                           X---

:from  |         X....................................

:to    |.......................X

:from  |         X:::::::::::::.......................
:to    |..........:::::::::::::X


:fromto_query utc_timestamp
:from returns         Event2, Event3, Event4            utc_timestamp >= :from
:to returns           Event1, Event2, Event3            utc_timestamp <= :to
:from & :to returns   Event2, Event3                    utc_timestamp >= :from && utc_timestamp <= :to


:fromto_query intersect
:from returns         Event1, Event2, Event3, Event4    utc_timestamp + duration >= :from
:to returns           Event1, Event2, Event3            utc_timestamp <= :to
:from & :to returns   Event1, Event2, Event3            utc_timestamp + duration >= :from && utc_timestamp <= :to


:fromto_query contain 
:from returns         Event2, Event3, Event4            utc_timestamp >= :from
:to returns           Event1, Event2                    utc_timestamp + duration <= :to
:from & :to returns   Event2                            utc_timestamp >= :from && utc_timestamp + duration <= :to
```

