require 'spec_helper'

describe 'postfix-relay::install_remote_relay' do
  let (:conf_dir) { '/etc/postfix' }
  let (:chef_run) do
    ChefSpec::SoloRunner.new do | node |
      node.normal['postfix_relay']['email_domain']                      = 'mysite.com'
      node.normal['postfix_relay']['live_email']['relayhost']           = 'smtp.mydomain.com'
      node.normal['postfix_relay']['live_email']['smtp_sasl_user_name'] = 'me@mydomain.com'
      node.normal['postfix_relay']['live_email']['smtp_sasl_passwd']    = 'password'
      node.normal['postfix']['conf_dir']                                = conf_dir
    end.converge(described_recipe)
  end

  it "sets the postfix hostname to the email_domain" do
    chef_run.should render_file('/etc/postfix/main.cf').with_content(
      /^myhostname = mysite.com/m
    )
  end
  
  it "does not include the email_domain in the postfix mydestination config" do
    # Fauxhai is the hostname from Fauxhai
    chef_run.should render_file('/etc/postfix/main.cf').with_content(
      /^mydestination = Fauxhai, localhost.localdomain, localhost$/m
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
  
  it "defaults to using postfix-relay TLS configuration for postfix attributes" do
    # This is here because postfix cookbook changes broke our attribute overrides so we need to verify they get set
    # The attributes are defined in attributes/postfix.rb
    expect(chef_run.node['postfix']['main']['smtp_sasl_auth_enable']).to eq('yes')
    expect(chef_run.node['postfix']['main']['smtp_use_tls']).to eq('yes')
    expect(chef_run.node['postfix']['main']['smtp_tls_security_level']).to eq('encrypt')
    expect(chef_run.node['postfix']['main']['smtp_tls_note_starttls_offer']).to eq('yes')
    expect(chef_run.node['postfix']['main']['smtp_tls_CAfile']).to eq('/etc/ssl/certs/ca-certificates.crt')
    expect(chef_run.node['postfix']['sasl_password_file']).to eq("#{conf_dir}/sasl_passwd")
    expect(chef_run.node['postfix']['main']['smtp_sasl_password_maps']).to eq("hash:#{conf_dir}/sasl_passwd")
    expect(chef_run.node['postfix']['main']['smtp_sasl_security_options']).to eq('noanonymous')
    expect(chef_run.node['postfix']['main']['smtp_sasl_mechanism_filter']).to eq('login')
  end

end
