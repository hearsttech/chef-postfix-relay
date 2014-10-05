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
normal['postfix']['main']['inet_interfaces']              = 'loopback-only'
normal['postfix']['main']['smtp_sasl_auth_enable']        = 'yes'
normal['postfix']['main']['smtp_use_tls']                 = 'yes'
normal['postfix']['main']['smtp_tls_security_level']      = 'encrypt'
normal['postfix']['main']['smtp_tls_note_starttls_offer'] = 'yes'
normal['postfix']['main']['smtp_tls_CAfile']              = '/etc/ssl/certs/ca-certificates.crt'
normal['postfix']['sasl_password_file']                   = "#{node['postfix']['conf_dir']}/sasl_passwd"
normal['postfix']['main']['smtp_sasl_password_maps']      = "hash:#{node['postfix']['sasl_password_file']}"
normal['postfix']['main']['smtp_sasl_security_options']   = 'noanonymous'
normal['postfix']['main']['smtp_sasl_mechanism_filter']   = 'login'
