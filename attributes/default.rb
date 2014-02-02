#
# Author:: Andrew Coulton(<andrew@ingenerator.com>)
# Cookbook Name:: postfix-relay
# Attribute:: default
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

# Domain to send email from if no domain is specified
default['postfix_relay']['email_domain'] = nil

# Template to create forwarding addresses for local users
default['postfix_relay']['local_user_alias'] = nil


# Regular expression patterns (and replacements) to use to alter outgoing email sender addresses
default['postfix_relay']['outbound_address_replacements'] = node['postfix_relay']['outbound_address_replacements'] || {}

# By default, do not allow live email
default['postfix_relay']['allow_live_email']  = false

# Configuration for the mail dump. The transport will be included in postfix configuration if active is true
default['postfix_relay']['fs_mail']['active'] = false
default['postfix_relay']['fs_mail']['user']   = (node['vagrant'] ? "vagrant" : "ubuntu")
default['postfix_relay']['fs_mail']['file']   = "/tmp/outgoing_mail.dump"
