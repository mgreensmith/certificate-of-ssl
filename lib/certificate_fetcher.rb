require 'httpclient'

class CertificateFetcher
  # Connect to the +domain+ and return a hash of details about the SSL
  # certificate served by the domain.
  def self::fetch_cert_details(domain)
    https_url = 'https://' + domain.gsub(/^https?:\/\//, '')
    client = HTTPClient.new
    client.connect_timeout = 2
    client.receive_timeout = 2

    cert = OpenSSL::X509::Certificate.new(client.head(https_url).peer_cert)

    subjectprops = OpenSSL::X509::Name.new(cert.subject).to_a
    issuerprops = OpenSSL::X509::Name.new(cert.issuer).to_a

    {
      content: cert.to_s,
      org: subjectprops.find { |name, _, _| name == 'O' }[1],
      domain: subjectprops.find { |name, _, _| name == 'CN' }[1],
      issuer: issuerprops.find { |name, _, _| name == 'O' }[1],
      valid_date: cert.not_before,
      expiry_date: cert.not_after
    }

  rescue
    return {}
  end
end
