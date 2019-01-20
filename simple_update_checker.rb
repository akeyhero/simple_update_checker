#!/usr/bin/env ruby

email    = ARGV[0]
url      = ARGV[1]
selector = ARGV[2] || 'body'
wait     = (ARGV[3] || '5').to_i

require 'bundler/setup'
Bundler.require
require 'capybara/poltergeist'

puts "Starting the simple update chekcer.."

target_digest = Digest::MD5.hexdigest "#{url}\0#{selector}"
last_access_file_name = "#{Dir.pwd}/tmp/last_access_#{target_digest}.txt"

puts "Recording content's digest on #{last_access_file_name}"

Mail.defaults do
  delivery_method :smtp, address: 'localhost', port: 25
end

session = Capybara::Session.new :poltergeist

while true
  session.visit url
  target_dom = session.find selector
  content = target_dom.text
  content_digest = Digest::MD5.hexdigest content
  
  last_content_digest = File.open(last_access_file_name) { |f| f.read }.strip rescue nil
  
  if content_digest == last_content_digest
    puts "No update found at #{Time.new}"
  else
    if last_content_digest
      Mail.deliver(
        from: email,
        to: email,
        subject: 'Updated!',
        body: content,
        charset: Encoding::UTF_8
      )

      puts "Update found at: #{Time.new}"
    else
      puts "First check made at: #{Time.new}"
    end

    File.open last_access_file_name, mode = "w" do |f|
      f.write content_digest
    end
  end
  
  sleep wait * 60
end
