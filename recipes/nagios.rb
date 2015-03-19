#
# Recipe for doploying nagios3
#
#
#

bash 'update packages info' do
  code <<-EOF
    apt-get update
  EOF
end

package 'apache2' do
  action :upgrade
end

package 'apache2-utils' do
  action :upgrade
end

#bash 'nagios3' do
#  code <<-EOF
#    DEBIAN_FRONTEND=noninteractive apt-get install nagios3 -y
#    apt-get install pnp4nagios -y
#  EOF
#end
package 'nagios3' do
  action :upgrade
end

package 'pnp4nagios' do
  action :upgrade
end

#node.default['nagios_hostgroups'] = ["SJC-1","debian"]
#node.override['nagios_hostgroups'] = ["SJC-1","debian"]

#Clean up nagios config dir
#bash 'clean up' do
#  code <<-EOF
#    rm /etc/nagios3/conf.d/localhost_nagios2.cfg
#  EOF
#end

#Add new user "nagiosadmin" with password from attributes file
bash 'user_add' do
  code <<-EOF
    htpasswd -cb /etc/nagios3/htpasswd.users nagiosadmin #{node['nagiosadmin']['password']}
  EOF
end

bash 'include nagios3 config' do
  code <<-EOF
    echo "Include /etc/nagios3/apache2.conf" >> /etc/apache2/apache2.conf
  EOF
end

cookbook_file 'npcd' do
  path "/etc/default/npcd"
  owner "root"
  group "root"
  mode "0644"
  action :create
end

#Search nodes for nagios
#ng = node['nagios']['hostgroups_available']
#client_node = search(:node, "role:#{node['nagios']['check_role']}")
hash = Hash[node['nagios']['hostgroups_available'].map.with_index.to_a]
ng = Array.new()
client_node = search(:node, 'nagios_client:true')
client_node.each do |client|
  template "/etc/nagios3/conf.d/#{client['hostname']}.cfg" do
    source "hosts.cfg.erb"
    variables :client => client
  end
  puts "#{node['nagios']['hostgroups_available']}" + "    " + "#{client['nagios_hostgroups']}" + "    " + "#{client['nagios_hostgroups']}"
  if client['nagios_hostgroups'].nil?
    puts "*********      EMPTY      *******"
  else
    client['nagios_hostgroups'].each do |cli_hg|
      puts "#####################################################################     "+"#{cli_hg}" 
      if node['nagios']['hostgroups_available'].include? cli_hg    #client['nagios_hostgroups']
         puts "*****************************"
         puts "Include   " + "#{client['nagios_hostgroups']}" + "#{ node['nagios']['hostgroups_available'].include? client['nagios_hostgroups']}" 
         puts hash["#{cli_hg}"]
         puts client['hostname']
         puts "*****************************"
         ng[hash["#{cli_hg}"][0]] = client['hostname']
         #ng[hash["#{cli_hg}"]].push(client['hostname'])
         #client['nagios_hostgroups'].each do |cli_hg|
         #  ng[cli_hg] = ng[cli_hg] + client['hostname']
         #end
      end
    end
  end
end
puts "#{ng}"
#Create new hostgroup file
#puts "#{ng}"
#puts ng
#puts ng[1]
#puts ng[2]
#ng.each do |arr|
#  print 



#
#node['nagios']['hostgroups_available'].each do |hg|


service 'nagios3' do
  supports :status => true, :start => true, :stop => true, :restart => true
  action :restart
end

service 'apache2' do
  supports :status => true, :start => true, :stop => true, :restart => true
  action :restart
end
