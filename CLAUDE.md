# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Environment

All test runs must be executed from a Linux filesystem clone, not the Windows working directory (`/mnt/c/...`), because `BASH_SOURCE%/*` path resolution breaks under Windows paths. Use a `/tmp` clone:

```bash
git clone /mnt/c/Users/Christian/git/solace-perftest-harness /tmp/solace-perftest-harness
cp /mnt/c/Users/Christian/git/solace-perftest-harness/config/credentials.yaml /tmp/solace-perftest-harness/config/
cd /tmp/solace-perftest-harness
```

Always invoke scripts with `./` from within the repo directory (not `bash scriptname.sh` from outside).

## Prerequisites

- Ansible installed on the controller host
- SSH access to publisher/consumer test hosts (Linux)
- `sdkperf_c` binary placed in `pubSubTools/` (not included in repo)
- `config/credentials.yaml` present (gitignored — copy from `config/credentials.yaml.example`)

## Common Commands

```bash
# Initial setup
./setup.sh                             # Configure hosts and credentials interactively

# Running tests
./start-benchmarking-test.sh           # Menu: select and run a pre-defined benchmarking testset
benchmarking-tests/ent-10k-direct.sh <broker-ip>   # Run a specific benchmarking testset directly
./start-standard-discovery-test.sh     # Discovery test: prompts for all parameters
./start-custom-discovery-test.sh       # Wizard: builds a custom discovery testset

# Analysis (also runs automatically after each testset)
engine/analyse-result-set.sh 1k_mixed              # By shorthand (resolves to results/*_result.txt)
engine/analyse-result-set.sh results/foo_result.txt
engine/analyse-result-set.sh results/my-run/       # All files in directory
engine/analyse-result-set.sh                        # Scan entire results/ directory

# Versioning
./bump-version.sh v2.2.0              # Update VERSION before committing a significant change
```

## Architecture

The harness is structured in four layers:

```
User entry points  →  Engine runners  →  Ansible playbook  →  Remote host scripts
```

**User entry points** (`start-*.sh`, `benchmarking-tests/*.sh`, `discovery-tests/*.sh`, `custom-sets/*.sh`) define test scenarios as shell arrays and delegate to one of two engine runners.

**Engine runners** (`engine/run-testset.sh`, `engine/run-binsearch-testset.sh`) loop over scenarios:
- `run-testset.sh` — fixed-target mode: each scenario has a known target rate; pass/fail within 5% margin.
- `run-binsearch-testset.sh` — discovery mode: exponential probe (doubles rate from `upper_bound/1024`) then binary search; stops at ±1% precision or `search_iterations` (default 10).

Both runners invoke `engine/run-test.sh` per scenario, which calls `ansible-playbook engine/start-sdk.yaml` with test parameters serialized as JSON via `-e`.

**Ansible playbook** (`engine/start-sdk.yaml`) deploys `sdkperf_c` and the publisher/consumer scripts to test hosts, launches consumers first (async), then publishers (async), polls both to completion, and collects stdout.

**Remote scripts** (`scripts/sdkpublisher.sh`, `scripts/sdkconsumers.sh`) run on test hosts. Each spawns N sdkperf_c processes pinned to CPU cores via `taskset`, collects rate stats, and prints a summary line parsed by the runners.

## Test Scenario Formats

**Fixed-target** (`benchmarking-tests/`):
```
msg_size : fanout : overall_consumer_rate : parallel_pub_hosts : msg_type
```
`overall_consumer_rate` already includes fanout. The playbook divides by `parallel_hosts × fanout` to get per-publisher rate.

**Binary search** (`discovery-tests/`):
```
msg_size : fanout : parallel_pub_hosts : msg_type
```

Scenarios are space-separated within a bash array variable. Multiple arrays are joined with `;` as delimiter and passed as a single string argument to the runner. The runner splits on `;` to iterate arrays.

## Configuration

**`config/host`** — Ansible inventory with `[pubhost]` and `[subhost]` groups. Written by `setup.sh`.

**`config/credentials.yaml`** — Required fields: `broker_vpn`, `broker_username`, `broker_password`, `sshuser`, `pub_cores`, `sub_cores`. Both runner scripts validate the three broker credential fields before starting and abort early if missing.

**`VERSION`** — Contains `HARNESS_VERSION` and `HARNESS_DATE`. Sourced by runner scripts and written to the "Test environment" header of every result file. Run `./bump-version.sh vX.Y.Z` before committing.

## Result Files

Written to `results/{prefix}_{msg_type}_result.txt` after each testset. Free-form text with structured markers that `analyse-result-set.sh` parses (ANSI codes stripped). The analysis table is also appended to the result file.

`temp/` holds per-iteration logs during a run and is cleaned up afterwards.

## Key Tunable Parameters

In `engine/run-binsearch-testset.sh` (top of file): `runlength` (60s), `search_iterations` (10), `allowed_error_margin` (5%), `precision_pct` (1%), `inter_iteration_cooldown` (5s).

Upper bound overrides for capable brokers (export before calling the runner):
- `search_upper_bound_direct` (default 5,000,000)
- `search_upper_bound_nonpersistent` (default 2,000,000)
- `search_upper_bound_persistent` (default 1,000,000)

See `discovery-tests/londonlab-discovery.sh` for an example.

## LLM Tool Definitions

`docs/tools.json` contains Anthropic-format tool definitions for the harness operations. Pass the `tools` array to the Claude API `tools` parameter (or any OpenAI-compatible interface) to give an LLM the ability to run tests and analyse results programmatically.

Tools defined: `list_benchmarking_tests`, `run_benchmarking_test`, `run_discovery_test`, `run_custom_testset`, `run_single_test`, `analyse_results`, `list_results`.
