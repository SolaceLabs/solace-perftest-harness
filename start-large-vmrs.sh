#!/bin/bash
#Simple script to start the "large" GCE VMRs
gcloud compute instances start gdis-solace-vmr-eur1-large-ha-p gdis-solace-vmr-eur1-large-ha-c --zone europe-west1-b
gcloud compute instances start gdis-solace-vmr-eur1-large-ha-b --zone europe-west1-b
