#
# Installs postfix configured to relay mail to a remote host
#
# Author::  Andrew Coulton (<andrew@ingenerator.com>)
# Cookbook Name:: postfix-relay
# Recipe:: install_local_dump
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


# Set postfix access credentials
node.normal['postfix']['main']['relayhost']           = node['postfix_relay']['live_email']['relayhost']
node.normal['postfix']['sasl']['smtp_sasl_passwd']    = node['postfix_relay']['live_email']['smtp_sasl_passwd']
node.normal['postfix']['sasl']['smtp_sasl_user_name'] = node['postfix_relay']['live_email']['smtp_sasl_user_name']

# Ensure that outgoing mail without a domain (eg from local users) is in the correct domain
node.normal['postfix']['main']['myhostname']          = node['postfix_relay']['email_domain']
# Ensure that mail to addresses in the email_domain is sent externally
node.normal['postfix']['main']['mydestination']       = "#{node['hostname']}, localhost.localdomain, localhost"

include_recipe "postfix::default"
