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
  def json_response(url, revision, options = {})
    %{
      {
        "id": 1,
        "html": "#{options[:html] || '<html></html>'}",
        "css": "#{options[:css] || 'body { color: red }'}",
        "javascript": "#{options[:javascript] || 'console.log(\'loaded\');'}",
        "created": "2013-05-23T15:50:19.850Z",
        "last_viewed": "2013-05-23T15:50:19.800Z",
        "url": "#{url}",
        "active": true,
        "reported": null,
        "streaming": "n",
        "streaming_key": "479be77ce3819c266b00bcddb97795e8",
        "streaming_read_key": "479be77ce3819c266b00bcddb97795e8",
        "active_tab": null,
        "active_cursor": null,
        "revision": #{revision},
        "settings": {
          "processors": {}
        },
        "last_updated": "2012-07-23T00:00:00.000Z"
      }
    }
  end

  context 'when initialising with options' do
    subject { JsBinClient.new(host: 'localhost', port: 8080, api_key: 'example' ).options }

    its(:host) { should == 'localhost' }
    its(:port) { should == 8080 }
    its(:ssl) { should be_false }
    its(:api_key) { should == 'example' }
  end

  context 'retrieving a bin' do
    subject { JsBinClient.new(host: 'localhost', port: 8080) }
    let(:stub_path) { "http://localhost:8080/#{JsBinClient::API_PREFIX}" }

    it 'should throw an exception if missing' do
      stub_request(:get, "#{stub_path}invalid").to_return(status: 404, body: '{"error":"message"}')
      expect { subject.get('invalid') }.to raise_exception JsBinClient::BinMissing
    end

    it 'should return valid data' do
      url_id = '1234'
      stub_request(:get, "#{stub_path}#{url_id}").to_return(status: 200, body: json_response(url_id, 1))
      response = subject.get(url_id)

      response[:javascript].should match(/console\.log/)
      response[:css].should match(/red/)
      response[:html].should match(/html/)
      response[:id].should == 1
      response[:url].should == url_id
    end
  end

  context 'creating a bin' do
    subject { JsBinClient.new(host: 'localhost', port: 8080) }
    let(:stub_path) { "http://localhost:8080/#{JsBinClient::API_PREFIX}" }
    let(:new_id) { '1234' }
    let(:bin_params) { { html: 'html1', javascript: 'javascript1', css: 'css1' } }

    specify do
      stub_request(:post, "#{stub_path}save").to_return(status: 200, body: json_response(new_id, 1, bin_params))
      response = subject.create(bin_params)

      [:javascript, :css, :html].each { |p| response[p].should == bin_params[p] }
      response[:url].should == new_id

      a_request(:post, "#{stub_path}save").with(:body => bin_params).should have_been_made.once
    end
  end

  context 'create a revision for a bin' do
    subject { JsBinClient.new(host: 'localhost', port: 8080) }
    let(:stub_path) { "http://localhost:8080/#{JsBinClient::API_PREFIX}" }
    let(:url_id) { '1234' }
    let(:bin_params) { { html: 'html1', javascript: 'javascript1', css: 'css1' } }

    specify do
      stub_request(:post, "#{stub_path}#{url_id}/save").to_return(status: 200, body: json_response(url_id, 1, bin_params))
      response = subject.create_revision(url_id, bin_params)

      [:javascript, :css, :html].each { |p| response[p].should == bin_params[p] }
      response[:url].should == url_id

      a_request(:post, "#{stub_path}#{url_id}/save").with(:body => bin_params).should have_been_made.once
    end
  end

  context '#url_for' do
    subject { JsBinClient.new(host: 'localhost', port: 8080) }
    let(:url_path) { "http://localhost:8080/" }
    let(:url_id) { 'asdsad' }

    it 'should return edit URL without revision by default' do
      subject.url_for(url_id).should == "#{url_path}#{url_id}/latest/edit"
    end

    it 'should return edit URL with revision by default' do
      subject.url_for(url_id, revision: 3).should == "#{url_path}#{url_id}/3/edit"
    end

    it 'should return preview URL without revision' do
      subject.url_for(url_id, preview: true).should == "#{url_path}#{url_id}/latest"
    end

    it 'should return preview URL with revision' do
      subject.url_for(url_id, preview: true, revision: 3).should == "#{url_path}#{url_id}/3"
    end

    it 'should return edit URL with panels with revision' do
      subject.url_for(url_id, revision: 3, panels: 'javascript,html').should == "#{url_path}#{url_id}/3/edit#javascript,html"
    end

    it 'should return edit URL with panels from array' do
      subject.url_for(url_id, panels: %w(javascript html)).should == "#{url_path}#{url_id}/latest/edit#javascript,html"
    end

    it 'should return embeddable URL with revision with panels' do
      subject.url_for(url_id, embed: true, revision: 3, panels: %w(javascript live)).should == "#{url_path}#{url_id}/3/embed?javascript,live"
    end

    it 'should return embeddable URL' do
      subject.url_for(url_id, embed: true).should == "#{url_path}#{url_id}/latest/embed"
    end

    it 'should support SSL' do
      client = JsBinClient.new(host: 'jsbin.com', port: 443, ssl: true)
      client.url_for(url_id, preview: true).should == "https://jsbin.com:443/#{url_id}/latest"
    end
  end
end
