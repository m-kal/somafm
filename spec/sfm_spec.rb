require 'rails_helper'
require 'rspec'

require 'sfm'

describe Sfm do
  it 'exist' do
    sfm = Sfm.new()
    expect(sfm).to_not be_nil
  end

  describe '#pretty_format_hashes_as_table' do
    it 'should print out a table from a simple hash' do
      test_hash = [{'1' => 'A', '2' => 'B', '3' => 'C', '4' => 'D'}]
      sfm = Sfm.new()
      res = sfm.pretty_format_hashes_as_table(test_hash)
      expect(res.length).to eq(3)
      expect(res[0]).to eq('| 1 | 2 | 3 | 4 ')
      expect(res[1]).to eq('|---|---|---|---')
      expect(res[2]).to eq('| A | B | C | D ')
    end

    it 'should print out a table from a simple hash with longer headers than values' do
      test_hash = [{'11' => 'A', '22' => 'B', '33' => 'C', '44' => 'D'}]
      sfm = Sfm.new()
      res = sfm.pretty_format_hashes_as_table(test_hash)
      expect(res.length).to eq(3)
      expect(res[0]).to eq('| 11 | 22 | 33 | 44 ')
      expect(res[1]).to eq('|----|----|----|----')
      expect(res[2]).to eq('| A  | B  | C  | D  ')
    end

    it 'should print out a table from a simple hash with longer values than headers' do
      test_hash = [{'1' => 'AA', '2' => 'BB', '3' => 'CC', '4' => 'DD'}]
      sfm = Sfm.new()
      res = sfm.pretty_format_hashes_as_table(test_hash)
      expect(res.length).to eq(3)
      expect(res[0]).to eq('| 1  | 2  | 3  | 4  ')
      expect(res[1]).to eq('|----|----|----|----')
      expect(res[2]).to eq('| AA | BB | CC | DD ')
    end
  end

  describe '#build_song_history_url' do
    it 'should return a valid URL' do
      url = Sfm.new.build_song_history_url('defcon')
      uri = URI.parse(url)
      expect(uri.host).to eq('somafm.com')
    end
  end

  describe '#get_current_channel_data_xml' do
    it 'Returns xml for valid url' do
      stub_request(:get, "http://somafm.com/channels.xml").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => File.open("#{Rails.root}/spec/fixtures/channels.xml", 'r'), :headers => {})

      sfm = Sfm.new()
      xml = sfm.get_current_channel_data_xml
      expect(xml.css('channels channel').count).to eq(34)
    end
  end

  describe '#get_station_song_histories' do
    it 'should load HTML' do
      stub_request(:get, "http://somafm.com/defcon/songhistory.html").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => File.open("#{Rails.root}/spec/fixtures/defcon.htm", 'r'), :headers => {})


      sfm = Sfm.new()
      histories = sfm.get_station_song_histories('defcon')
      expect(histories.length).to eq(11)
    end
  end

  describe '#parse_station_song_histories' do
    it 'returns a hash for valid html histories' do
      raw_html = File.open("#{Rails.root}/spec/fixtures/defcon.htm", 'r')

      sfm = Sfm.new()
      allow(sfm).to receive(:get_station_song_histories).and_return(Nokogiri::HTML(raw_html))
      htm = sfm.get_station_song_histories('defcon')
      expect(htm.css("table tr").count).to eq(23)

      parsed = sfm.parse_station_song_histories(htm)
      expect(parsed.length).to eq(11)
      expect(parsed.first.keys.include?('Played At')).to be_truthy
      expect(parsed.first.keys.include?('Artist')).to be_truthy
      expect(parsed.first.keys.include?('Song')).to be_truthy
      expect(parsed.first.keys.include?('Album')).to be_truthy
    end
  end

  describe '#song_history_is_song?' do
    it 'returns false for an invalid song-history' do
      sfm = Sfm.new()

      expect(sfm.song_history_is_song?({'Played' => '', 'Artist' => ''})).to be_falsey
      expect(sfm.song_history_is_song?({'Played At' => '', 'Art' => ''})).to be_falsey
      expect(sfm.song_history_is_song?({'Played At' => '', 'Artist' => ''})).to be_falsey
      expect(sfm.song_history_is_song?({'Played At' => '23:54:11', 'Artist' => 'Break / Station ID'})).to be_falsey
      expect(sfm.song_history_is_song?({'Played At' => '23:54:11', 'Artist' => '(sound bite)'})).to be_falsey
    end

    it 'returns true for an valid song-history' do
      sfm = Sfm.new()

      expect(sfm.song_history_is_song?({'Played At' => '23:54:11', 'Artist' => ''})).to be_truthy
      expect(sfm.song_history_is_song?({'Played At' => '23:54:11', 'Artist' => 'Test'})).to be_truthy
      expect(sfm.song_history_is_song?({'Played At' => '23:54:11 (Now)', 'Artist' => 'Test'})).to be_truthy
    end
  end

  describe '#song_is_currently_played?' do
    it 'returns false for a song not playing' do
      sfm = Sfm.new()

      expect(sfm.song_is_currently_played?({'Played At' => '23:54:11', 'Artist' => ''})).to be_falsey
    end

    it 'returns true for a current song' do
      sfm = Sfm.new()

      expect(sfm.song_is_currently_played?({'Played At' => '23:54:11 (Now)', 'Artist' => ''})).to be_truthy
    end

  end
end