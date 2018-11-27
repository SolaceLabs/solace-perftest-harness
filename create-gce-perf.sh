
for index in 1 2 3 4 5 6 7 8; do
  name=perf${index}
  gcloud compute instances create ${name} \
  --boot-disk-size=15GB \
  --boot-disk-type=pd-ssd \
  --labels="creator=choltfurth,usage=perftesting,customer=hsbc" \
  --machine-type=n1-standard-8 \
  --zone=europe-west1-b \
  --no-address \
  --image-project=centos-cloud \
  --image-family=centos-7 
done
