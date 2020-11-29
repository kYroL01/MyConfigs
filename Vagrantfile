# Vagrant config for WSL Debian (on Windows 10) - Ubuntu Bionic 64 Box

Vagrant.configure("2") do |config|
  config.vm.provider "virtualbox" do |v|
  v.memory = 4096
  v.cpus = 2
  v.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
  end
  
  config.vm.box = "ubuntu/bionic64"
  config.vm.synced_folder '.', '/vagrant', disabled: true
  # config.vm.provision "shell", path: "setup.sh"        
  config.vm.network :forwarded_port, guest: 80, host: 80
  config.vm.network :forwarded_port, guest: 443, host: 443
end 
