#!/bin/bash
#Simple script to stop all the VMR performance test hosts
gcloud compute instances stop perf1 perf2 perf3 perf4 perf5 perf6 perf7 perf8 --zone europe-west1-b
