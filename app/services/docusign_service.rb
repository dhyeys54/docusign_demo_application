class DocusignService
  def initialize(user)
    @user = user
    @client = DocuSignClient
    authenticate
    @envelopes_api = DocuSign_eSign::EnvelopesApi.new(@client)
  end

  def authenticate
    private_key = File.read(Rails.root.join(ENV["DOCUSIGN_PRIVATE_KEY_PATH"]))
    token = @client.request_jwt_user_token(
      ENV["DOCUSIGN_INTEGRATION_KEY"],
      ENV["DOCUSIGN_USER_ID"],
      private_key,
      3600,
      [ "signature" ]
    )
    @client.default_headers["Authorization"] = "Bearer #{token.access_token}"
  end

  def send_template(template_id)
    envelope_definition = DocuSign_eSign::EnvelopeDefinition.new(
      status: "sent",
      template_id: template_id,
      template_roles: [
        DocuSign_eSign::TemplateRole.new(
          email: @user.email,
          name: @user.name,
          role_name: "signer"
        )
      ],
      email_subject: "Please sign this document"
    )

    @envelopes_api.create_envelope(ENV["DOCUSIGN_ACCOUNT_ID"], envelope_definition)
  end

  def create_recipient_view(envelope_id)
    view_request = DocuSign_eSign::RecipientViewRequest.new(
      authentication_method: "none",
      client_user_id: @user.id.to_s,
      return_url: Rails.application.routes.url_helpers.root_url,
      email: @user.email,
      user_name: @user.name
    )

    @envelopes_api.create_recipient_view(ENV["DOCUSIGN_ACCOUNT_ID"], envelope_id, view_request)
  end
end
