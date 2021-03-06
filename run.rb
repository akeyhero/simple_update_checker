#!/usr/bin/env ruby

email    = ARGV[0]
url      = ARGV[1]
selector = ARGV[2] || 'body'
interval = (ARGV[3] || '5').to_i

require_relative 'init'

checker = SimpleUpdateChecker.new(email, url, selector, interval)
checker.start_session
checker.run
