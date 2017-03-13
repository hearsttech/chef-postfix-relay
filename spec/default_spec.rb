require 'spec_helper'

describe 'postfix-relay::default' do

  let (:chef_run) do
    ChefSpec::SoloRunner.new do | node |
      node.normal['postfix_relay']['email_domain']     = 'mysite.com'
      node.normal['postfix_relay']['allow_live_email']                  = false
    end.converge(described_recipe)
  end
  
  it "creates /etc/postfix in case it is required before the package is installed" do#
    expect(chef_run).to create_directory("/etc/postfix").with({
      :owner  => "root",
      :group  => "root",
      :mode   => 0755
    })
  end 
  
  it "installs local user aliases" do
    expect(chef_run).to include_recipe "postfix-relay::alias_local_users"
  end
  
  it "installs sender aliases" do
    expect(chef_run).to include_recipe "postfix-relay::alias_senders"
  end
  
  it "installs postfix as a dump or relay" do
    expect(chef_run).to include_recipe "postfix-relay::install_postfix"
  end
  
  it "configures postfix to only listen on the loopback interface" do
    expect(chef_run.node['postfix']['main']['inet_interfaces']).to eq('loopback-only')
  end

end
