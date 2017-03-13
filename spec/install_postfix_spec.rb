require 'spec_helper'

describe 'postfix-relay::install_postfix' do

  let (:chef_run) do
    ChefSpec::SoloRunner.new do | node |
      node.normal['postfix_relay']['email_domain']     = 'mysite.com'
      node.normal['postfix_relay']['live_email']['relayhost']           = 'smtp.mydomain.com'
      node.normal['postfix_relay']['live_email']['smtp_sasl_user_name'] = 'me@mydomain.com'
      node.normal['postfix_relay']['live_email']['smtp_sasl_passwd']    = 'password'
      node.normal['postfix_relay']['allow_live_email']                  = allow_live_email
    end.converge(described_recipe)
  end
  
  context "when allow_live_email is true" do
    let (:allow_live_email) { true }
    
    it "installs postfix as a remote relay" do
      expect(chef_run).to include_recipe("postfix-relay::install_remote_relay")
    end
    
    it "does not install postfix as a local dump" do
      expect(chef_run).not_to include_recipe("postfix-relay::install_local_dump")
    end
    
    it "installs standard postfix aliases" do
      expect(chef_run).to include_recipe("postfix::aliases")
    end
    
    it "installs postfix authenticated smtp handling" do
      expect(chef_run).to include_recipe("postfix::sasl_auth")
    end
  end
  
  context "when allow_live_email is false" do
    let (:allow_live_email) { false }

    it "installs postfix as a local dump" do
      expect(chef_run).to include_recipe("postfix-relay::install_local_dump")
    end
    
    it "does not install postfix as a remote relay" do
      expect(chef_run).not_to include_recipe("postfix-relay::install_remote_relay")
    end
    
    it "installs standard postfix aliases" do
      expect(chef_run).to include_recipe("postfix::aliases")
    end
    
    it "installs postfix authenticated smtp handling" do
      expect(chef_run).to include_recipe("postfix::sasl_auth")
    end
  end

end
