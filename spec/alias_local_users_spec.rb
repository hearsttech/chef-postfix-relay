require 'spec_helper'

describe 'postfix-relay::alias_local_users' do

  let (:chef_run) do
    ChefSpec::SoloRunner.new do | node |
      node.normal['postfix_relay']['local_user_alias'] = local_user_alias
      node.normal['postfix_relay']['email_domain']     = 'mysite.com'
      node.normal['etc']['passwd'] = {
        'user1' => {},
        'user2' => {},
      }
    end.converge(described_recipe)
  end

  context "when local_user_alias set to nil" do
    let (:local_user_alias) { nil }

    it "does not set the postfix virtual_alias_maps attribute" do
      expect(chef_run.node['postfix']['main']).not_to have_key('virtual_alias_maps')
    end

    it "does not create an /etc/postfix/virtual file" do
      chef_run.should_not create_template('/etc/postfix/virtual')
    end
  end

  context "when local_user_alias is set" do
    let (:local_user_alias) { 'alerts+:user@mycompany.com' }

    it "sets the postfix virtual_alias_maps attribute" do
      expect(chef_run.node['postfix']['main']['virtual_alias_maps']).to eq('hash:/etc/postfix/virtual')
    end

    it "creates an /etc/postfix/virtual file" do
      chef_run.should create_template('/etc/postfix/virtual').with({
        :owner => "root",
        :group => "root",
        :mode  => 0644
      })
    end

    it "runs postmap to update when the virtual alias file changes" do
      chef_run.should_not run_execute('update_postfix_virtual_aliases').with({
        :command => "postmap /etc/postfix/virtual",
        :user    => "root"
      })
      expect(chef_run.template('/etc/postfix/virtual')).to notify('execute[update_postfix_virtual_aliases]').to(:run)
    end

    it "reloads postfix once postmap has completed" do
      expect(chef_run.execute('update_postfix_virtual_aliases')).to notify('service[postfix]').to(:reload)
    end

    context "when local_user_alias includes a :user placeholder" do
      let (:local_user_alias) { 'alerts+:user@mycompany.com' }

      it "uses local_user_alias as a template to map each local user in /etc/postfix/virtual" do
        chef_run.should render_file('/etc/postfix/virtual').with_content(
          /user1@mysite\.com\s+alerts\+user1@mycompany\.com$\s+user2@mysite.com\s+alerts\+user2@mycompany\.com$/m
        )
      end
    end

    context "when local_user_alias does not include a :user placeholder" do
      let (:local_user_alias) { 'alerts_from_servers@mycompany.com' }

      it "maps each local user to local_user_alias in /etc/postfix/virtual" do
        chef_run.should render_file('/etc/postfix/virtual').with_content(
          /user1@mysite\.com\s+alerts_from_servers@mycompany\.com$\s+user2@mysite.com\s+alerts_from_servers@mycompany\.com$/m
        )
      end
    end

  end

end
