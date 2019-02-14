# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrant configuration v2
Vagrant.configure("2") do |config|

  config.vm.box = "coreos-stable"

  ## Provider definitions

  config.vm.provider :libvirt do |libvirt, override|
    override.vm.box = "pjz/coreos-stable"
    libvirt.cpus = 4
    libvirt.memory = 4096   # 4GB of RAM
    libvirt.cputopology :sockets => '1', :cores => '2', :threads => '2'
  end

  config.vm.provider :parallels do |prl|
    prl.cpus = 2
    prl.memory = 2048
  end

  # Vultr deploys its ssh keys into /root/.ssh/authorized_keys instead of /home/core.
  # For non-Vultr providers, we don't need to do anything:
  config.vm.provision "fix_ssh_user", type: "shell", preserve_order: true,
                      inline: "echo nothing needed, 'core' user has keys"

  config.vm.provider :vultr do |vultr, override|
    override.ssh.keys_only = false
    override.ssh.private_key_path = '~/.ssh/id_rsa'
    override.vm.box = 'vultr'
    override.vm.box_url = 'https://github.com/p0deje/vagrant-vultr/raw/master/box/vultr.box'
    vultr.os = 'CoreOS Stable'
    vultr.region = 'New Jersey'

    # If we don't do this, we get an attempted SMB share??
    override.vm.synced_folder ".", "/vagrant", disabled: true

    # Because Vultr put our keys in the wrong place, copy them to the 'core' user.
    override.vm.provision "fix_ssh_user", type: "shell", preserve_order: true,
        inline: "cp /root/.ssh/authorized_keys /home/core/.ssh/authorized_keys"
  end

  ## End of providers


  config.vm.synced_folder "./on-builder", "/root/build", type: "rsync"

  ### developer container is found at:
  # http://stable.release.core-os.net/amd64-usr/current/coreos_developer_container.bin.bz2

  # The uncompressed version may not work; it looks like:
  # config.vm.provision "file", source: "coreos_developer_container.bin", destination: "/home/core/coreos_developer_container.bin"

  config.vm.provision "file", source: "coreos_developer_container.bin.bz2", destination: "/home/core/coreos_developer_container.bin.bz2"

  # config.vm.provision "file", source: "coreos_developer_container.bin.lz4", destination: "/home/core/coreos_developer_container.bin.lz4"

  config.vm.synced_folder "./output", "/mnt", type: "sshfs", reverse: true

$stage2 = <<-SCRIPT
sudo -i bash /root/build/stage2
SCRIPT

$stage3 = <<-SCRIPT
sudo -i bash /root/build/stage3
SCRIPT

  ## Provisioner definitions
  config.vm.provision "shell", inline: $stage2
  config.vm.provision "shell", inline: $stage3

end
