class AuthnResponseController < SamlController
  protect_from_forgery except: :idp_response

  SIGNING_IN_STATE = 'SIGN_IN_WITH_IDP'.freeze
  REGISTERING_STATE = 'REGISTER_WITH_IDP'.freeze

  def idp_response
    if params['RelayState'] != cookies[CookieNames::SESSION_ID_COOKIE_NAME]
      raise Errors::WarningLevelError, "Relay state should match session id. Relay state was #{params['RelayState'].inspect}"
    end

    response = SESSION_PROXY.idp_authn_response(session, cookies, params['SAMLResponse'], params['RelayState'])
    user_state = response.is_registration ? REGISTERING_STATE : SIGNING_IN_STATE

    case response.idp_result
    when 'SUCCESS'
      report_to_analytics("Success - #{user_state}")
      redirect_to response.is_registration ? confirmation_path : response_processing_path
    when 'CANCEL'
      report_to_analytics("Cancel - #{user_state}")
      redirect_to response.is_registration ? failed_registration_path : start_path
    else
      report_to_analytics("Failure - #{user_state}")
      redirect_to response.is_registration ? failed_registration_path : failed_sign_in_path
    end
  end
end
