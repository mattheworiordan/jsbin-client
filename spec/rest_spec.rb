require 'spec_helper'
require 'ostruct'

describe 'JsBinClient::Rest' do
  let(:bin_id) { 'exampleID' }
  let(:options) { OpenStruct.new({ host: 'host', port: 8080, ssl: false, api_key: '3' }) }
  let(:url) { "http://host:8080/api/#{bin_id}" }
  subject { JsBinClient::Rest.new(options)}

  context 'should use the options' do
    before { stub_request(:get, url).to_return(status: 200, body: '{"response":"valid"}') }
    after { a_request(:get, url).with(:headers => {'authorization' => 'token 3'}).should have_been_made.once }

    specify do
      subject.get(bin_id)['response'].should == 'valid'
    end

    it 'over SSL' do
      options.ssl = true
      subject.get(bin_id)['response'].should == 'valid'
    end

    it 'and return indifferent JSON' do
      subject.get(bin_id)[:response].should == 'valid'
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