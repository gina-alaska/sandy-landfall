require 'pathname'
require 'date'
require 'httparty'

class Pass

  def initialize md5
    @md5 = Pathname.new(md5)
    @id = @md5.basename('.md5').to_s
    files = Dir.glob(File.join(@md5.dirname, "#{@id}*")).reject{|f| File.basename(f) == @md5.basename }
    @file = Pathname.new(files.first)
  end

  def notify_arrival
    response = HTTParty.post(controller, default_options)
    puts response.body
  end

  def cache!
    return false if File.exists?(File.join(cache_path, @file.basename))
    # Create directories unless they exist
    # Delete any files if they exist?  Or fail if it exists
    # Return false if either of the above is true
    # Return True if the copy is successful
    FileUtils.mkdir_p(cache_path) unless File.exists? cache_path
    FileUtils.copy @file, cache_path
    # TODO:  Verify copied file matches md5
  end

  private
  def default_options
    {
      body: {
        satellite: satellite.name,
        facility: facility.to_s,
        pass: {
          acquired_at: satellite.acquired_at,
          name: @id
        }
      }
    }
  end

  def satellite
    @satellite ||= Satellite.new(@id)
  end

  def facility
    @facility ||= relative_path.split.first
  end

  def controller
    "http://#{ENV['SANDY_CONTROLLER']}/processing/pass"
  end

  def cache_path
    File.join(ENV['LANDFALL_SHARED_PATH'], facility, satellite.name, 'raw', year, month, id)
  end

  def relative_path
    @md5.sub(/^#{ENV['LANDFALL_RAW_PATH']}/, '')
  end

  def year
    satellite.acquired_at.year.to_s
  end

  def month
    satellite.acquired_at.month.to_s.rjust(2,'0')
  end

  class Satellite
    attr_reader :name
    attr_reader :acquired_at

    def initialize pattern
      @name, @acquired_at = parse_name(pattern)
    end

    private
    def parse_name(filename)
      case filename
        when /^npp/; ['snpp', parse_date(filename, "npp.%y%j.%H%M")]
        when /^a1/; ['aqua', parse_date(filename, "a1.%y%j.%H%M")]
        when /^t1/; ['terra', parse_date(filename, "t1.%y%j.%H%M")]
      # TODO:  DMSP, NOAA, METOP
        else ['unknown', Time.now]
      end
    end

    def parse_date(filename, pattern)
      DateTime.strptime(filename, pattern)
    end
  end
end