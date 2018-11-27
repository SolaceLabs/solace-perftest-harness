TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate                 1000 #", [0m
[0;32m        "# Message rate per publisher host       250 #", [0m
[0;32m        "# Fanout                                  1 #", [0m
[0;32m        "# Message size                       102400 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                4 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:       615 (msgs/sec)
Sum across all  consumers:       567 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 950
Achieved rate 567 < 950
Test: Fail
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate                 2100 #", [0m
[0;32m        "# Message rate per publisher host       262 #", [0m
[0;32m        "# Fanout                                  2 #", [0m
[0;32m        "# Message size                       102400 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                4 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:      2047 (msgs/sec)
Sum across all  consumers:      2049 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 1995
Achieved rate 2049 >= 1995
Test: OK
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate                 5000 #", [0m
[0;32m        "# Message rate per publisher host       250 #", [0m
[0;32m        "# Fanout                                  5 #", [0m
[0;32m        "# Message size                       102400 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                4 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:       469 (msgs/sec)
Sum across all  consumers:      3892 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 4750
Achieved rate 3892 < 4750
Test: Fail
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate                 6000 #", [0m
[0;32m        "# Message rate per publisher host       150 #", [0m
[0;32m        "# Fanout                                 10 #", [0m
[0;32m        "# Message size                       102400 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                4 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:      1151 (msgs/sec)
Sum across all  consumers:      5766 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 5700
Achieved rate 5766 >= 5700
Test: OK
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate                10000 #", [0m
[0;32m        "# Message rate per publisher host       100 #", [0m
[0;32m        "# Fanout                                 50 #", [0m
[0;32m        "# Message size                       102400 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                2 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:       383 (msgs/sec)
Sum across all  consumers:      9608 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 9500
Achieved rate 9608 >= 9500
Test: OK
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate                 2000 #", [0m
[0;32m        "# Message rate per publisher host       500 #", [0m
[0;32m        "# Fanout                                  1 #", [0m
[0;32m        "# Message size                        51200 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                4 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:       626 (msgs/sec)
Sum across all  consumers:      1115 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 1900
Achieved rate 1115 < 1900
Test: Fail
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate                 4000 #", [0m
[0;32m        "# Message rate per publisher host       500 #", [0m
[0;32m        "# Fanout                                  2 #", [0m
[0;32m        "# Message size                        51200 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                4 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:       752 (msgs/sec)
Sum across all  consumers:      2086 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 3800
Achieved rate 2086 < 3800
Test: Fail
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate                 9500 #", [0m
[0;32m        "# Message rate per publisher host       475 #", [0m
[0;32m        "# Fanout                                  5 #", [0m
[0;32m        "# Message size                        51200 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                4 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:       756 (msgs/sec)
Sum across all  consumers:      5537 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 9025
Achieved rate 5537 < 9025
Test: Fail
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate                12700 #", [0m
[0;32m        "# Message rate per publisher host       317 #", [0m
[0;32m        "# Fanout                                 10 #", [0m
[0;32m        "# Message size                        51200 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                4 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:      2495 (msgs/sec)
Sum across all  consumers:     12486 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 12065
Achieved rate 12486 >= 12065
Test: OK
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate                17000 #", [0m
[0;32m        "# Message rate per publisher host       170 #", [0m
[0;32m        "# Fanout                                 50 #", [0m
[0;32m        "# Message size                        51200 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                2 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:       671 (msgs/sec)
Sum across all  consumers:     16813 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 16150
Achieved rate 16813 >= 16150
Test: OK
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate                 5000 #", [0m
[0;32m        "# Message rate per publisher host      1250 #", [0m
[0;32m        "# Fanout                                  1 #", [0m
[0;32m        "# Message size                        20480 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                4 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:      4587 (msgs/sec)
Sum across all  consumers:      2201 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 4750
Achieved rate 2201 < 4750
Test: Fail
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate                13000 #", [0m
[0;32m        "# Message rate per publisher host      1625 #", [0m
[0;32m        "# Fanout                                  2 #", [0m
[0;32m        "# Message size                        20480 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                4 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:      2600 (msgs/sec)
Sum across all  consumers:      4491 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 12350
Achieved rate 4491 < 12350
Test: Fail
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate                25000 #", [0m
[0;32m        "# Message rate per publisher host      1250 #", [0m
[0;32m        "# Fanout                                  5 #", [0m
[0;32m        "# Message size                        20480 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                4 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:      1902 (msgs/sec)
Sum across all  consumers:     10385 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 23750
Achieved rate 10385 < 23750
Test: Fail
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate                30000 #", [0m
[0;32m        "# Message rate per publisher host       750 #", [0m
[0;32m        "# Fanout                                 10 #", [0m
[0;32m        "# Message size                        20480 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                4 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:      2731 (msgs/sec)
Sum across all  consumers:     18253 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 28500
Achieved rate 18253 < 28500
Test: Fail
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate                40000 #", [0m
[0;32m        "# Message rate per publisher host       400 #", [0m
[0;32m        "# Fanout                                 50 #", [0m
[0;32m        "# Message size                        20480 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                2 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:      1599 (msgs/sec)
Sum across all  consumers:     40016 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 38000
Achieved rate 40016 >= 38000
Test: OK
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate                26000 #", [0m
[0;32m        "# Message rate per publisher host      6500 #", [0m
[0;32m        "# Fanout                                  1 #", [0m
[0;32m        "# Message size                         4096 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                4 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:     15267 (msgs/sec)
Sum across all  consumers:      7546 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 24700
Achieved rate 7546 < 24700
Test: Fail
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate                50000 #", [0m
[0;32m        "# Message rate per publisher host      6250 #", [0m
[0;32m        "# Fanout                                  2 #", [0m
[0;32m        "# Message size                         4096 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                4 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:     12567 (msgs/sec)
Sum across all  consumers:     12434 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 47500
Achieved rate 12434 < 47500
Test: Fail
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate               118000 #", [0m
[0;32m        "# Message rate per publisher host      5900 #", [0m
[0;32m        "# Fanout                                  5 #", [0m
[0;32m        "# Message size                         4096 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                4 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:     11875 (msgs/sec)
Sum across all  consumers:     29135 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 112100
Achieved rate 29135 < 112100
Test: Fail
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate               123000 #", [0m
[0;32m        "# Message rate per publisher host      3075 #", [0m
[0;32m        "# Fanout                                 10 #", [0m
[0;32m        "# Message size                         4096 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                4 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:      9314 (msgs/sec)
Sum across all  consumers:     45434 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 116850
Achieved rate 45434 < 116850
Test: Fail
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate               290000 #", [0m
[0;32m        "# Message rate per publisher host      2900 #", [0m
[0;32m        "# Fanout                                 50 #", [0m
[0;32m        "# Message size                         4096 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                2 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:      4069 (msgs/sec)
Sum across all  consumers:     99096 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 275500
Achieved rate 99096 < 275500
Test: Fail
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate                38000 #", [0m
[0;32m        "# Message rate per publisher host      9500 #", [0m
[0;32m        "# Fanout                                  1 #", [0m
[0;32m        "# Message size                         2048 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                4 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:     19526 (msgs/sec)
Sum across all  consumers:      9646 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 36100
Achieved rate 9646 < 36100
Test: Fail
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate                80000 #", [0m
[0;32m        "# Message rate per publisher host     10000 #", [0m
[0;32m        "# Fanout                                  2 #", [0m
[0;32m        "# Message size                         2048 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                4 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:     19538 (msgs/sec)
Sum across all  consumers:     19514 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 76000
Achieved rate 19514 < 76000
Test: Fail
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate               150000 #", [0m
[0;32m        "# Message rate per publisher host      7500 #", [0m
[0;32m        "# Fanout                                  5 #", [0m
[0;32m        "# Message size                         2048 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                4 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:     11346 (msgs/sec)
Sum across all  consumers:     28060 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 142500
Achieved rate 28060 < 142500
Test: Fail
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate               270000 #", [0m
[0;32m        "# Message rate per publisher host      6750 #", [0m
[0;32m        "# Fanout                                 10 #", [0m
[0;32m        "# Message size                         2048 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                4 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:     11795 (msgs/sec)
Sum across all  consumers:     58177 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 256500
Achieved rate 58177 < 256500
Test: Fail
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate               520000 #", [0m
[0;32m        "# Message rate per publisher host      5200 #", [0m
[0;32m        "# Fanout                                 50 #", [0m
[0;32m        "# Message size                         2048 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                2 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:      5695 (msgs/sec)
Sum across all  consumers:    139602 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 494000
Achieved rate 139602 < 494000
Test: Fail
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate                51000 #", [0m
[0;32m        "# Message rate per publisher host     12750 #", [0m
[0;32m        "# Fanout                                  1 #", [0m
[0;32m        "# Message size                         1024 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                4 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:     21766 (msgs/sec)
Sum across all  consumers:     10783 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 48450
Achieved rate 10783 < 48450
Test: Fail
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate               103000 #", [0m
[0;32m        "# Message rate per publisher host     12875 #", [0m
[0;32m        "# Fanout                                  2 #", [0m
[0;32m        "# Message size                         1024 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                4 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:     21465 (msgs/sec)
Sum across all  consumers:     21317 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 97850
Achieved rate 21317 < 97850
Test: Fail
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate               200000 #", [0m
[0;32m        "# Message rate per publisher host     10000 #", [0m
[0;32m        "# Fanout                                  5 #", [0m
[0;32m        "# Message size                         1024 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                4 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:     16930 (msgs/sec)
Sum across all  consumers:     42080 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 190000
Achieved rate 42080 < 190000
Test: Fail
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate               300000 #", [0m
[0;32m        "# Message rate per publisher host      7500 #", [0m
[0;32m        "# Fanout                                 10 #", [0m
[0;32m        "# Message size                         1024 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                4 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:     10880 (msgs/sec)
Sum across all  consumers:     53667 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 285000
Achieved rate 53667 < 285000
Test: Fail
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate               540000 #", [0m
[0;32m        "# Message rate per publisher host      5400 #", [0m
[0;32m        "# Fanout                                 50 #", [0m
[0;32m        "# Message size                         1024 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                2 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:      5930 (msgs/sec)
Sum across all  consumers:    144777 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 513000
Achieved rate 144777 < 513000
Test: Fail
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate                57500 #", [0m
[0;32m        "# Message rate per publisher host     14375 #", [0m
[0;32m        "# Fanout                                  1 #", [0m
[0;32m        "# Message size                          512 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                4 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:     25258 (msgs/sec)
Sum across all  consumers:     12580 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 54625
Achieved rate 12580 < 54625
Test: Fail
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate               122000 #", [0m
[0;32m        "# Message rate per publisher host     15250 #", [0m
[0;32m        "# Fanout                                  2 #", [0m
[0;32m        "# Message size                          512 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                4 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:     20198 (msgs/sec)
Sum across all  consumers:     20025 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 115900
Achieved rate 20025 < 115900
Test: Fail
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate               220000 #", [0m
[0;32m        "# Message rate per publisher host     11000 #", [0m
[0;32m        "# Fanout                                  5 #", [0m
[0;32m        "# Message size                          512 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                4 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:     17811 (msgs/sec)
Sum across all  consumers:     44117 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 209000
Achieved rate 44117 < 209000
Test: Fail
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate               325000 #", [0m
[0;32m        "# Message rate per publisher host      8125 #", [0m
[0;32m        "# Fanout                                 10 #", [0m
[0;32m        "# Message size                          512 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                4 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:     12780 (msgs/sec)
Sum across all  consumers:     63049 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 308750
Achieved rate 63049 < 308750
Test: Fail
--
TASK [echo_end] *****************************************************************************************************
[0;32mok: [perf2] => {[0m
[0;32m    "msg": [[0m
[0;32m        "#############################################", [0m
[0;32m        "# Overall message rate               550000 #", [0m
[0;32m        "# Message rate per publisher host      5500 #", [0m
[0;32m        "# Fanout                                 50 #", [0m
[0;32m        "# Message size                          512 #", [0m
[0;32m        "# Message type                   persistent #", [0m
[0;32m        "# Number of publisher hosts in inventory  4 #", [0m
[0;32m        "# Parallel hosts (pub/sub)                2 #", [0m
[0;32m        "# Parallel processes per host             8 #", [0m
[0;32m        "#############################################"[0m
[0;32m    ][0m
[0;32m}[0m
--
RESULT ****************************************
Sum across all publishers:      5511 (msgs/sec)
Sum across all  consumers:    134730 (msgs/sec)

allowed error margin = 5 %
target rate - error margin = 522500
Achieved rate 134730 < 522500
Test: Fail
