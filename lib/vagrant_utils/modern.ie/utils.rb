require 'colorize'
require 'ruby-prof'

#
# timethis is ruby-prof stuff I want to remember
# everything else is silly text formatting that should be its own class
#
module Utils
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
