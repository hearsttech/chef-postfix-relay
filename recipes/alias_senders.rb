#
# Creates the sender_canonical_maps map for outbound address replacements
#
# Author::  Andrew Coulton (<andrew@ingenerator.com>)
# Cookbook Name:: postfix-relay
# Recipe:: alias_senders
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

replacements = node['postfix_relay']['outbound_address_replacements'].reject {|pattern,replace| replace.nil? }

unless replacements.empty? then
  node.default['postfix']['main']['sender_canonical_maps'] = 'regexp:/etc/postfix/sender_canonical_maps'

  template "/etc/postfix/sender_canonical_maps" do
    owner    "root"
    group    "root"
    mode     0644
    notifies :reload, 'service[postfix]'
    variables({
      :replacements => replacements
    })
  end

  # Define for notification
  service "postfix" do
    action :nothing
  end

end