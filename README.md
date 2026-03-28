# Solace Performance Test Harness

A test harness for characterising and validating the message throughput of Solace brokers — both software brokers and hardware appliances. Uses Ansible to deploy [sdkperf_c](https://docs.solace.com/API/SDKPerf/SDKPerf.htm) to remote Linux test hosts and drive publisher/consumer load against the broker under test.

---

## What you will need

- A Solace software broker or hardware appliance to test
- Publisher and consumer test hosts (Linux) — min 2, ideally 4 or more with 10 GbE connectivity
- A controller host (Linux) with Ansible installed and SSH access to the test hosts
- SSH keys from the controller installed on all test hosts
- A client username on the broker VPN with publish, subscribe, and guaranteed endpoint create permissions (credentials stored in `config/credentials.yaml`)
- `sdkperf_c` binary placed in `pubSubTools/` on the controller (copied to test hosts by Ansible)

> For minimal testing a single publisher host and a single consumer host is sufficient, but will limit the maximum achievable rates (especially for direct messaging at small message sizes).

Run `./setup.sh` for a guided walkthrough of the above requirements and to configure your test hosts and credentials.

---

## Repository structure

```
setup.sh                         # Interactive setup wizard — configures hosts and explains requirements
start-benchmarking-test.sh       # Interactive menu to select and run a benchmarking test
start-generic-discovery-test.sh  # Wrapper to run a generic discovery test (prompts for all parameters)
start-custom-discovery-test.sh   # Builds a custom discovery testset and saves it to custom-sets/

engine/                          # Core test engine
engine/run-testset.sh            # Runs a fixed-target testset (pass/fail against known rates)
engine/run-binsearch-testset.sh  # Discovers max throughput via exponential probe + binary search
engine/run-test.sh               # Single-test wrapper around the Ansible playbook
engine/start-sdk.yaml            # Ansible playbook: deploys sdkperf_c, runs publishers and consumers

benchmarking-tests/              # Fixed-target testsets for known broker tiers
discovery-tests/                 # Discovery testsets (binary search format)
custom-sets/                     # User-generated custom discovery testsets (gitignored)
scripts/                         # sdkpublisher.sh and sdkconsumers.sh — run on test hosts
pubSubTools/                     # sdkperf_c binary and licences (not included in repo)
config/host                      # Ansible inventory (publisher and consumer hosts)
config/credentials.yaml          # Broker credentials for sdkperf (gitignored — not committed)
config/credentials.yaml.example  # Credentials template
docs/                            # Architecture overview and additional documentation
results/                         # Test result output files
temp/                            # Temporary per-iteration logs (cleaned up after each run)
```

---

## Getting started

Run the setup wizard to configure your test hosts:

```bash
./setup.sh
```

This will explain the infrastructure requirements, guide you through SSH key setup, and write your publisher/subscriber host names to `config/host` and your broker credentials to `config/credentials.yaml`.

---

## Running a fixed-target testset (known broker)

The `benchmarking-tests/` folder contains pre-configured testsets for common broker tiers and configurations. Each script defines target rates the broker is expected to achieve and reports pass/fail for each scenario.

The easiest way to run one is via the interactive menu:

```bash
./start-benchmarking-test.sh
```

Or invoke a testset script directly:

```bash
benchmarking-tests/ent-10k-gm-ha.sh <broker-ip>
```

### Software broker tiers (Solace licensing)

| Script prefix | Licensing tier |
|---|---|
| `standard-*` | Standard |
| `ent-1k-*` | Enterprise 1k |
| `ent-10k-*` | Enterprise 10k |
| `ent-100k-*` | Enterprise 100k |

Each tier has variants for message type and HA configuration:
- `-direct` — direct messaging
- `-gm-noha` — guaranteed (persistent) messaging, standalone broker
- `-gm-ha` — guaranteed messaging, HA pair (primary + backup + monitoring node (in case of software))
- `-quick` — abbreviated run covering key scenarios only

### Hardware appliance

| Script | Description |
|---|---|
| `3560-ADB4-direct.sh` | Solace 3560 appliance — direct messaging |
| `3560-ADB4-gm-ha.sh` | Solace 3560 appliance — guaranteed messaging (HA pair) |

Target rates in the 3560 testsets are based on published Solace [specifications](https://solace.com/products/performance/) (11M/24M msg/s direct at 100B f=1/f=10; 640k/2.8M msg/s persistent at 1KB f=1/f=10) and measurements from londonlab.

---

## Discovering the maximum throughput of an unknown broker

Use the discovery tests when you don't know what rates to expect — for example, new hardware, a new configuration, or initial characterisation of a broker.

Rather than specifying target rates, the script automatically finds the highest message rate the broker can sustain end-to-end for each scenario using two phases:

1. **Exponential probe** — doubles the rate from a low starting point until the first failure, quickly narrowing the search window without wasting iterations in the wrong part of the range.
2. **Binary search** — converges on the maximum stable rate within the window found by the probe.

The search stops early once precision reaches ±1% of the current midpoint (with an absolute floor of ±500 msgs/sec for very low-rate scenarios).

Test entries omit the target rate field:
```
msg_size:fanout:publisher_hosts:msg_type
```

**Generic discovery** — standard scenario matrix (100B, 1KB, 20KB × fanout 1/5/50), prompts for broker, SSH user, host count, and message types:
```bash
./start-generic-discovery-test.sh
```

**Custom discovery** — interactive wizard to choose message types, sizes, fanout values and upper bounds, generates a reusable testset under `custom-sets/`:
```bash
./start-custom-discovery-test.sh
```

The generated script is saved to `custom-sets/<name>.sh` and can be re-run directly at any time:
```bash
./custom-sets/<name>.sh [broker-ip]
```

### Upper bounds

The exponential probe starts at `upper_bound / 1024` and doubles upward. The defaults are conservative (software broker limits). Testsets for more capable brokers should override these via `export` before calling `engine/run-binsearch-testset.sh`:

| Variable | Default | 3560 w/ ADB4 |
|---|---|---|
| `search_upper_bound_direct` | 5,000,000 | 25,000,000 |
| `search_upper_bound_nonpersistent` | 2,000,000 | 20,000,000 |
| `search_upper_bound_persistent` | 1,000,000 | 5,000,000 |

See `discovery-tests/londonlab-discovery.sh` for an example of how to override these.

---

## How the tests work

1. The testset script defines scenarios as arrays and passes them to `engine/run-testset.sh` or `engine/run-binsearch-testset.sh`.
2. For each scenario the runner calls `engine/run-test.sh`, which invokes the Ansible playbook `engine/start-sdk.yaml`.
3. Ansible copies `sdkperf_c` and the publisher/consumer scripts to the test hosts, then launches:
   - **Consumers** asynchronously (started first, so they are ready before publishers)
   - **Publishers** at the target rate for the configured `runlength` (default: 60 seconds)
4. After the run, Ansible collects stdout from both sides. The total consumer rate is summed across all hosts and checked against the target (allowing a 5% error margin).
5. Results are written to `results/` at the end of each testset.

### Fixed-target testset format
```
msg_size : fanout : overall_msg_rate : parallel_hosts : msg_type
```

`overall_msg_rate` is the **total consumer rate** expected (i.e. it already includes the fanout multiplier). The playbook divides it by `parallel_hosts × fanout` to derive the per-publisher-host rate.

### Binary search testset format
```
msg_size : fanout : parallel_hosts : msg_type
```

The target rate field is omitted — the script determines it automatically.

---

## Infrastructure sizing guidance

| Message size | Bottleneck | Notes |
|---|---|---|
| ≤ 1KB | Broker CPU / disk IOPS | Throughput largely independent of message size |
| 1KB–20KB | Disk write bandwidth (persistent) or broker CPU (direct) | Persistent rates fall as message size increases |
| ≥ 20KB | Network bandwidth (n * 10 GbE ≈ n * 1.25 GB/s per host / network interface) | Rate ≈ n * 1.25 GB/s ÷ msg_size per host, fanout has minimal effect on publisher rate |

For high-fanout scenarios (f ≥ 10), the consumer-side network becomes the binding constraint: each consumer host must handle `publish_rate × fanout` messages. With 1 consumer host on 10 GbE this limits useful fanout testing. Use multiple consumer hosts for accurate high-fanout results.

---

## Configuration

Key parameters in `engine/run-binsearch-testset.sh`:

| Parameter | Default | Description |
|---|---|---|
| `runlength` | 60 | Seconds per test run |
| `search_iterations` | 10 | Maximum binary search iterations |
| `allowed_error_margin` | 5 | Consumer rate must be ≥ (100 − margin)% of target to pass |
| `precision_pct` | 1 | Stop binary search when range ≤ ±1% of midpoint |
| `precision_threshold` | 500 | Absolute minimum precision floor (msgs/sec) |
| `inter_iteration_cooldown` | 5 | Seconds between iterations (allows broker queues to drain) |

Key parameters in `engine/start-sdk.yaml`:

| Parameter | Default | Description |
|---|---|---|
| `sshuser` | `perfharness` | SSH user on test hosts |
| `sdk_publishers` | 4 | sdkperf_c publisher processes per host (match to core count) |
| `runlength` | 120 | Default run length (overridden by calling script) |

---

## Additional documentation

- `docs/Perf Test Harness-Overview.pptx` — architecture and methodology overview

## Authors

Christian Holtfurth

## Resources

- [Solace Developer Portal](https://solace.dev)
- [sdkperf documentation](https://docs.solace.com/API/SDKPerf/SDKPerf.htm)
- [Solace community](https://solace.community)
