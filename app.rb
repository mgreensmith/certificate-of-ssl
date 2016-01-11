require 'sinatra'

require 'certificate_fetcher'
require 'document_generator'

get '/' do
  erb :index
end

post '/generate' do
  c = CertificateFetcher.fetch_cert_details(params[:domain])
  file = DocumentGenerator.new(
    c[:content],
    c[:org],
    c[:domain],
    c[:issuer],
    c[:expiry]).certificate_file
  send_file file, filename: params[:domain].gsub(/\./, '_') + '.pdf', type: 'application/pdf'
end
