require 'rubygems'
require 'sinatra'
require 'pp'

require 'haml'

require 'base64'
require 'soap/wsdlDriver'

def send_mail()
  api = 'https://www.cfhdocmail.com/Test_SimpleAPI/DocMail.SimpleAPI.asmx?wsdl'
  driver = SOAP::WSDLDriverFactory.new(api).create_rpc_driver

  file = 'sample.pdf'
  contents = open(file, 'rb') do |f| f.read end

  mailing_name = 'test'
  username = 'mihail'
  password = '123456'
  address = 'sample address, 11'

  first_name = 'test'
  last_name = 'test'

  resp = driver.sendLetterToSingleAddress(
    'sUsr' => username,
    'sPwd' => password,
    'sMailingName' => mailing_name,
    'bColour' => true,
    'bDuplex' => true,
    'eDeliveryType' => 'StandardClass',
    'sTemplateFileName' => File.basename(file),
    'eAddressNameFormat' => 'FullName',

    'bTemplateData' => contents,
    'sFirstName' => first_name, 
    'sLastName'  => last_name,  
    'sAddress1' => address,
    'bProofApprovalRequired' => 'false'
  )
  resp
end

get '/' do
  resp = send_mail
  @result = resp.sendLetterToSingleAddressResult

  haml :response
end
