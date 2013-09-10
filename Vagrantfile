# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("1") do |config|
  config.vm.box = "debian-7.1.0"

  config.vm.network :hostonly, "10.11.12.13"

  config.vm.forward_port 80, 4000

  #config.vm.share_folder "pari", "/pari", "../pari"

  VAGRANT_JSON = {
    "python" => {
      "version" => "2.7.3",
      "install_method" => "source"
    },
    "nginx" => {
      "version" => "1.4.1",
      "default_site_enabled" => false,
      "source" => {
        "modules" => ["http_gzip_static_module", "http_ssl_module"]
      }
    },
    "postgresql" => {
      "password" => {
        "postgres" => "md59d112bc849c9e18f409dacd4e45898d0"
      }
    },
    "memcached" => {
      "listen" => "127.0.0.1",
      "user" => "www-data",
      "group" => "www-data"
    },
    "django_app" => {
      "debug" => "true",
      "settings_module" => "vagrant",
      "server_name" => "dev.ruralindiaonline.org"
    },
    "s3cmd" => {
      "users" => [:root, :vagrant],
      "aws_access_key_id" => "",
      "aws_secret_access_key" => ""
    },
    "run_list" => [
      "recipe[apt]",
      "recipe[build-essential]",
      "recipe[git]",
      "recipe[nodejs]",
      "recipe[nginx::source]",
      "recipe[python::default]",
      "recipe[gunicorn::default]",
      "recipe[supervisor]",
      "recipe[postgresql::server]",
      "recipe[memcached]",
      "recipe[s3cmd]",
      "recipe[django_app]"
    ]
  }

  config.vm.provision :shell, :inline => "gem install chef --version 11.4.2 --no-rdoc --no-ri --conservative"

  config.vm.provision :chef_solo do |chef|
     chef.cookbooks_path = ["site-cookbooks", "cookbooks"]
     chef.roles_path = "roles"
     chef.data_bags_path = "data_bags"
     chef.provisioning_path = "/tmp/vagrant-chef"

     chef.json = VAGRANT_JSON
     VAGRANT_JSON['run_list'].each do |recipe|
      chef.add_recipe(recipe)
     end if VAGRANT_JSON['run_list']
  end

  config.vm.provision :chef_client do |chef|
    chef.chef_server_url = "https://api.opscode.com/organizations/ruralindia"
    chef.validation_key_path = "#{ENV['HOME']}/.chef/ruralindia-validator.pem"
    chef.environment = "dev"
    chef.validation_client_name = "ruralindia-validator"
    chef.client_key_path = "#{ENV['HOME']}/.chef/manojlds.pem"
    chef.add_role("djangoapp")
  end

end
