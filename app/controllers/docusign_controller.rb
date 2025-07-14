class DocusignController < ApplicationController
  def send_document
    service = DocusignService.new(current_user)
    template_id = params[:template_id] # or fetch from ENV
    response = service.send_template(template_id)
    envelope_id = response.envelope_id
    redirect_to action: :embedded_signing, envelope_id: envelope_id
  end

  def embedded_signing
    service = DocusignService.new(current_user)
    view = service.create_recipient_view(params[:envelope_id])
    redirect_to view.url
  end

  # Optional webhook endpoint
  def webhook
    xml = Hash.from_xml(request.body.read)
    envelope_id = xml.dig("DocuSignEnvelopeInformation", "EnvelopeStatus", "EnvelopeID")
    status = xml.dig("DocuSignEnvelopeInformation", "EnvelopeStatus", "Status")
    # Save status to your DB
    head :ok
  end
end
