require 'spec_helper'
require 'further_information_service'
require 'session_proxy'

RSpec.describe FurtherInformationService do
  let(:display_data_repo) { double(:display_data_repo) }
  let(:cookies) { double(:cookies) }
  let(:session_proxy) { instance_double('SessionProxy') }
  let(:service) { FurtherInformationService.new(session_proxy, display_data_repo) }
  let(:session) { double(:session) }

  it 'should fetch cycle 3 display data' do
    attribute_key = 'AnAttributeKey'
    expected_display_data = double(:expected_display_data)
    expect(session_proxy).to receive(:cycle_three_attribute_name).with(session, cookies).and_return(attribute_key)
    expect(display_data_repo).to receive(:fetch).with(attribute_key).and_return(expected_display_data)
    expect(service.get_attribute_for_session(session, cookies)).to eql(expected_display_data)
  end

  it 'should submit cycle 3 attribute value' do
    expect(session_proxy).to receive(:submit_cycle_three_value).with(session, cookies, 'value')
    service.submit(session, cookies, 'value')
  end

  it 'should submit cycle 3 cancel' do
    expect(session_proxy).to receive(:cycle_three_cancel).with(session, cookies)
    service.cancel(session, cookies)
  end
end
