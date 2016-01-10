require 'socket'
require 'openssl'

class CertificateFetcher
  # Connect to the +domain+ and return a hash of details about the SSL
  # certificate served by the dmoain.
  def self::fetch_cert_details(domain)
    tcp_client = TCPSocket.new(domain, 443)
    ssl_client = OpenSSL::SSL::SSLSocket.new(tcp_client)
    ssl_client.connect
    cert = OpenSSL::X509::Certificate.new(ssl_client.peer_cert)
    ssl_client.sysclose
    tcp_client.close

    subjectprops = OpenSSL::X509::Name.new(cert.subject).to_a
    issuerprops = OpenSSL::X509::Name.new(cert.issuer).to_a

    {
      content: cert.to_s,
      org: subjectprops.find { |name, _data, _type| name == 'O' }[1],
      domain: subjectprops.find { |name, _data, _type| name == 'CN' }[1],
      issuer: issuerprops.find { |name, _data, _type| name == 'O' }[1],
      expiry: cert.not_after
    }
  end
end
