require "./lib/somafm/engine"

require 'thor'
require 'net/http'
require 'open-uri'
require 'Nokogiri'
require 'byebug'

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

  def get_current_channel_data_xml
    Nokogiri::XML(open(self.build_channels_url))
  end

  def get_channel_by_name_or_id(str)
    doc = get_current_channel_data_xml
    doc.css('channels channel').each do |ch|
      if ch.css('title').text.downcase.eql?(str) || ch['id'].downcase.eql?(str)
        return ch
      end
    end

    nil
  end

  def song_history_is_song?(sh)
    sh.key?('Played At') &&
      sh.key?('Artist') &&
      !sh['Played At'].eql?('') &&
      !sh['Artist'].eql?('Break / Station ID') &&
      !sh['Artist'].eql?('(sound bite)')
  end

  def song_is_currently_played?(sh)
    sh['Played At'].end_with?('(Now)')
  end

  def get_station_song_histories(station, limit=0)
    doc = Nokogiri::HTML(open(build_song_history_url(station)))
    parsed = parse_station_song_histories(doc)
    parsed.take(limit.to_i.eql?(0) ? parsed.count : limit.to_i)
  end

  def parse_station_song_histories(html_history)
    row = 0
    sh_keys = []
    sh = []
    html_history.css("table tr").each do |tr|
      if row == 0
        tr.css('td').each do |td|
          sh_keys += [td.text]
        end
        row += 1
        next
      end

      song_history = {}
      col = 0
      tr.css('td').each do |td|
        unless sh_keys[col].eql?("")
          song_history[sh_keys[col]] = td.text.strip
          col += 1
        end
      end

      if song_history_is_song?(song_history)
        sh += [song_history]
        if song_is_currently_played?(song_history)
          #puts "now playing"
        end
      end
    end

    sh
  end

  def pretty_format_hashes_as_table(hashes)
    response_lines = []
    longest_string = {}
    hashes.each do |history|
      history.keys.each do |key|
        longest_string[key] = [longest_string[key].to_i, key.length, history[key].length].max
      end
    end

    headings = ''
    divider = ''
    hashes.first.keys.each do |key|
      fmt_str = "#{longest_string[key]}"
      headings << sprintf("| %-#{fmt_str}s ", key)
      divider  << sprintf("|--" << "-" * longest_string[key])
    end

    response_lines += [headings]
    response_lines += [divider]

    hashes.each do |history|
      str = ''
      history.keys.each do |key|
        fmt_str = "#{longest_string[key]}"
        str << sprintf("| %-#{fmt_str}s ", history[key])
      end
      response_lines += [str]
    end
    response_lines
  end
end
