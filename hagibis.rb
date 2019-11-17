#!/usr/bin/env ruby
require "thor"
require_relative "./apps/rcard_billing/cli"
require_relative "./apps/line_message/cli"

module Hagibis
  class CLI < Thor
    register(RCardBilling::CLI, 'rcard_billing', 'rcard_billing [COMMAND]', 'Commands for Rakuten Card billings.')
    register(LineMessage::CLI, 'line_message', 'line_message [COMMAND]', 'Commands for LINE bot messaging.')
  end
end

if __FILE__ == $0
  Hagibis::CLI.start(ARGV)
end
