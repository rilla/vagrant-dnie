#
# Cookbook Name:: opendnie
# Recipe:: default
#
# Copyright 2013, Jose A. Rilla <jose@rilla.es>
# Basada en http://bitplanet.es/manuales/3-linux/322-instalar-lector-dnie-en-ubuntu-1204.html
#
# All rights reserved - Do Not Redistribute
#
require 'fileutils'
require 'tempfile'

package "opensc" do
  action :purge
end

[
  'xorg',
  'openbox',
  'virtualbox-guest-additions',
  'pcscd',
  'pcsc-tools',
  'autoconf',
  'subversion',
  'libpcsclite-dev',
  'libreadline6',
  'libreadline-dev',
  'openssl',
  'libssl-dev',
  'libtool',
  'libltdl-dev',
  'libccid',
  'pinentry-gtk2',
  'libnss3-tools',
  'pkg-config',
  'unzip',
  'build-essential',
  'usbmount',
  'firefox',
  'firefox-locale-es',
  'icedtea-plugin'
].each do |p|
  package p do
    retries 5
    action :install
  end
end

execute "Upgrade all packages" do
  command <<-EOC
    DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
  EOC
end

directory "/home/vagrant/opendnie" do
  owner "vagrant"
  group "vagrant"
  mode 0755
  action :create
end

directory "/home/vagrant/opendnie/certs" do
  owner "vagrant"
  group "vagrant"
  mode 0755
  action :create
end

remote_file "/home/vagrant/opendnie/certs/ACRAIZ-SHA2.zip" do
  source "http://www.dnielectronico.es/ZIP/ACRAIZ-SHA2.zip"
  owner "vagrant"
  group "vagrant"
  mode 0755
  not_if { ::File.exists? "/home/vagrant/opendnie/certs/ACRAIZ-SHA2.zip" }
end

remote_file "/home/vagrant/opendnie/certs/AVDNIEFNMTSHA2.zip" do
  source "http://www.dnielectronico.es/seccion_integradores/certificados/AVDNIEFNMTSHA2.zip"
  owner "vagrant"
  group "vagrant"
  mode 0755
  not_if { ::File.exists? "/home/vagrant/opendnie/certs/AVDNIEFNMTSHA2.zip" }
end

execute "unzip certs into ~/opendnie/certs" do
 cwd "/home/vagrant/opendnie/certs"
 user "vagrant"
 group "vagrant"
 command "unzip -o ACRAIZ-SHA2.zip && unzip -o AVDNIEFNMTSHA2.zip"
 action :run
 not_if { ::File.exists? "/home/vagrant/opendnie/certs/ACRAIZ-SHA2.crt" and ::File.exists? "/home/vagrant/opendnie/certs/AVDNIEFNMTSHA2.cer" }
end

cookbook_file "/home/vagrant/dotfiles.tgz" do
  user "vagrant"
  group "vagrant"
  source "dotfiles.tgz"
  not_if { ::File.exists? "/home/vagrant/dotfiles.tgz" }  
end

execute "untar dotfiles into ~" do
  cwd "/home/vagrant"
  user "vagrant"
  group "vagrant"
  command "tar xzf dotfiles.tgz"
  not_if { ::File.directory? "/home/vagrant/.mozilla" }
end

execute "Install certificates" do
  user "vagrant"
  group "vagrant"
  profile_path = "/home/vagrant/.mozilla/firefox/hk5vd8qu.default"
  command <<-EOC
    certutil -A -d #{ profile_path } -i /home/vagrant/opendnie/certs/ACRAIZ-SHA2.crt -n 'AC RAIZ DNIE' -t 'TCu,Cuw,Tuw'
    certutil -A -d #{ profile_path } -i /home/vagrant/opendnie/certs/AVDNIEFNMTSHA2.cer -n 'AV DNIE FNMT' -t 'TCu,Cuw,Tuw'
  EOC
  action :run
end

ruby_block 'modify-makefile' do
  block do
    temp_file = Tempfile.new('Makefile.am')
    flag = false
    File.open("/home/vagrant/opendnie/opensc-opendnie/src/tools/Makefile.am", 'r') do |f|
      f.each_line do |line|
        if line =~ /^LIBS = /
          flag = true
          temp_file.write line
        elsif flag && line !~ /\\$/
          flag = false
          temp_file.write "#{ line.gsub(/\n/, '') } \\\n      /usr/lib/i386-linux-gnu/libltdl.la"
        else
          temp_file.write line
        end
      end
    end
    FileUtils.mv("/home/vagrant/opendnie/opensc-opendnie/src/tools/Makefile.am", "/home/vagrant/opendnie/opensc-opendnie/src/tools/Makefile.original")
    FileUtils.mv(temp_file.path, "/home/vagrant/opendnie/opensc-opendnie/src/tools/Makefile.am")
  end
  action :nothing
end

execute "Checkout opensc-opendnie" do
  command <<-EOC
    svn checkout --username anonsvn --password anonsvn --trust-server-cert --non-interactive https://forja.cenatic.es/svn/opendnie/opensc-opendnie/trunk /home/vagrant/opendnie/opensc-opendnie
  EOC
  not_if { ::File.directory? "/home/vagrant/opendnie/opensc-opendnie" }
  notifies :create, "ruby_block[modify-makefile]", :immediately
end

execute "Compile OpenSC" do
  cwd "/home/vagrant/opendnie/opensc-opendnie"
  command <<-EOC
    ./bootstrap &&\
    ./configure --prefix=/usr --sysconfdir=/etc/opensc &&\
    make &&\
    make install
  EOC
  not_if { ::File.exists? "/usr/lib/opensc-pkcs11.so" }
end

execute "Install OpenSC module in Firefox" do
  command "modutil -add PKCS11 -libfile /usr/lib/opensc-pkcs11.so -force -dbdir /home/vagrant/.mozilla/firefox/hk5vd8qu.default/"
  notifies :run, "execute[reboot]", :immediately
  not_if { `modutil -list -dbdir /home/vagrant/.mozilla/firefox/hk5vd8qu.default/ | grep /usr/lib/opensc-pkcs11.source` }
end

execute "reboot" do
 command "( sleep 5; reboot -f ) &"
 action :nothing
end

