require 'optparse'
require 'net/http'

if __FILE__ == $0
  maps_dir = File.dirname(__FILE__) # Get current directory
  maps = [] # List of maps to download

  # Handle command line arguments
  OptionParser.new do |opts|
    opts.on("-d", "--directory DIR", "Specify maps directory") do |dir|
      maps_dir = dir
      puts dir
    end

    opts.on("-l", "--list LIST_FILE", "Load a list of maps") do |list_name|
      puts "Load maps from: #{list_name}"
      File.open(list_name, "r") {|file|
        file.each_line {|map_name|
          maps.push map_name.chomp
        }
      }
    end
  end.parse!(ARGV)

  # Add remaining parameters to the list of maps
  maps += ARGV

  # Download all the maps
  maps.each {|map_name|
    map_name = map_name + ".bsp" if not File.extname(map_name) == ".bsp"
    map_name = maps_dir + File::SEPARATOR  + map_name

    if not File.exists? map_name
      Net::HTTP.start("maps.redditeast.com") { |http|
        resp = http.get("/maps/#{map_name}.bz2")
        open(map_name, "wb") { |file|
          file.write(resp.body)
          puts "Downloaded #{map_name}"
        }
      }
    else
      puts "Skipped #{map_name}: map already exists"
    end
  }
end
