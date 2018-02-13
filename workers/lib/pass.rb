require 'pathname'
require 'date'
require 'httparty'

class Pass

  def initialize md5
    @md5 = Pathname.new(md5)
    @id = @md5.basename('.md5').to_s
    files = Dir.glob(File.join(@md5.dirname, "#{@id}*")).reject{|f| File.basename(f) == @md5.basename.to_s }
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
    if satellite.name == "metop-b"
      system("gunzip #{cache_path}/#{@file.basename.to_s}")
    end
    # TODO:  Verify copied file matches md5
    true
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
    @facility ||= relative_path.split.first.to_s[1..-1]
  end

  def controller
    "http://#{ENV['SANDY_CONTROLLER']}/processing/pass"
  end

  def cache_path
    File.join(ENV['LANDFALL_SHARED_PATH'], facility, satellite.name, 'raw', year, month, @id)
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
      name = filename.downcase
      case name
      when %r{^npp.\d{5}.\d{4}};      ['snpp', parse_date(name, "npp.%y%j.%H%M")]
      when %r{^npp.\d{8}.\d{4}};      ['snpp', parse_date(name, "npp.%Y%m%d.%H%M")]
      when %r{^a1.\d{5}.\d{4}};       ['aqua', parse_date(name, "a1.%y%j.%H%M")]
      when %r{^aqua.\d{8}.\d{4}};     ['aqua', parse_date(name, "aqua.%Y%m%d.%H%M")]
      when %r{^t1.\d{5}.\d{4}};       ['terra', parse_date(name, "t1.%y%j.%H%M")]
      when %r{^terra.\d{8}.\d{4}};    ['terra', parse_date(name, "terra.%Y%m%d.%H%M")]
      when %r{^tp\d{13}.metop-b.dat}; ['metop-b', parse_date(name, "tp%Y%j%H%M")]
      when %r{^n15};                  ['noaa15', parse_date(name, "n15.%y%j.%H%M")]
      when %r{^n18};                  ['noaa18', parse_date(name, "n18.%y%j.%H%M")]
      when %r{^n19};                  ['noaa19', parse_date(name, "n19.%y%j.%H%M")]
      when %r{^jpss1.\d{8}.\d{4}};    ['noaa20', parse_date(name, "jpss1.%Y%m%d.%H%M")]
    # TODO:  DMSP
      else ['unknown', Time.now]
      end
    end

    def parse_date(filename, pattern)
      DateTime.strptime(filename, pattern)
    end
  end
end
