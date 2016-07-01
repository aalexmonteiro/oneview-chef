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

module OneviewCookbook
  # Define default properties for all resources
  module ResourceBaseProperties
    # Loads the default properties for all resources
    def self.load(context)
      context.property :client, required: true
      context.property :name, [String, Symbol], required: true
      context.property :data, Hash, default: {}
      context.property :save_resource_info, [TrueClass, FalseClass, Array], default: context.node['oneview']['save_resource_info']
    end
  end

  # Oneview Resources base actions
  module ResourceBase
    # Create a OneView resource or update it if exists
    # @param [OneviewSDK::Resource] item item to be created or updated
    # @return [TrueClass, FalseClass] Returns true if the resource was created, false if updated or unchanged
    def create_or_update(item = nil)
      ret_val = false
      item ||= load_resource
      temp = item.data.clone
      if item.exists?
        item.retrieve!
        if item.like? temp
          Chef::Log.info("#{resource_name} '#{name}' is up to date")
        else
          Chef::Log.debug "#{resource_name} '#{name}' Chef resource differs from OneView resource."
          Chef::Log.info "Update #{resource_name} '#{name}'"
          converge_by "Update #{resource_name} '#{name}'" do
            item.update(temp) # Note: Assumes resources supports #update
          end
        end
      else
        Chef::Log.info "Create #{resource_name} '#{name}'"
        converge_by "Create #{resource_name} '#{name}'" do
          item.create
        end
        ret_val = true
      end
      save_res_info(save_resource_info, name, item)
      ret_val
    end

    # Create a OneView resource only if it doesn't exist
    # @param [OneviewSDK::Resource] item item to be created
    # @return [TrueClass, FalseClass] Returns true if the resource was created
    def create_if_missing(item = nil)
      ret_val = false
      item ||= load_resource
      if item.exists?
        Chef::Log.info("'#{resource_name} #{name}' exists. Skipping")
        item.retrieve! if save_resource_info
      else
        Chef::Log.info "Create #{resource_name} '#{name}'"
        converge_by "Create #{resource_name} '#{name}'" do
          item.create
        end
        ret_val = true
      end
      save_res_info(save_resource_info, name, item)
      ret_val
    end

    # Delete a OneView resource if it exists
    # @param [OneviewSDK::Resource] item item to be deleted
    # @return [TrueClass, FalseClass] Returns true if the resource was deleted
    def delete(item = nil)
      item ||= load_resource
      return false unless item.retrieve!
      converge_by "Delete #{resource_name} '#{name}'" do
        item.delete
      end
      true
    end

    # Let Chef know that the why-run flag is supported
    def whyrun_supported?
      true
    end
  end
end
