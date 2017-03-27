require 'rails'
require 'thor'
require 'net/http'
require 'open-uri'
require 'Nokogiri'

require "./lib/somafm/engine"
require "./lib/sfm"

class SomaCli < Thor
  desc "st STATION", "Reports the current song for a given station."
  def st(station)
    puts "Looking up info for #{station}..."
    sfm = Sfm.new()
    st = sfm.get_channel_by_name_or_id(station)
    puts st.css('lastPlaying').text unless st.nil?
  end

  desc "ch", "Lists all channels."
  def channels
    sfm = Sfm.new()
    doc = sfm.get_current_channel_data
    doc.css('channels channel').each do |ch|
      puts ch.css('title').text + ': ' + ch.css('description').text
    end
  end

  desc "sh STATION", "Show song history"
  def sh(channel)
    sfm = Sfm.new()
    doc = Nokogiri::HTML(open(sfm.build_song_history_url(channel)))
    row = 0
    sh_keys = []
    sh = []
    doc.css("table tr").each do |tr|
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

      if sfm.song_history_is_song?(song_history)
        sh += [song_history]
        if sfm.song_is_currently_played?(song_history)
          #puts "now playing"
        end
      end
    end
    puts sh
  end
end

SomaCli.start(ARGV)