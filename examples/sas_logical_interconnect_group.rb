# (c) Copyright 2016 Hewlett Packard Enterprise Development LP
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed
# under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
# CONDITIONS OF ANY KIND, either express or implied. See the License for the
# specific language governing permissions and limitations under the License.

my_client = {
  url: ENV['ONEVIEWSDK_URL'],
  user: ENV['ONEVIEWSDK_USER'],
  password: ENV['ONEVIEWSDK_PASSWORD']
}

# This resource is only available for API300::Synergy, so we need to set these attributes
# to ensure it loads the correct resource_provider module. You can also set the api_version
# and api_variant properties on each resource definition below (see the README).
node.default['oneview']['api_version'] = 300
node.default['oneview']['api_variant'] = 'Synergy'

# Example: Create a SAS LIG with interconnects
oneview_sas_logical_interconnect_group 'SAS LIG' do
  my_client
  interconnects([
    { bay: 4, type: 'Synergy 12Gb SAS Connection Module' },
    { bay: 1, type: 'Synergy 12Gb SAS Connection Module' }
  ])
end

# Example: Delete a SAS LIG
oneview_logical_interconnect_group 'SAS LIG' do
  client my_client
  action :delete
end
