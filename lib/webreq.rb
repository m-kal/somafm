# require_relative "./somafm/engine"

require 'net/http'

class WebReq
  @responses
  def initialize()
    @responses = []
  end

  def get(url)
    content = Net::HTTP.get_response(URI(url))
    @responses << content
    puts url << "[#{content['Content-Length']}]"
    return content.body
  end

  def bandwidth()
    bw = 0
    @responses.each do |b|
      bw += b['Content-Length'].to_i
    end

    return bw
  end
end