#
# Creates virtual alias maps for all local users
#
# Author::  Andrew Coulton (<andrew@ingenerator.com>)
# Cookbook Name:: postfix-relay
# Recipe:: alias_local_users
#
# Copyright 2013-14, inGenerator Ltd
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

unless node['postfix_relay']['local_user_alias'].nil?
  node.default['postfix']['main']['virtual_alias_maps'] = 'hash:/etc/postfix/virtual'

  # Define the alias mappings
  aliases = {}
  local_email_domain = node['postfix_relay']['email_domain']
  local_user_alias   = node['postfix_relay']['local_user_alias']
  node['etc']['passwd'].each_key do | user |
    local_email = "#{user}@#{local_email_domain}"
    aliases[local_email] = local_user_alias.sub(':user', user)
  end

  template "/etc/postfix/virtual" do
    owner    "root"
    group    "root"
    mode     0644
    notifies :run, "execute[update_postfix_virtual_aliases]"
    variables({
      :aliases => aliases,
    })
  end

  execute "update_postfix_virtual_aliases" do
    action   :nothing
    command  "postmap /etc/postfix/virtual"
    user     "root"
    notifies :reload, "service[postfix]"
  end

  # Define the service to notify
  service "postfix" do
    action  :nothing
  end

end