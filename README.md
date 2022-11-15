# Run performance tests against Solace routers

The Solace PubSub+ Event Broker provides enterprise-grade messaging capabilities deployable in any computing environment. The broker provides the same rich feature set as Solace’s proven hardware appliances, with the same open protocol support, APIs and common management. The VMR can be deployed in the datacenter or natively within all popular private and public clouds. 

# What you will need to run a performance test against a Solace router
- A (pair) of Solace appliances or Solace software brokers you want to test
- A couple of performance test hosts (Linux - ideally 4 publisher hosts and 4 consumer hosts)
- Decent network connectivity (10 GbE) between your hosts and the Solace routers
- A controller host (Linux) with network connectivity to the perf hosts to run the Ansible playbook on
- ssh keys of your controller host installed on your perf hosts
- A client user on your Solace router/VPN matching the credentials (sdk_credentials) in start-sdk.yaml with permissions to publish, subscribe and create temp. topic endpoints on your VPN
- The publisher hosts should have 8 cores and the consumer hosts need 4 cores (adjust values in sdkconsumers.sh and sdkpublishers.sh, if you need to change any of these)

# To run a custom test set
- Create a new script in the specific-test-set folder and adjust the numbers accordingly to the numbers you believe your router should be able to achieve.
- Run the script passing in a (set of) router IPs that are reachable from your perf hosts - unless you have already configured these IPs in your script of course.

# To run a templated test set
- The specific-test-sets folder contains templates for testing various sized brokers with reasonable defaults.
- E.g. to test a standard broker in a singleton/stand-alone setup, simply run `specific-test-sets/standard-gm-noha.sh` from the root directory of the project.
- Or To test an enterprise broker running with 4 cores in a HA setup, simply run `specific-test-sets/ent-4core-gm-ha.sh` from the root directory of the project.

# How the tests work
- The specific test set scripts are simply defining the tests that you want to run against the router, these are:
```
# Tests are being passed in as arrays. 
# An array can have several tests separated by space.
# Each test need to be in the format:
# msg_size:fanout_number:overall_msg_rate:number_of_publisher_hosts:msg_type
# Several (up to 7) arrays/testsets can be passed in, if separated by ;
# Example format for one test set:<br/>
# testarray1=""<br/>
# "100:1:1300000:4:direct "<br/>
# "100:2:1550000:4:direct "<br/>
# "100:5:3000000:4:direct "<br/>
# "100:10:3300000:4:direct "<br/>
# "100:50:4000000:2:direct "<br/>
# "100:100:4000000:2:direct "<br/>
# ";" #need to  end with to separate the various test arrays;<br/>
```
- The specific test set script calls the run-testset.sh script, which parses the arrays and runs each test by passing it to run-tests.sh
- run-tests.sh is a wrapper around the Ansible playbook start-sdk.yaml, which pushed the necessary tools and scripts to your perf hosts and runs the publisher and consumer scripts asynchronously for a given time (e.g. each test for 180 seconds).
- The results are being collected from each host and summed up after checking whether any errors have occured.
- The achieved rate is then checked against the provided rate for each test to decide whether a test is considered a success or a failure (allowing for an error margin of 5%).
- The results for each test are being written to a file in the result folder at the end of the test run.

# Additional documentation
- Check `Perf Test Harness-Overview.pptx` for more details.

## Authors
Christian Holtfurth

## Resources

For more information about Solace technology in general please visit these resources:

- The Solace Developer Portal website at: http://dev.solace.com
- Understanding [Solace technology.](http://dev.solace.com/tech/)
- Ask the [Solace community](http://dev.solace.com/community/).