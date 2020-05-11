require "./cli/cli"

module Geera
  VERSION = "0.1.0"

  cli = Cli.new
  cli.start ARGV
end
