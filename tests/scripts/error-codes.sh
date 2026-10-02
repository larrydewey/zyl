#!/usr/bin/env bash
# The error-code catalog matches the raise sites exactly (verify/error-codes.sh).
exec bash "$(cd "$(dirname "$0")/../.." && pwd)/verify/error-codes.sh"
