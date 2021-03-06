# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "precise32"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  config.vm.box_url = "http://files.vagrantup.com/precise32.box"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network :forwarded_port, guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network :private_network, ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network :public_network

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"
  # config.vm.share_folder "shared", "/home/vagrant/shared", "./shared", { :create => true }

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider :virtualbox do |vb|
    # Don't boot with headless mode
    vb.gui = true
    # Use VBoxManage to customize the VM. For example to change memory:
    vb.customize [ 
      "modifyvm", :id,
      "--vram", 128,
      "--memory", 1024,
       "--usb", :on
    ]
    vb.customize [
      "usbfilter", 
      "add", 0, "--target", :id, "--name", "Connect all USB devices to VM"
    ]
  end
  #
  # View the documentation for the provider you're using for more
  # information on available options.

  config.vm.provision :chef_solo do |chef|
    # chef.cookbooks_path = "../my-recipes/cookbooks"
    # chef.roles_path = "../my-recipes/roles"
    # chef.data_bags_path = "../my-recipes/data_bags"
    chef.add_recipe "apt"
    # chef.add_recipe "lightweight-desktop"
    # chef.add_recipe "apt"
    chef.add_recipe "opendnie"
    # chef.add_role "web"
  
    # You may also specify custom JSON attributes:
    # chef.json = { :mysql_password => "foo" }
  end

  # config.vm.provider :virtualbox do |vb|
  #   # Don't boot with headless mode
  #   vb.gui = true
  #   vb.customize [
  #     "usbfilter", 
  #     "add", 0, "--target", :id, "--name", "Connect all USB devices to VM"
  #   ]
  # end

end
