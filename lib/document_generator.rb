require 'prawn'
require 'prawn/measurement_extensions'
require 'ordinalize'

class DocumentGenerator
  FONTS = %w( OldEnglishFive Miama Alpine Scriptina )

  ASSET_DIR = File.expand_path('../../assets', __FILE__)
  OUTPUT_DIR = File.expand_path('../../out', __FILE__)

  def initialize(cert_details)
    @content = cert_details[:content]
    @org = cert_details[:org]
    @domain = cert_details[:domain]
    @issuer = cert_details[:issuer]
    @valid_date = cert_details[:valid_date]
    @expiry_date = cert_details[:expiry_date]

    @pdf = Prawn::Document.new(page_layout: :landscape, margin: 0)
  end

  def certificate_file
    generate_certificate
    file = "#{OUTPUT_DIR}/#{@domain.gsub(/\./, '_')}.pdf"
    @pdf.render_file file
    file
  end

  private

  # Generate a PDF document that is an SSL "certificate" for this instance.
  def generate_certificate
    import_fonts

    @pdf.image "#{ASSET_DIR}/background.png", fit: [11.in, '8.5'.to_f.in]

    @pdf.formatted_text_box [{ text: @content, font: 'Courier' }],
                            at: ['1.75'.to_f.in, 6.in],
                            height: '3.5'.to_f.in,
                            width: '3.25'.to_f.in,
                            overflow: :shrink_to_fit,
                            valign: :center

    @pdf.formatted_text_box [{ text: 'Certificate of SSL', font: 'OldEnglishFive', size: 36 }],
                            at: ['2.85'.to_f.in, 7.in]

    @pdf.image "#{ASSET_DIR}/seal.png", at: ['4.5'.to_f.in, 2.in], width: '1.5'.to_f.in

    @pdf.bounding_box(['5'.to_f.in, '5.9'.to_f.in], width: '4.5'.to_f.in) do
      description_line 'This certificate is hereby issued to'
      value_line @org
      description_line 'for the protection and security of'
      value_line @domain
      description_line "with our full authority and trust,\nuntil the %s day of %s, %s" % [
        value_inline(@expiry_date.day.ordinalize),
        value_inline(@expiry_date.strftime('%B')),
        value_inline(@expiry_date.year)
      ]

      @pdf.move_down '0.4'.to_f.in
      @pdf.font 'Scriptina'
      @pdf.text @issuer, size: 20, align: :center, color: '003366' # nignight blue

      @pdf.font 'Miama'
      @pdf.text 'Issuing Authority', size: 16, align: :center
    end
  end

  def import_fonts
    FONTS.each do |f|
      @pdf.font_families[f] = { normal: { file: "#{ASSET_DIR}/fonts/#{f}.ttf", font: f } }
    end
  end

  def description_line(text)
    @pdf.font 'Miama'
    @pdf.text text, size: 20, align: :center, inline_format: true
  end

  def value_line(text)
    @pdf.move_down '0.1'.to_f.in
    @pdf.font 'Alpine'
    @pdf.text text, size: 22, align: :center
    @pdf.move_down '0.1'.to_f.in
  end

  def value_inline(text)
    "<font name='Alpine' size='14'> #{text} </font>"
  end
end
