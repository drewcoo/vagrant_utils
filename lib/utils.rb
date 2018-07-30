require 'colorize'
require 'ruby-prof'

#
# timethis is ruby-prof stuff I want to remember
# everything else is silly text formatting that should be its own class
#
module Utils
  # Keeps retrying with longer sleeps until it eventually raises
  # Takes over 4 minutes.
  SLEEP_INCREMENT = 0.1
  def retry_with_backoff
    sleep_number = -SLEEP_INCREMENT
    loop do
      raise 'Too long to contact host' if sleep_number >= 5
      sleep sleep_number += SLEEP_INCREMENT
      yield self
    end
  end

  # rubocop:disable Metrics/MethodLength
  def timethis(label: nil, times: 1, &block)
    RubyProf.start

    start = Time.now
    times.times do
      block.yield
    end
    stop = Time.now

    result = RubyProf.stop
    printer = RubyProf::FlatPrinter.new(result)
    printer.print(STDOUT)

    puts
    puts label unless label.nil?
    puts "TIME: #{stop - start}"
  end
  # rubocop:enable Metrics/MethodLength

  def puts_table(title, data)
    max_len = longest_line(data + [title])
    title = centered(title, max_len)
    horizontal = color_line(max_len)

    puts
    puts horizontal
    puts title
    puts horizontal
    data.each { |line| puts line }
    puts horizontal
  end

  private

  def longest_line(text)
    longest = 0
    text.each { |line| longest = line.length if line.length > longest }
    longest
  end

  def centered(string, total_len)
    lead = ' ' * ((total_len - string.length) / 2)
    lead + string
  end

  def color_line(length, color = :green)
    ('-' * length).colorize(color)
  end
end
