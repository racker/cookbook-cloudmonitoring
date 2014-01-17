# encoding: UTF-8
#
# Cookbook Name:: rackspace_cloudmonitoring
# Recipe:: agent
#
# Install and configure the cloud monitoring agent on a server
#
# Copyright 2014, Rackspace, US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if platform_family?('debian')
  rackspace_apt_repository 'cloud-monitoring' do

    if node['platform'] == 'ubuntu'
      uri "http://stable.packages.cloudmonitoring.rackspace.com/ubuntu-#{node['platform_version']}-#{node['kernel']['machine']}"
    elsif node['platform'] =='debian'
      uri "http://stable.packages.cloudmonitoring.rackspace.com/debian-#{node['lsb']['codename']}-#{node['kernel']['machine']}"
    end

    distribution 'cloudmonitoring'
    components ['main']
    key 'https://monitoring.api.rackspacecloud.com/pki/agent/linux.asc'
    action :add
  end

elsif platform_family?('rhel')
  # do RHEL things

  #Grab the major release for cent and rhel servers as this is what the repos use.
  releaseVersion = node['platform_version'].split('.').first

  #We need to figure out which signing key to use, cent5 and rhel5 have their own.
  if (node['platform'] == 'centos') && (releaseVersion == '5')
    signingKey = 'https://monitoring.api.rackspacecloud.com/pki/agent/centos-5.asc'
  elsif (node['platform'] == 'redhat') && (releaseVersion == '5')
    signingKey = 'https://monitoring.api.rackspacecloud.com/pki/agent/redhat-5.asc'
  else
    signingKey = 'https://monitoring.api.rackspacecloud.com/pki/agent/linux.asc'
  end

  rackspace_yum_key 'Rackspace-Monitoring' do
    url signingKey
    action :add
  end

  rackspace_yum_repository 'cloud-monitoring' do
    description 'Rackspace Monitoring'
    url "http://stable.packages.cloudmonitoring.rackspace.com/#{node['platform']}-#{releaseVersion}-#{node['kernel']['machine']}"
    action :add
  end
end

# Hook into the cloud_monitoring module to get access to the CM_agent_token and CM_credentials classes
# This is the easiest way to pull out the token and id generated by the LWRP
class Chef::Recipe
  include Opscode::Rackspace::Monitoring
end

credentials = CM_credentials.new(node, nil)
node.set[:rackspace_cloudmonitoring][:agent][:token] = credentials.get_attribute(:token)

# Call the agent_token LWRP to ensure we have a token in the API
rackspace_cloudmonitoring_agent_token "#{node.hostname}" do
  token               node[:rackspace_cloudmonitoring][:agent][:token]
  action :create
end


my_token_obj = CM_agent_token.new(credentials, node[:rackspace_cloudmonitoring][:agent][:token], "#{node.hostname}")
my_token = my_token_obj.get_obj

# Generate the config template
template '/etc/rackspace-monitoring-agent.cfg' do
  source 'rackspace-monitoring-agent.erb'
  cookbook node[:rackspace_cloudmonitoring][:templates_cookbook][:'rackspace-monitoring-agent']
  owner 'root'
  group 'root'
  mode 0600
  variables(
            # So the API calls it label, and the config calls it ID
            # Clear as mud.
            monitoring_id:    my_token.label,
            monitoring_token: my_token.token,
            )
  action :create
end

# Save the token label into the node attributes for use by the entity recipe
# Note that, like the agent, the entity API calls it ID.
node.default[:rackspace_cloudmonitoring][:agent][:id] = my_token.label

package 'rackspace-monitoring-agent' do
  if node[:rackspace_cloudmonitoring][:agent][:version] == 'latest'
    action :upgrade
  else
    version node[:rackspace_cloudmonitoring][:agent][:version]
    action :install
  end

  notifies :restart, 'service[rackspace-monitoring-agent]'
end

node[:rackspace_cloudmonitoring][:agent][:plugins].each_pair do |source_cookbook, path|
  remote_directory "rackspace_cloudmonitoring_plugins_#{source_cookbook}" do
    path node[:rackspace_cloudmonitoring][:agent][:plugin_path]
    cookbook source_cookbook
    source path
    files_mode 0755
    owner 'root'
    group 'root'
    mode 0755
    recursive true
    purge false
  end
end

service 'rackspace-monitoring-agent' do
  # TODO: RHEL, CentOS, ... support
  supports value_for_platform(
    ubuntu:  { default: [:start, :stop, :restart, :status] },
    default: { default: [:start, :stop] }
  )

  case node[:platform]
    when 'ubuntu'
    if node[:platform_version].to_f >= 9.10
      provider Chef::Provider::Service::Upstart
    end
  end

  action [:enable, :start]
  subscribes :restart, resources(template: '/etc/rackspace-monitoring-agent.cfg'), :delayed

end
