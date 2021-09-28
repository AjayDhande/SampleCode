require 'identity_provider'

# Define actions for handling user sessions.
class SessionsController < ApplicationController
  skip_before_action :authenticate_user
  before_action :set_secrets, only: %i[create destroy]

  # GET /
  # Redirect the user depending on if they are signed in or not.
  def new
    redirect_to(signed_in? ? home_path : idp_sign_in_path)
  end

  # GET /auth/callback
  # Create a session with the user information provided by IdP.
  def create
    tokens = IdentityProvider::Tokens.new(code: params['code'])
                                     .retrieve_tokens
    if tokens[:access_token].present?
      ith_user_info =
        IdentityProvider::Authentication.new(tokens[:access_token])
                                        .retrieve_ith_user_info
    end
    if ith_user_info.present?
      sign_in(ith_user_info, tokens)
      redirect_back_or(home_path)
    else
      session[:id_token] = tokens[:id_token]
      redirect_to session_unauthorized_path
    end
  end

  # DELETE /sign_out
  # End the current session.
  def destroy
    id_token = session[:id_token]
    if id_token.present?
      redirect_to "#{@secrets.is4_domain}/connect/endsession?"\
                  "id_token_hint=#{id_token}&post_logout_redirect_uri="\
                  "#{@secrets.is4_post_logout_redirect_uri}"
    else
      redirect_to root_path
    end
    sign_out
  end

  # GET /unauthorized
  # Tell the user their request was not authorized.
  def unauthorized; end

  private

  # Set secrets variable.
  def set_secrets
    @secrets = Rails.application.secrets
  end
end