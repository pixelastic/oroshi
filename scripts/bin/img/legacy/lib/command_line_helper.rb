# Command-line related methods, to help the use of the cli from ruby
module CommandLineHelper
  # Check if a cli tool is installed
  def installed?(input)
    system("which #{input} > /dev/null 2>&1")
  end
end
