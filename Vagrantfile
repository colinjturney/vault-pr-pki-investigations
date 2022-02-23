BOX_IMAGE = "bento/ubuntu-20.04"

Vagrant.configure("2") do |config|

  config.vm.define "vault-1" do |subconfig|
    subconfig.vm.box = BOX_IMAGE
    subconfig.vm.network "private_network", type: "dhcp"
    subconfig.vm.hostname = "vault-1"
    subconfig.vm.provider :virtualbox do |vb|
             vb.customize ['modifyvm', :id,'--memory', '512']
    end
    subconfig.vm.provision "shell" do |s|
      s.path = "install-vault.sh"
    end
  end

  config.vm.define "vault-2" do |subconfig|
    subconfig.vm.box = BOX_IMAGE
    subconfig.vm.network "private_network", type: "dhcp"
    subconfig.vm.hostname = "vault-2"
    subconfig.vm.provider :virtualbox do |vb|
             vb.customize ['modifyvm', :id,'--memory', '512']
    end
    subconfig.vm.provision "shell" do |s|
      s.path = "install-vault.sh"
    end
  end

end
