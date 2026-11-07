#!/bin/bash
# Start Pi against the LLM server on the agx host.
export LLAMA_BASE_URL="http://192.168.0.32:9931"
pi
# Keep the terminal open briefly so final output stays readable; Enter skips.
read -t 20
