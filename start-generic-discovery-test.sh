#!/bin/bash
# Wrapper to launch the generic discovery test.
# Prompts for broker, SSH user, host count, upper bounds, and message types,
# then runs exponential probe + binary search across a standard scenario matrix.
#
# Usage: ./start-generic-discovery-test.sh

${BASH_SOURCE%/*}/discovery-tests/generic-discovery.sh "$@"
