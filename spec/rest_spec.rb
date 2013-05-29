require 'spec_helper'
require 'ostruct'

describe 'JsBinClient::Rest' do
  let(:bin_id) { 'exampleID' }
  let(:options) { OpenStruct.new({ host: 'host', port: 8080, ssl: false, api_key: '3' }) }
  let(:url) { "http://host:8080/api/#{bin_id}" }
  subject { JsBinClient::Rest.new(options)}

  context 'should use the options' do
    before { stub_request(:get, url).to_return(status: 200, body: '{"response":"valid"}') }

    specify do
      subject.get(bin_id)['response'].should == 'valid'
      a_request(:get, url).with(:headers => {'authorization' => 'token 3'}).should have_been_made.once
    end

    context 'over SSL' do
      before { stub_request(:get, url).to_return(status: 200, body: '{"response":"valid"}') }
      let(:options) { OpenStruct.new({ host: 'host', port: 443, ssl: true, api_key: '5' }) }
      let(:url) { "https://host:443/api/#{bin_id}" }

      specify do
        subject.get(bin_id)['response'].should == 'valid'
        a_request(:get, url).with(:headers => {'authorization' => 'token 5'}).should have_been_made.once
      end
    end

    it 'and return indifferent JSON' do
      subject.get(bin_id)[:response].should == 'valid'
      a_request(:get, url).with(:headers => {'authorization' => 'token 3'}).should have_been_made.once
    end
  end

  context 'should support all HTTP verbs' do
    let(:methods) { %w(get post put) }
    before do
      methods.each { |method| stub_request(method.to_sym, url).to_return(status: 200, body: "{\"method\":\"#{method}\"}") }
    end

    specify do
      methods.each do |method|
        subject.send(method.to_sym, bin_id)['method'].should == method
      end
    end
  end

  context 'should catch invalid JSON response' do
    before { stub_request(:get, url).to_return(status: 200, body: 'this is not JSON') }
    specify do
      expect { subject.get(bin_id) }.to raise_exception(JsBinClient::InvalidJson)
    end
  end

  context 'should catch a JSBin' do
    specify '404 error' do
      stub_request(:get, url).to_return(status: 404, body: '{"error":"message"}')
      expect { subject.get(bin_id) }.to raise_exception(JsBinClient::BinMissing)
    end

    specify 'ownership 403 error' do
      stub_request(:get, url).to_return(status: 403, body: '{"error":"You are not the owner"}')
      expect { subject.get(bin_id) }.to raise_exception(JsBinClient::OwnershipError, 'You are not the owner')
    end

    specify 'permission 403 error' do
      stub_request(:get, url).to_return(status: 403, body: '{"error":"The API key you provided is not valid"}')
      expect { subject.get(bin_id) }.to raise_exception(JsBinClient::AuthenticationRequired, 'The API key you provided is not valid')
    end
  end
end