require 'open-uri'
require 'net/http'
require 'base64'
require 'json'

class Lakebtc
  TIMEOUT = 30
  URL = "https://www.lakebtc.com/api_v1"
  ACCESSKEY = "test@example.com"
  SECRETKEY = "243141afd21qsdfsfasfds2412431234"
     
  def get_balances
    conn('getAccountInfo')
  end
  
  def get_orders
    conn('getOrders')
  end
  
  def buy_order(price, amount, currency)
    conn('buyOrder', [price, amount, currency])
  end
  
  def conn(m, myparams = [])
    t_time = Time.now
    tonce = (t_time.to_f * 1e6).to_i.to_s
    
    uri = URI.parse URL

    postdata = {"method" => m, "params" => myparams, "id" => 1}
    
    ps = ["tonce=#{tonce}"]
    ps << "accesskey=#{ACCESSKEY}"
    ps << "requestmethod=post"
    ps << "id=1"
    ps << "method=#{m}"
    ps << "params=#{myparams.join(',')}"
    
    pstring = ps.join('&')


    digest = OpenSSL::Digest::Digest.new('sha1')
    hash = OpenSSL::HMAC.hexdigest(digest, SECRETKEY, pstring)

    pair = "#{ACCESSKEY}:#{hash}"
    b64 = "Basic " + Base64.strict_encode64(pair)

    if URL =~ /^https/ 
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    else
      http = Net::HTTP.new(uri.host, uri.port)
    end

    http.open_timeout = TIMEOUT
    http.read_timeout = TIMEOUT

#    http.set_debug_output($stdout)

    headers = {
      "Content-type" => "application/json-rpc",
      "Authorization" => b64,
      "Json-Rpc-Tonce" => tonce,
      "User-Agent" => 'LakeBTC Ruby Bot',
      "Connection" => ''
    }
    
    response = http.post(uri.path, postdata.to_json, headers) 
    
    JSON.parse response.body
  end
end