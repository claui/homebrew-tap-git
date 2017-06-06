#:  * `tap-git` <arguments-to-git>:
#:    Run `git` inside the tap directory which points
#:    to the current working directory, i. e. has the
#:    current working directory configured as its remote.

require "tap"

module Homebrew
  module_function

  current_root = %x{ git -c alias.root='!pwd' root }.strip
  ohai "Working directory: #{current_root}"

  uri_path = current_root.gsub(/([^a-zA-Z0-9\/_.-]+)/) do
    ?% + $1.unpack("H2" * $1.bytesize).join(?%).upcase
  end
  current_root_uri = "file://#{uri_path}"

  matching_taps = Tap.select do |tap|
    tap.private? && tap.custom_remote? &&
      tap.remote.casecmp(current_root_uri).zero?
  end

  if matching_taps.empty?
    odie "Unable to find a private tap pointing to this directory"
  end

  tap = matching_taps.first
  ohai "Found tap: #{tap.name}"

  if ARGV.empty?
    odie "To run Git, this command requires at least one argument."
  end

  exec 'git', '-C', tap.path, *ARGV
end
