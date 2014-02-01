require 'spec_helper'

describe 'postfix-relay::alias_senders' do

  context "with no outbound_address_replacements configured" do
    let (:chef_run) do
      ChefSpec::Runner.new do | node |
        node.set['postfix_relay']['outbound_address_replacements'] = {}
      end.converge(described_recipe)
    end

    it "does not set the postfix sender_canonical_maps attribute" do
      expect(chef_run.node['postfix']['main']).not_to have_key('sender_canonical_maps')
    end

    it "does not create a sender_canonical file" do
      chef_run.should_not create_template('/etc/postfix/sender_canonical')
    end
  end

  context "with outbound_address_replacements configured" do
    let (:chef_run) do
      ChefSpec::Runner.new do | node |
        node.set['postfix_relay']['outbound_address_replacements'] = {
          '/^chef-client@[^.]+.*$/' => 'chef.${1}@ingenerator.com',
          '/^other-email$/'         => nil,
        }
      end.converge(described_recipe)
    end

    it "sets the postfix sender_canonical_maps attribute" do
      expect(chef_run.node['postfix']['main']['sender_canonical_maps']).to eq('regexp:/etc/postfix/sender_canonical_maps')
    end

    it "creates the sender_canoninical_maps_file" do
      chef_run.should create_template('/etc/postfix/sender_canonical_maps').with(
        :owner => "root",
        :group => "root",
        :mode  => 0644
      )
    end

    it "includes each configured regex replacement in the map" do
      chef_run.should render_file('/etc/postfix/sender_canonical_maps').with_content(
        Regexp.new(Regexp.escape('/^chef-client@[^.]+.*$/')+'\s+'+Regexp.escape('chef.${1}@ingenerator.com'))
      )
    end

    it "does not include patterns where replacement is set to nil" do
      chef_run.should render_file('/etc/postfix/sender_canonical_maps').with_content(
        /^(?!.*other-email)/m
      )
    end

    it "notifies postfix to reload when the map changes" do
      expect(chef_run.template('/etc/postfix/sender_canonical_maps')).to notify('service[postfix]').to(:reload)
    end
  end

end