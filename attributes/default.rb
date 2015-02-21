#
# Cookbook Name:: cloud_monitoring
# Recipe:: default
#
# Copyright 2014, Rackspace
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
default['cloud_monitoring']['rackspace_monitoring_version'] = '0.2.18'
default['cloud_monitoring']['fog_version'] = '1.16.0'
default['cloud_monitoring']['checks'] = {}
default['cloud_monitoring']['alarms'] = {}
default['cloud_monitoring']['rackspace_username'] = 'your_rackspace_username'
default['cloud_monitoring']['rackspace_api_key'] = 'your_rackspace_api_key'
default['cloud_monitoring']['rackspace_auth_region'] = 'us'
default['cloud_monitoring']['abort_on_failure'] = true

default['cloud_monitoring']['agent'] = {}
default['cloud_monitoring']['agent']['id'] = nil
default['cloud_monitoring']['agent']['channel'] = nil
default['cloud_monitoring']['agent']['version'] = 'latest'
default['cloud_monitoring']['agent']['token'] = nil
default['cloud_monitoring']['monitoring_endpoints'] = [] # This should be a list of strings like 'x.x.x.x:port'

default['cloud_monitoring']['plugin_path'] = '/usr/lib/rackspace-monitoring-agent/plugins'
# This looks a little weird but is intentional so that this cookbook and its
# plugins directory always gets included in the list of plugins and won't get overwriten by
# a role or node attribute.
default['cloud_monitoring']['plugins']['cloud_monitoring'] = 'plugins'

default['cloud_monitoring']['credentials']['databag_name'] = 'rackspace'
default['cloud_monitoring']['credentials']['databag_item'] = 'cloud'

# Check default values
default['cloud_monitoring']['check_default']['period'] = 30
default['cloud_monitoring']['check_default']['timeout'] = 10

# Default main configuration hash for monitors.rb
# No checks are defined by default as there is an account-wide limit and each check incurrs billing
# http://docs.rackspace.com/cm/api/v1.0/cm-devguide/content/api-rsource-limits.html
default['cloud_monitoring']['monitors'] = {}
