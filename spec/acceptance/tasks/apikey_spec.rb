require 'spec_helper_acceptance'
require 'json'

describe 'API Key task' do
  before(:each) do
    params = {
      'credentials_file' => credentials,
    }
    ENV['PARAMS'] = JSON.generate(params)
  end

  let(:result) do
    puts "Executing apikey.rb task with `#{ENV['PARAMS']}`" if debug_output?
    Open3.capture2e('bundle exec ruby -Ilib tasks/apikey.rb')
  end
  let(:stdout_str) { result[0] }
  let(:status) { result[1] }

  context 'when apikey task is called with valid credentials' do
    let(:credentials) { "file://#{Dir.getwd}/spec/fixtures/acceptance-credentials.conf" }

    it 'will return an API key' do
      expect(stdout_str).to match %r{"apikey":}
      puts stdout_str if debug_output?
      expect(status.exitstatus).to eq 0
    end
  end
  context 'when apikey task is called with invalid credential_file parameter specified' do
    let(:credentials) { 'foo' }

    it 'will throw an error and not return an API key' do
      expect(stdout_str).not_to match %r{"apikey":}
      expect(stdout_str).to match %r{Unexpected url 'foo' found. Only file:/// URLs for configuration supported at the moment}
      puts stdout_str if debug_output?
      expect(status.exitstatus).not_to eq 0
    end
  end
end
