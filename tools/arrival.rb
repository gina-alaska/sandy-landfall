require 'pathname'
require 'date'
require 'httparty'

class Pass
  def initialize(in_file)
    files = nil
    @filename = in_file
    if File.extname(in_file) == '.md5'
      @md5 = Pathname.new(in_file)
      @id = @md5.basename('.md5').to_s
      @id = File.basename(@id, '.gz') if File.extname(@id) == '.gz'

      @id = File.basename(@id, '.dat') if File.extname(@id) == '.dat'

      @id = File.basename(@id, '.zero') if File.extname(@id) == '.zero'

      files = Dir.glob(File.join(@md5.dirname, "#{@id}*")).reject { |f| File.basename(f) == @md5.basename.to_s }
    else
      @data_file = Pathname.new(in_file)
      @id = @data_file.basename.to_s
      @id = File.basename(@id, '.gz') if File.extname(@id) == '.gz'

      @id = File.basename(@id, '.dat') if File.extname(@id) == '.dat'

      @id = File.basename(@id, '.zero') if File.extname(@id) == '.zero'

      files = Dir.glob(File.join(@data_file.dirname, "#{@id}*"))
    end

    @file = Pathname.new(files.first)
  end

  def to_s
    "Pass{#{satellite}:#{@filename}}"
  end

  def notify_arrival
    response = HTTParty.post(controller, default_options)
    puts response.body
  end

  def cache!
    path = File.join(cache_path, @file.basename)
    if File.exist?(File.join(cache_path, @file.basename)) && (File.size?(path) == File.size?(@file))
      puts('INFO: File seems to be already ingested and online.')
      puts("INFO: \tSize in gluster: #{File.size?(path)}")
      puts("INFO: \tSize on landfall: #{File.size?(@file)}")
      puts("INFO: \tPath on Gluster: #{@file}")
      return false
    end
    # Create directories unless they exist
    # Delete any files if they exist?  Or fail if it exists
    # Return false if either of the above is true
    # Return True if the copy is successful
    FileUtils.mkdir_p(cache_path) unless File.exist? cache_path
    FileUtils.copy @file, cache_path
    system("gunzip #{cache_path}/#{@file.basename}") if satellite.name == 'metop-b'
    # TODO:  Verify copied file matches md5
    true
  end

  def satellite
    @satellite ||= Satellite.new(@id)
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

  def facility
    @facility ||= File.basename(File.dirname(@filename))
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
    satellite.acquired_at.month.to_s.rjust(2, '0')
  end

  class Satellite
    attr_reader :name, :acquired_at

    def initialize(pattern)
      @name, @acquired_at = parse_name(pattern)
    end

    def to_s
      "Satellite:#{@name}@#{@acquired_at}"
    end

    private

    def parse_name(filename)
      name = filename.downcase
      case name
      when /^npp.\d{5}.\d{4}/ then      ['snpp', parse_date(name, 'npp.%y%j.%H%M')]
      when /^npp.\d{8}.\d{4}/ then      ['snpp', parse_date(name, 'npp.%Y%m%d.%H%M')]
      when /^a1.\d{5}.\d{4}/ then       ['aqua', parse_date(name, 'a1.%y%j.%H%M')]
      when /^aqua.\d{8}.\d{4}/ then     ['aqua', parse_date(name, 'aqua.%Y%m%d.%H%M')]
      when /^t1.\d{5}.\d{4}/ then       ['terra', parse_date(name, 't1.%y%j.%H%M')]
      when /^terra.\d{8}.\d{4}/ then    ['terra', parse_date(name, 'terra.%Y%m%d.%H%M')]
      when /^tp\d{13}.metop-b/ then ['metop-b', parse_date(name, 'tp%Y%j%H%M')]
      when /^tp\d{13}.metop-c/ then ['metop-c', parse_date(name, 'tp%Y%j%H%M')]
      when /^n15/ then                  ['noaa15', parse_date(name, 'n15.%y%j.%H%M')]
      when /^n18/ then                  ['noaa18', parse_date(name, 'n18.%y%j.%H%M')]
      when /^n19/ then                  ['noaa19', parse_date(name, 'n19.%y%j.%H%M')]
      when /^noaa18/ then               ['noaa18', parse_date(name, 'noaa18.%Y%m%d.%H%M')]
      when /^noaa19/ then               ['noaa19', parse_date(name, 'noaa19.%Y%m%d.%H%M')]
      when /^jpss1.\d{8}.\d{4}/ then    ['noaa20', parse_date(name, 'jpss1.%Y%m%d.%H%M')]
      when /^j1.\d{5}.\d{4}/ then       ['noaa20', parse_date(name, 'j1.%y%j.%H%M')]
      when /^jpss2.\d{8}.\d{4}/ then    ['noaa21', parse_date(name, 'jpss2.%Y%m%d.%H%M')]
      when /^j2.\d{5}.\d{4}/ then       ['noaa21', parse_date(name, 'j2.%y%j.%H%M')]
      when /^gcom-w1.\d{8}.\d{4}/ then  ['gcom-w', parse_date(name, 'gcom-w1.%Y%m%d.%H%M')]
      # TODO:  DMSP
      else ['unknown', Time.now]
      end
    end

    def parse_date(filename, pattern)
      DateTime.strptime(filename, pattern)
    end
  end
end

skip = ['.md5', '.gz']

unless skip.member?(File.extname(ARGV.first))
  pass = Pass.new(ARGV.first)
  puts("INFO: Starting #{pass} at #{Time.now}")
  if pass.satellite.name == 'unknown'
    puts('INFO: SKipping - unknown platform.')
  elsif pass.cache!
    pass.notify_arrival
  end

  puts("INFO: Done #{pass} at #{Time.now}")
end
