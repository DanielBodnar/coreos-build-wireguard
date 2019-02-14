# coreos-build-wireguard

Build WireGuard tools and kernel modules for CoreOS using Vagrant, following https://github.com/coreos/bugs/issues/2225#issuecomment-351578984

## Setup

### Vagrant plugins

```
vagrant install vagrant-sshfs
```

Install `sshfs` on your host system too.


### Downloading an appropriate developer image

You need a developer image that matches the Vagrant box you're going to run. `./fetch-dev-container` will download the latest `stable` dev container. 

If you're really bored, feel free to `bunzip2` it and `lz4` the image.

## For each run

```
rm -rf output
mkdir output
```

(This is necessary as some `sshfs` implementations will whine about non-empty directories.)

```
vagrant up
```

#### Be patient

The line that starts `systemd-nspawn --bind="$PWD:/host"` hangs for approximately three minutes for some reason.

## Output

In the `output` directory is a torcx package. Info on using it can be found at the [GitHub thread](https://github.com/coreos/bugs/issues/2225#issuecomment-351578984).