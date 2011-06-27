require 'rubygems'
require 'rest_client'
require 'nokogiri'

require 'pp'

$user = 'mihail'
$pass = 'Qwerty11'
$root = 'https://stage.rest.click2mail.com/v1'
$resource = RestClient::Resource.new $root, $user, $pass

def url path
  "https://#{$user}:#{$pass}@#{$root}/#{path}"
end

address_list = '<addressList><address><name>Joe Smith</name><address1>123 Main St.</address1><city>Anytown</city><state>VA</state><postalCode>11105</postalCode></address></addressList>'

def create_address data
  p 'create_address'
  address_list = <<EOF
  <addressList>
    <address>
      <name>#{data[:name]}</name>
      <address1>#{data[:address1]}</address1>
      <city>#{data[:city]}</city>
      <state>#{data[:state]}</state>
      <postalCode>#{data[:postalCode]}</postalCode>
    </address>
  </addressList>
EOF

  response = $resource['addressLists'].post address_list,
    :content_type => :xml

  p response.code # should be 201
  id_list = Nokogiri::XML(response).css('addressList id').collect { |id| id.content }
  id_list[0]
end

def create_builder
  p 'create_builder'
  response = $resource['mailingBuilders'].post ''

  p response.code
  id_list = Nokogiri::XML(response).css('mailingBuilderPresenter id').collect { |id| id.content }
  id_list[0]
end

def select_letter builder_id
  p 'select_letter', builder_id

  response = $resource["mailingBuilders/#{builder_id}"].put :sku => 'LT43',
    :content_type => "Content-Type: application/x-www-form-urlencoded"
  p response.code
end

def upload_document filename
  p 'upload_document', filename
  response = $resource["documents/#{filename}"].put File.read("#{filename}.pdf")
  p response.code
end

def attach_document builder_id, filename
  p 'attach_document', builder_id, filename
  response = $resource["mailingBuilders/#{builder_id}/document"].put :uri => "urn:document:#{$user}:#{filename}",
    :content_type => "application/x-www-form-urlencoded"

  p response.code
end

def attach_address builder_id, address_id
  p 'attach_address', builder_id, address_id
  p url("mailingBuilders/#{builder_id}/addressList")
  response = $resource["mailingBuilders/#{builder_id}/addressList"].put "id=#{address_id}",
    :content_type => 'application/x-www-form-urlencoded'
  p response.code
end

def address_ready? address_id
  p 'address_ready?', address_id
  response = $resource["addressLists/#{address_id}"].get
  p response.code
  prop_list = Nokogiri::XML(response).css("addressList ready").collect { |i| i.content }
  ready = prop_list[0]
  p ready
  ready == 'true'
end

def submit_letter builder_id
  p 'submit_letter', builder_id
  response = $resource["mailingBuilders/#{builder_id}/build"].post ''
  p response.code
end

def send_mail address, filename
  begin
    address_id = create_address address
    builder_id = create_builder
    select_letter builder_id
    upload_document filename
    attach_document builder_id, filename

    while true do
      p 'Polling the address resource'
      if address_ready? address_id then
        attach_address builder_id, address_id
        return submit_letter builder_id
      else
        sleep(10)
      end
    end

  rescue RestClient::Exception => e
    p e
  end
end


address = {
  :name => 'Joe Smith',
  :address1 => '123 Main St.',
  :city => 'Anytown',
  :state => 'VA',
  :postalCode => 11105
}
filename = 'sample'

send_mail address, filename

