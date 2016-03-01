require 'spec_helper'
require 'models/api_response_handler'
require 'models/api_client'
require 'json'

describe ApiResponseHandler do
  context 'on a successful response' do
    it 'should return a parsed response body on a successful response' do
      expected_result = {'id' => '12'}
      result = ApiResponseHandler.new.handle_response(200, 200, expected_result.to_json)
      expect(result).to eq(expected_result)
    end

    it 'raises an error when API response is OK but JSON is empty' do
      expect {
        ApiResponseHandler.new.handle_response(200, 200, '')
      }.to raise_error ApiClient::Error, 'Received 200, but unable to parse JSON'
    end

    it 'errors on receiving malformed JSON' do
      expect {
        ApiResponseHandler.new.handle_response(200, 200, 'aaa')
      }.to raise_error ApiClient::Error, 'Received 200, but unable to parse JSON'
    end
  end

  context 'on an unsuccessful response' do
    it 'errors when receiving 500 and empty JSON' do
      expect {
        ApiResponseHandler.new.handle_response(500, 200, '')
      }.to raise_error ApiClient::Error, 'Received 500, but unable to parse JSON'
    end

    it 'raises an error when API response is not ok with message' do
      expect {
        ApiResponseHandler.new.handle_response(400, 200, '{"message": "Failure"}')
      }.to raise_error ApiClient::Error, 'Received 400 with error message: \'Failure\' and id: \'NONE\''
    end

    it 'raises an error when API response is not ok with id' do
      expect {
        ApiResponseHandler.new.handle_response(500, 200, '{"id": "1234"}')
      }.to raise_error ApiClient::Error, 'Received 500 with error message: \'NONE\' and id: \'1234\''
    end


    it 'raises an error when API response is not ok with malformed JSON' do
      expect {
        ApiResponseHandler.new.handle_response(500, 200, 'aaa')
      }.to raise_error ApiClient::Error, 'Received 500, but unable to parse JSON'
    end

    it 'raises an error when API response is not ok with JSON, but message missing' do
      expect {
        ApiResponseHandler.new.handle_response(500, 200, '{}')
      }.to raise_error ApiClient::Error, 'Received 500 with error message: \'NONE\' and id: \'NONE\''
    end

    it 'raises a session error' do
      error_body = {id: '0', type: 'SESSION_ERROR'}
      expect {
        ApiResponseHandler.new.handle_response(400, 200, error_body.to_json)
      }.to raise_error ApiClient::SessionError, 'Received 400 with type: \'SESSION_ERROR\' and id: \'0\''
    end

    it 'raises a session timeout error' do
      error_body = {id: '0', type: 'SESSION_TIMEOUT'}
      expect {
        ApiResponseHandler.new.handle_response(400, 200, error_body.to_json)
      }.to raise_error ApiClient::SessionTimeoutError, 'Received 400 with type: \'SESSION_TIMEOUT\' and id: \'0\''
    end
  end
end