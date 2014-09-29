#
# Installs postfix configured to send mail to a local dump file
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

node.normal['postfix']['main']['default_transport']   = 'fs_mail'
node.normal['postfix']['main']['relayhost']           = 'localhost'
node.normal['postfix']['sasl']['smtp_sasl_passwd']    = 'localhost'
node.normal['postfix']['sasl']['smtp_sasl_user_name'] = 'localhost'
node.normal['postfix']['master_template_source']      = 'postfix-relay'
node.normal['postfix_relay']['fs_mail']['active']     = true

include_recipe "postfix::default"
