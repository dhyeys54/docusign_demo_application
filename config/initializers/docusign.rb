require "docusign_esign"
DocuSignClient = DocuSign_eSign::ApiClient.new
DocuSignClient.set_oauth_base_path(ENV["DOCUSIGN_AUTH_SERVER"])
