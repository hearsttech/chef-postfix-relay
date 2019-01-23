name 'postfix-relay'
maintainer 'Andrew Coulton'
maintainer_email 'andrew@ingenerator.com'
license 'Apache-2.0'
chef_version '>=12.18.31'
description 'Installs postfix as a local mail relay, optionally delivering all mail to local dump files (for dev/build servers)'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.4.3'
issues_url 'https://github.com/ingenerator/chef-postfix-relay/issues'
source_url 'https://github.com/ingenerator/chef-postfix-relay'

%w(ubuntu).each do |os|
  supports os
end

depends "postfix", "~>5.3"
