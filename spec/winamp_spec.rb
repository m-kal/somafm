require 'rails_helper'
require 'rspec'

require 'winamp'

describe Winamp do
  plsContent = <<PLSTEXT
[playlist]
numberofentries=2
File1=http://ice1.somafm.com/defcon-128-mp3
Title1=SomaFM: DEF CON Radio (#1  ): Music for Hacking. The DEF CON Year-Round Channel.
Length1=-1
File2=http://ice2.somafm.com/defcon-128-mp3
Title2=SomaFM: DEF CON Radio (#2  ): Music for Hacking. The DEF CON Year-Round Channel.
Length2=-1
Version=2
PLSTEXT

  it 'exist' do
    w = Winamp.new()
    expect(w).to_not be_nil
  end

  it 'has basic commands' do
    w = Winamp.new('winamp.exe')

    expect(w).to receive(:cmd).with('/PLAYPAUSE').and_return(true)
    w.playpause()

    expect(w).to receive(:cmd).with('/LOADPLAY filename.mp3').and_return(true)
    w.play('filename.mp3')
  end

  describe '#streams_from_pls``' do
    it 'fetches content for urls' do
      stub_request(:get, "http://somafm.com/defcon.pls").
          with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
          to_return(:status => 200, :body => plsContent, :headers => {})
      w = Winamp.new()
      streams = w.streams_from_pls("http://somafm.com/defcon.pls")
      expect(streams.length).to eq(2)
    end
  end

  describe '#parse_playlist_ini' do
    it 'can parse simple playlist files' do
      w = Winamp.new()
      streams = w.parse_playlist_ini(IniFile.new(:content => plsContent))
      expect(streams.length).to eq(2)
    end
  end
end