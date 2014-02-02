require 'spec_helper'

describe 'postfix-relay::default' do

  let (:chef_run) do
    ChefSpec::Runner.new do | node |
      node.set['postfix_relay']['email_domain']     = 'mysite.com'
      node.set['postfix_relay']['allow_live_email']                  = false
    end.converge(described_recipe)
  end
  
  it "creates /etc/postfix in case it is required before the package is installed" do#
    chef_run.should create_directory("/etc/postfix").with({
      :owner  => "root",
      :group  => "root",
      :mode   => 0644
    })
  end 
  
  it "installs local user aliases" do
    chef_run.should include_recipe "postfix-relay::alias_local_users"
  end
  
  it "installs sender aliases" do
    chef_run.should include_recipe "postfix-relay::alias_senders"
  end
  
  it "installs postfix as a dump or relay" do
    chef_run.should include_recipe "postfix-relay::install_postfix"
  end

end