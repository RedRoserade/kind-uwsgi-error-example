# Repository to describe issue with `uwsgi` on `kind` with memory limits

For some reason, `uwsgi` seems to crash OOM in a `kind` cluster on some scenarios.

I set a memory limit of 512Mi for testing.

## Setup

1. An OpenShift cluster on IBM Cloud
2. A `kind` cluster on Fedora 33
3. A `kind` cluster on Ubuntu 20.10
4. Straight `docker run` both on Fedora 33 and Ubuntu 20.10

Docker version: 20.10.5
Kind version: Latest

## Running this

There's two `run-*.sh` on this repository. One runs in a `kind` cluster (assuming the default name) and the other runs via `docker run`.

Both build the image, and the `run-kind.sh` script also loads it into the cluster node.

## What happens

Setups 1, 3, and 4, all work well with this image. Scenario 2 only works with `MODE=http-socket`. When running with `MODE=http`, it is either OOM-killed or hangs.

(TODO dmesg logs)

## What I tried doing to get scenario 2 to work

### Increase memory limits

After increasing the memory limit to ~6Gi, `uwsgi` boots and then releases all the memory. However, this is impractical

### Try other modes

For some reason, `http-socket` works. From what I can tell, it launches one less process. However, considering it works with `http` on all the other scenarios, this should work too.

### Enable cgroups v1

Didn't do anything.
