require 'spec_helper'

describe 'postfix-relay::install_remote_relay' do

  let (:chef_run) do
    ChefSpec::Runner.new do | node |
      node.set['postfix_relay']['email_domain']     = 'mysite.com'
      node.set['postfix_relay']['live_email']['relayhost']           = 'smtp.mydomain.com'
      node.set['postfix_relay']['live_email']['smtp_sasl_user_name'] = 'me@mydomain.com'
      node.set['postfix_relay']['live_email']['smtp_sasl_passwd']    = 'password'
    end.converge(described_recipe)
  end

  it "sets the postfix hostname to the email_domain" do
    chef_run.should render_file('/etc/postfix/main.cf').with_content(
      /^myhostname = mysite.com/m
    )
  end
  
  it "does not include the email_domain in the postfix mydestination config" do
    # chefspec is the hostname from Fauxhai
    chef_run.should render_file('/etc/postfix/main.cf').with_content(
      /^mydestination = chefspec, localhost.localdomain, localhost$/m
    )    
  end

  it "installs postfix with postfix::default" do
    chef_run.should include_recipe("postfix::default")
  end

  it "does not include the fs_mail transport in master.cf" do
    chef_run.should render_file('/etc/postfix/master.cf').with_content(
      /^(?!.*fs_mail)/m
    )
  end

  it "sets the postfix relay configuration to use the configured remote host with credentials" do
    expect(chef_run.node['postfix']['main']['relayhost']).to eq('smtp.mydomain.com')
    expect(chef_run.node['postfix']['sasl']['smtp_sasl_user_name']).to eq('me@mydomain.com')
    expect(chef_run.node['postfix']['sasl']['smtp_sasl_passwd']).to eq('password')
  end

end