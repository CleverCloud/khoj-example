#!/bin/sh
# The Clever Cloud Python runtime runs Nginx on port 8080 and forwards requests to port 9000
exec khoj --host="0.0.0.0" --port=9000 --anonymous-mode --non-interactive
