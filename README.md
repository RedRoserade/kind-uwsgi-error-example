# Repository to describe issue with `uwsgi` on `kind` with memory limits

For some reason, `uwsgi` seems to crash OOM in a `kind` cluster on some scenarios. If I give the pod >8Gi memory limit, it will boot but it'll consume those 8Gi.

I set a memory limit of 512Mi for testing.

## Setup

1. An OpenShift cluster on IBM Cloud
2. A `kind` cluster on Fedora 33
3. A `kind` cluster on Ubuntu 20.10
4. Straight `docker run` both on Fedora 33 and Ubuntu 20.10
5. Straight `podman run` on Fedora 33
6. A `k3s` cluster on Fedora 33

Docker version: 20.10.5

Kind version: `kind v0.10.0 go1.15.7 linux/amd64`

Podman version: `3.0.1`

## Running this

There's three `run-*.sh` on this repository:

- `run-kind.sh` runs in a `kind` cluster (assuming the default name)
- `run-docker.sh` runs via `docker run`
- `run-k3s` runs via a `k3s` cluster (assuming on the local machine)

Both build the image, and the `run-kind.sh` and `run-k3s.sh` scripts also load it into their cluster nodes.

## What happens

Setups 1, 3, 4, 5 and 6 all work well with this image. Scenario 2 only works with `MODE=http-socket`. When running with `MODE=http`, it is either OOM-killed or hangs.

## What I tried doing to get scenario 2 to work

### What works

#### Increase memory limits

After increasing the memory limit to >8Gi, `uwsgi` boots, however, it keeps around 8Gi in-memory (doesn't de-allocate)

#### Try other modes

For some reason, `http-socket` works. From what I can tell, it launches one less process. However, considering it works with `http` on all the other scenarios, this should work too.

### What doesn't work

- Enable cgroups v1
- Try alpine-based versions and python 3.9-based versions
- Disable SELinux
- Running with `securityContext.capabilities.add = ["ALL"]`
- Running with `securityContext.runAsUser = 1000`
- Disabling swap via `swapoff -a`: https://github.com/kubernetes-sigs/kind/issues/2175#issuecomment-812457026

## Logs

### dmesg

The following logs can be found via `dmesg -T`:

```
[Thu Apr  1 16:45:10 2021] Memory cgroup stats for /docker/428406e4f18a1cb65e9691d40b63f3d92c95c1b0d15b5c427bed470b6832cd6e/kubelet/kubepods/pod1788d98a-0700-426a-8701-2312e4cc2163:
[Thu Apr  1 16:45:10 2021] anon 314535936
                           file 0
                           kernel_stack 49152
                           pagetables 8785920
                           percpu 0
                           sock 0
                           shmem 0
                           file_mapped 135168
                           file_dirty 270336
                           file_writeback 405504
                           anon_thp 0
                           file_thp 0
                           shmem_thp 0
                           inactive_anon 522788864
                           active_anon 3244032
                           inactive_file 0
                           active_file 98304
                           unevictable 0
                           slab_reclaimable 267248
                           slab_unreclaimable 489224
                           slab 756472
                           workingset_refault_anon 25080
                           workingset_refault_file 28017
                           workingset_activate_anon 0
                           workingset_activate_file 12045
                           workingset_restore_anon 0
                           workingset_restore_file 6666
                           workingset_nodereclaim 0
                           pgfault 17409645
                           pgmajfault 23265
                           pgrefill 32446
                           pgscan 32927525
                           pgsteal 13657687
                           pgactivate 38181
                           pgdeactivate 29054
                           pglazyfree 0
                           pglazyfreed 0
                           thp_fault_alloc 0
                           thp_collapse_alloc 0
[Thu Apr  1 16:45:10 2021] Tasks state (memory values in pages):
[Thu Apr  1 16:45:10 2021] [  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name
[Thu Apr  1 16:45:10 2021] [   7513]     0  7513      243        0    24576        8          -998 pause
[Thu Apr  1 16:45:10 2021] [   7863]     0  7863     1013      156    45056       21          -997 sleep
[Thu Apr  1 16:45:10 2021] [   8033]     0  8033     1439      790    53248      107          -997 bash
[Thu Apr  1 16:45:10 2021] [   9571]     0  9571     1439      818    45056       99          -997 bash
[Thu Apr  1 16:45:10 2021] [  11637]     0 11637    18094     3588   131072     3182          -997 uwsgi
[Thu Apr  1 16:45:10 2021] [  11638]     0 11638  2109807    76320  9076736  1045307          -997 uwsgi
[Thu Apr  1 16:45:10 2021] oom-kill:constraint=CONSTRAINT_MEMCG,nodemask=(null),cpuset=a07d3c191742700df28b349710c93b2014b255b22364decb09b53ca123fa8272,mems_allowed=0,oom_memcg=/docker/428406e4f18a1cb65e9691d40b63f3d92c95c1b0d15b5c427bed470b6832cd6e/kubelet/kubepods/pod1788d98a-0700-426a-8701-2312e4cc2163,task_memcg=/docker/428406e4f18a1cb65e9691d40b63f3d92c95c1b0d15b5c427bed470b6832cd6e/kubelet/kubepods/pod1788d98a-0700-426a-8701-2312e4cc2163/a07d3c191742700df28b349710c93b2014b255b22364decb09b53ca123fa8272,task=uwsgi,pid=11638,uid=0
```

### `ps` (via `docker run`)

```
➜  kind-uwsgi-error-example git:(main) ✗ docker exec -it test-mem-usage ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  1.4  0.1  73080 31448 ?        Ss   08:28   0:00 uwsgi --http 
root           7  0.0  0.0  59008 10996 ?        S    08:28   0:00 uwsgi --http 
root          33  0.0  0.0   9396  2988 pts/0    Rs+  08:29   0:00 ps aux
```

### `ps` (via pod on `kind`, with `resources.limits.memory: 12Gi`)

```
➜  kind-uwsgi-error-example git:(main) ✗ kubectl exec -it example-pod -- ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  2.8  0.1  73084 26164 ?        Ss   08:31   0:00 uwsgi --http 
root           7 47.3 52.3 8439420 8390708 ?     S    08:31   0:12 uwsgi --http 
root          20  0.0  0.0   9396  3088 pts/0    Rs+  08:31   0:00 ps aux
```

Notice the much higher CPU usage too.


### `ps` (via pod on `k3s`, with `resources.limits.memory: 512Mi`)

```
➜  kind-uwsgi-error-example git:(main) ✗ kubectl exec -it example-pod -- ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.2  0.1  73084 31476 ?        Ss   09:14   0:00 uwsgi --http 
root           7  0.0  0.0  59008 10988 ?        S    09:14   0:00 uwsgi --http 
root          14  0.0  0.0   9396  3000 pts/0    Rs+  09:16   0:00 ps aux
```
