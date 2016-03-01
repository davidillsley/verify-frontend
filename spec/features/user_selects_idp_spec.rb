require 'feature_helper'

RSpec.describe 'user selects an IDP on the sign in page' do
  context 'with JS enabled', js: true do
    it 'will redirect the user to the IDP' do
      body = [{'simpleId' => 'stub-idp-one', 'entityId' => 'http://idcorp.com'}]
      stub_request(:get, api_uri('session/idps')).to_return(body: body.to_json)
      stub_request(:put, api_uri('session/select-idp')).to_return(status: 200)
      stub_request(:get, api_uri('session/idp-authn-request')).to_return(status: 200)
      set_session_cookies
      visit '/sign-in'
      click_button('IDCorp')
      expect(a_request(:put, api_uri('session/select-idp'))).to have_been_made.once
      expect(a_request(:get, api_uri('session/idp-authn-request'))).to have_been_made.once
      expect(page).to have_current_path('http://idcorp.com')
    end
  end

  context 'with JS disabled' do
    it 'will display the interstitial page'
  end
end