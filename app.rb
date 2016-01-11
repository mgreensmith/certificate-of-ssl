require 'sinatra'

require 'certificate_fetcher'
require 'document_generator'

get '/' do
  erb :index
end

post '/generate' do
  cert_details = CertificateFetcher.fetch_cert_details(params[:domain])
  halt 422, 'Unable to fetch certificate details from the requested domain.' if cert_details.empty?
  file = DocumentGenerator.new(cert_details).certificate_file
  send_file file, filename: params[:domain].gsub(/\./, '_') + '.pdf', type: 'application/pdf'
end
