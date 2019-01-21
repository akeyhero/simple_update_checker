class SimpleUpdateChecker
  def initialize(email, url, selector, interval)
    @email    = email
    @url      = url
    @selector = selector
    @interval = interval
  end

  def start_session
    puts "Starting the simple update chekcer.."
    puts "Recording content's digest on #{last_access_file_name}"

    @session = Capybara::Session.new :poltergeist
  end

  def run
    while true
      check_update
      sleep @interval * 60
    end
  end

  private

  def check_update
    @session.visit @url

    content = get_content
    content_digest = digest_content content

    last_content_digest = read_last_content_digest

    if content_digest == last_content_digest
      puts "No update found at #{Time.new}"
    else
      if last_content_digest
        Mail.deliver do
          from    email
          to      email
          subject 'Updated!'
          body    <<~EOM
            #{content}
            
            URL: #{@url}
          EOM
          charset Encoding::UTF_8
        end
        puts "Update found at #{Time.new}"
      else
        puts "First check made at #{Time.new}"
      end

      write_last_content_digest(content_digest)
    end
  rescue Capybara::ElementNotFound => e
    puts "Element #{@selector} not found at #{Time.new}"
  end

  def get_content
    target_dom = @session.find @selector
    target_dom.text
  end

  def digest_content(content)
    Digest::MD5.hexdigest content
  end

  def read_last_content_digest
    File.open(last_access_file_name) { |f| f.read }.strip
  rescue
    nil
  end

  def write_last_content_digest(content_digest)
    File.open last_access_file_name, mode = 'w' do |f|
      f.write content_digest
    end
  end

  def last_access_file_name
    return @last_access_file_name if @last_access_file_name
    target_digest = Digest::MD5.hexdigest "#{@url}\0#{@selector}"
    @last_access_file_name = "#{Dir.pwd}/tmp/last_access_#{target_digest}.txt"
  end
end
