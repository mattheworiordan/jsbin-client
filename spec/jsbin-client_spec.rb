require 'spec_helper'

describe JsBinClient::Config do
  subject { JsBinClient::Config }

  its(:host) { should == 'jsbin.com' }
  its(:port) { should == 80 }
  its(:ssl) { should be_false }

  context 'when using ssl' do
    before { JsBinClient::Config.stub(:ssl) { true } }
    after { JsBinClient::Config.rspec_reset }

    its(:port) { should == 443 }
  end
end

describe JsBinClient do
  context 'when initialising with options' do
    subject { JsBinClient.new(host: 'localhost', port: 8080, api_key: 'example' ).options }

    its(:host) { should == 'localhost' }
    its(:port) { should == 8080 }
    its(:ssl) { should be_false }
    its(:api_key) { should == 'example' }
  end
end