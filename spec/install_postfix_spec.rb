require 'spec_helper'

describe 'postfix-relay::install_postfix' do

  let (:chef_run) do
    ChefSpec::Runner.new do | node |
      node.set['postfix_relay']['email_domain']     = 'mysite.com'
      node.set['postfix_relay']['live_email']['relayhost']           = 'smtp.mydomain.com'
      node.set['postfix_relay']['live_email']['smtp_sasl_user_name'] = 'me@mydomain.com'
      node.set['postfix_relay']['live_email']['smtp_sasl_passwd']    = 'password'
      node.set['postfix_relay']['allow_live_email']                  = allow_live_email
    end.converge(described_recipe)
  end
  
  context "when allow_live_email is true" do
    let (:allow_live_email) { true }
    
    it "installs postfix as a remote relay" do
      chef_run.should include_recipe("postfix-relay::install_remote_relay")
    end
    
    it "does not install postfix as a local dump" do
      chef_run.should_not include_recipe("postfix-relay::install_local_dump")
    end
    
    it "installs standard postfix aliases" do
      chef_run.should include_recipe("postfix::aliases")
    end
    
    it "installs postfix authenticated smtp handling" do
      chef_run.should include_recipe("postfix::sasl_auth")
    end
  end
  
  context "when allow_live_email is false" do
    let (:allow_live_email) { false }

    it "installs postfix as a local dump" do
      chef_run.should include_recipe("postfix-relay::install_local_dump")
    end
    
    it "does not install postfix as a remote relay" do
      chef_run.should_not include_recipe("postfix-relay::install_remote_relay")
    end
    
    it "installs standard postfix aliases" do
      chef_run.should include_recipe("postfix::aliases")
    end
    
    it "installs postfix authenticated smtp handling" do
      chef_run.should include_recipe("postfix::sasl_auth")
    end
  end

end