#
# Author:: Andrew Coulton(<andrew@ingenerator.com>)
# Cookbook Name:: postfix-relay
# Attribute:: postfix
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

# Override the default configuration from the postfix cookbook to match our standard use
default['postfix']['main']['inet_interfaces']              = 'loopback-only'
default['postfix']['main']['smtp_sasl_auth_enable']        = 'yes'
default['postfix']['main']['smtp_use_tls']                 = 'yes'
default['postfix']['main']['smtp_tls_security_level']      = 'encrypt'
default['postfix']['main']['smtp_tls_note_starttls_offer'] = 'yes'
default['postfix']['main']['smtp_tls_CAfile']              = '/etc/ssl/certs/ca-certificates.crt'
default['postfix']['main']['smtp_sasl_password_maps']      = "hash:#{node['postfix']['conf_dir']}/postfix/sasl_passwd"
default['postfix']['main']['smtp_sasl_security_options']   = 'noanonymous'
default['postfix']['main']['smtp_sasl_mechanism_filter']   = 'login'

