require 'spec_helper'

describe 'postfix-relay::install_local_dump' do

  let (:chef_run) do
    ChefSpec::SoloRunner.new do | node |
      node.normal['postfix_relay']['email_domain']     = 'mysite.com'
      node.normal['postfix_relay']['fs_mail']['user']  = 'myuser'
      node.normal['postfix_relay']['fs_mail']['file']  = '/tmp/my_custom_dump'
    end.converge(described_recipe)
  end
  
  it "sets the postfix default transport to fs_mail" do
    expect(chef_run.node['postfix']['main']['default_transport']).to eq('fs_mail')
  end
  
  it "installs postfix with postfix::default" do
    expect(chef_run).to include_recipe("postfix::default")
  end
  
  it "triggers postfix::default to generate the custom master.cf" do
    expect(chef_run.node['postfix']['master_template_source']).to eq('postfix-relay')
  end
  
  it "includes the fs_mail transport in master.cf" do
    expect(chef_run).to render_file('/etc/postfix/master.cf').with_content(
      /^fs_mail\s+unix\s+-\s+n\s+n\s+-\s+-\s+pipe$\s+flags=FB/m
    )
  end
  
  it "sets the fs_mail dump file to the configured location" do
    expect(chef_run).to render_file('/etc/postfix/master.cf').with_content(
      /^fs_mail.+?$\s+.+?argv=tee -a \/tmp\/my_custom_dump/
    )    
  end
  
  it "sets the fs_mail user to the configured user" do
    expect(chef_run).to render_file('/etc/postfix/master.cf').with_content(
      /^fs_mail.+?$\s+.+?user=myuser /
    )    
  end
  
  it "sets the postfix relay configuration to use localhost" do
    expect(chef_run.node['postfix']['main']['relayhost']).to eq('localhost')
    expect(chef_run.node['postfix']['sasl']['smtp_sasl_passwd']).to eq('localhost')
    expect(chef_run.node['postfix']['sasl']['smtp_sasl_user_name']).to eq('localhost')
  end

end
