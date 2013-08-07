#
# Cookbook Name:: cloud_monitoring
# Recipe:: default
#
# Copyright 2012, Rackspace
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
include_recipe 'xml::ruby' unless platform_family?("windows")

e = cookbook_file "/tmp/fog-1.14.1-monitoring.gem" do
  backup false
  action :nothing 
end

e.run_action(:create_if_missing)


chef_gem "fog" do
#  version node['cloud_monitoring']['fog_version']
  source "/tmp/fog-1.14.1-monitoring.gem"
  action :install
end

require 'fog'

begin
  # Access the Rackspace Cloud encrypted data_bag
  raxcloud = Chef::EncryptedDataBagItem.load("rackspace","cloud")

  #Create variables for the Rackspace Cloud username and apikey
  node.set['cloud_monitoring']['rackspace_username'] = raxcloud['username']
  node.set['cloud_monitoring']['rackspace_api_key'] = raxcloud['apikey']
  node.set['cloud_monitoring']['rackspace_auth_region'] = raxcloud['region'] || 'notset'
  node.set['cloud_monitoring']['rackspace_auth_region'] = node['cloud_monitoring']['rackspace_auth_region'].downcase

  if node['cloud_monitoring']['rackspace_auth_region'] == 'us'
    node.set['cloud_monitoring']['rackspace_auth_url'] = 'https://identity.api.rackspacecloud.com/v2.0'
  elsif node['cloud_monitoring']['rackspace_auth_region']  == 'uk'
    node.set['cloud_monitoring']['rackspace_auth_url'] = 'https://lon.identity.api.rackspacecloud.com/v2.0'
  else
    Chef::Log.info "Using the encrypted data bag for rackspace cloud but no raxregion attribute was set (or it was set to something other then 'us' or 'uk'). Assuming 'us'. If you have a 'uk' account make sure to set the raxregion in your data bag"
    node.set['cloud_monitoring']['rackspace_auth_url'] = 'https://identity.api.rackspacecloud.com/v2.0'
  end
rescue Exception => e
  Chef::Log.error "Failed to load rackspace cloud data bag: " + e.to_s
end

if node[:cloud_monitoring][:rackspace_username] == 'your_rackspace_username' || node['cloud_monitoring']['rackspace_api_key'] == 'your_rackspace_api_key'
  Chef::Log.info "Rackspace username or api key has not been set. For this to work, either set the default attributes or create an encrypted databag of rackspace cloud per the cookbook README"
end
