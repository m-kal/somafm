require_relative "./somafm/engine"
require 'inifile'

class Winamp
  :attr_reader
  @cmds

  def initialize(path="C:\\Program Files (x86)\\Winamp\\winamp.exe")
    @path = path
    @cmds = {
        'play' => 'PLAY',
        'plclear' => 'PLCLEAR',
        'pladd' => 'PLADD',
        'plfirst' => 'PLFIRST',
        'playpause' => 'PLAYPAUSE'
    }
  end

  def play(file)
    cmd("/" + "LOADPLAY " + file)
  end

  def play_stream(file)
    if File.extname(file) == '.pls'
      streams = streams_from_pls(file)
    end
    cmd("/" + "LOADPLAY " + streams.first[:file])
  end

  def streams_from_pls(stream_url)
    if stream_url =~ URI::regexp
      resp = Net::HTTP.get_response(URI.parse(stream_url))
      pls = IniFile.new(:content => resp.body)
    else
      pls = IniFile.load(stream_url)
    end
    streams = parse_playlist_ini(pls)
    streams
  end

  def parse_playlist_ini(pls)
    if pls.has_section?('playlist')
      content = pls['playlist']
      streams = []
      i = 1
      content['numberofentries'].times do
        streams += [{:file => content["File#{i}"],
                     :title => content["Title#{i}"],
                     :length => content["Length#{i}"]
                    }]
        i += 1
      end
      streams
    end
  end

  def playpause
    cmd("/" + @cmds['playpause'])
  end

  def listplay(files=[])
    #puts files
    puts "Loading #{files.length} files..."
    cmd("/" + "stop")
    cmd("/" + @cmds['plclear'])
    files.each do |file|
      #cmd("/" + @cmds['pladd'] + " #{file}")
      cmd("/ADD #{file}")
    end
    cmd("/" + @cmds['plfirst'])
    cmd("/" + @cmds['play'])
  end
  # /ADDPLAYLIST <file> <name> [<guid>]	Allows for adding the specified playlist to
  #         Winamp's library playlists.
		# 			The <guid> parameter is optional and auto-generated if not specified
  @private
  def cmd(str)
    cmd = "\"#{@path}\" " + str
    system(cmd)
  end
end