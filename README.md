# Repository to describe issue with `uwsgi` on `kind` with memory limits

For some reason, `uwsgi` seems to crash OOM in a `kind` cluster on some scenarios.

I set a memory limit of 512Mi for testing.

## Setup

1. An OpenShift cluster on IBM Cloud
2. A `kind` cluster on Fedora 33
3. A `kind` cluster on Ubuntu 20.10
4. Straight `docker run`

## What works

Setups 1., 3., and 4., all work well with this image.
