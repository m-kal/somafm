require "./lib/somafm/engine"

require 'thor'
require 'net/http'
require 'open-uri'
require 'Nokogiri'

class Sfm
  # Your code goes here...
  def initialize
    #
  end

  def build_song_history_url(station)
    "http://somafm.com/#{station}/songhistory.html"
  end

  def build_channels_url
    'http://somafm.com/channels.xml'
  end

  def get_current_channel_data
    Nokogiri::XML(open(self.build_channels_url))
  end

  def get_channel_by_name_or_id(str)
    doc = get_current_channel_data
    doc.css('channels channel').each do |ch|
      if ch.css('title').text.downcase.eql?(str) || ch['id'].downcase.eql?(str)
        return ch
      end
    end

    nil
  end

  def song_history_is_song?(sh)
    !sh['Played At'].eql?("") &&
        !sh['Artist'].eql?('Break / Station ID') &&
        !sh['Artist'].eql?('(sound bite)')
  end

  def song_is_currently_played?(sh)
    sh['Played At'].end_with?('(Now)')
  end
end
