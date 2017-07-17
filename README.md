inGenerator postfix-relay cookbook
==================================
[![Build Status](https://travis-ci.org/ingenerator/chef-postfix-relay.png?branch=0.3.x)](https://travis-ci.org/ingenerator/chef-postfix-relay)

`postfix-relay` installs and configures [postfix](http://www.postfix.org/) as a local mail relay server.
It supports four key goals:

* Capture local user alerting and notification mail on your server
* Reduce request handling latency and improve reliability of email delivery from your application
* Protect against flooding email accounts with alert/notification emails from dev and build servers
* Simplify functional testing of email-related parts of your application.

### Capturing local user email
Many shell and system processes send notifications by email to local user accounts on your server. You
can generally configure these to use alternate logging, but this is time consuming and you're likely to
miss some. With this cookbook, all local user email can be forwarded to an external alerting/bot account.
This will generally encourage you to switch off or find alternatives to email alerting for services you
don't care that much about!

### Reduce request handling latency and improve reliability
Your web application delivers mail to a local postfix instance on each machine, significantly reducing
the overhead of mail processing. Multi-tenant servers can be updated to use alternate email routing,
delivery and transport by reconfiguring the central relay server, rather than reconfiguring each
application. Email can be routed to a single trusted outbound SMTP server, avoiding issues with 
blacklisted or low-reputation cloud IP addresses.

### Protect against flooding email with dev/build notifications
Applications on development and build servers often generate high volumes of error notifications, 
application-related email (signup confirmations, password resets, etc). Often a dedicated external
mailbox has to be set up to receive and dump this traffic, or applications individually configured
not to send mail in the development environment. With this cookbook, the postfix relay transport
can be configured to dump all outgoing mail to simple files - allowing the rest of your infrastructure
and application to be provisioned as usual.

### Simplify functional testing
Functional tests of code that sends email, and usecases that require a user to receive an email (think
password reset, email confirmation, etc) can be tricky. Common techniques include fake email delivery 
or logging mechanisms in your application, but this gets dull fast. With this cookbook, all outbound
mail on dev/build is dumped to local files - your tests can easily inspect these both to check what 
was sent and where required to extract links, authentication codes, etc from them. Your whole application
runs in production conditions, with only the very final postfix relay switched for a fake.

Requirements
------------
- Chef 12 or higher
- **Ruby 2.3 or higher**

Installation
------------
We recommend adding to your `Berksfile` and using [Berkshelf](http://berkshelf.com/):

```ruby
cookbook 'postfix-relay', git: 'git://github.com/ingenerator/postfix-relay', branch: '0.3.x'
```

Have your main project cookbook *depend* on postfix-relay by editing the `metadata.rb` for your cookbook. 

```ruby
# metadata.rb
depends 'postfix-relay'
```

Usage
-----

For default installation and usage, set the following attributes in an attribute file, recipe or role.

```ruby

# The domain from which outbound email will be sent by default. In general your application should send with a full email address,
# but system accounts will append this domain to their local user - eg cron output will come from root@mysite.com.
# This is important because most remote SMTP servers will limit the domains they'll transfer mail for, so for example 
# root@my-cloud-virtual-server-hostname.my-cloud-provider.com is unlikely to make it through.
default['postfix_relay']['email_domain'] = mysite.com

# A template that will be used to create forwarding addresses for local users. :user will be replaced with the username
# Set the value to nil if you don't want to forward local mail
default['postfix_relay']['local_user_alias'] = 'alerts+:user@mycompany.com'

# Optional hash of regular expressions that will be used to change the sender email address of outbound mail
# For example, use this to change the sender email of the chef email reporting gem, which otherwise defaults to chef-client@{fqdn}
# Set nil to remove from the map
default['postfix_relay']['outbound_address_replacements']['/^chef-client@([^.]+).*$/'] = 'chef.${1}@mysite.com'

# Control whether email should be relayed - you'd generally set this in a role. 
# We like to default false, whitelisting roles that should be allowed to send mail
default['postfix_relay']['allow_live_email'] = true

# Configure the outbound relay - you'd usually set these values from an encrypted databag
# We default to assuming your remote SMTP user is using TLS encryption and requires login and authentication
# If you need something different you can override the underlying postfix attributes
default['postfix_relay']['live_email']['relayhost']           = 'smtp.somewhere.com:587'
default['postfix_relay']['live_email']['smtp_sasl_user_name'] = 'me@somewhere.com'
default['postfix_relay']['live_email']['smtp_sasl_passwd']    = 'password'

```

Then add the default recipe to your `run_list`:
```ruby
# In a role
"run_list" : [
  "recipe[postfix-relay::default]"
]

# In a recipe - note your cookbook must declare a dependency in metadata.rb as above
include_recipe "postfix-relay::default"
```

The default recipe executes the following steps:

| Recipe            | Action                                                                                              |
|-------------------|-----------------------------------------------------------------------------------------------------|
| install_postfix   | Runs the postfix::default recipe to install postfix, and configures the relay transports            |
| alias_local_users | Creates forwarding address aliases for all local users                                              |
| alias_senders     | Creates rules to inspect outbound email and replace sender addresses using regular expressions      |
  
To customise behaviour, include any or all of these recipes directly rather than relying on the default.

Attributes
----------

You *must* set the attributes shown in Usage above before this recipe will work. If any required attributes are not set, 
the cookbook will raise an ArgumentError.

Many other options are configurable - see the cookbook attributes files for details.

### Testing
See the [.travis.yml](.travis.yml) file for the current test scripts.

Contributing
------------
1. Fork the project
2. Create a feature branch corresponding to your change
3. Create specs for your change
4. Create your changes
4. Create a Pull Request on github

License & Authors
-----------------
- Author:: Andrew Coulton (andrew@ingenerator.com)

```text
Copyright 2012-2014, inGenerator Ltd

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
