require 'rest-client'

class CipherGuesser
  class CipherGuessError < StandardError; end

  JS_URL = "http://s.ytimg.com/yts/jsbin/html5player-%s.js"

  def guess(cipher_version)
    js   = download_player_javascript(cipher_version)
    body = extract_decipher_function_body(js)

    parse_function_body(body)
  end

  private

  def download_player_javascript(cipher_version)
    RestClient.get(JS_URL % cipher_version)
  end

  def extract_decipher_function_body(js)
    function_name  = js[decipher_function_name_regex, 1]
    function_regex = get_function_regex(function_name)
    match          = function_regex.match(js)

    raise(CipherGuessError, "Could not extract the decipher function") unless match
    match[:brace]
  end

  def parse_function_body(body)
    lines = body.split(";")

    remove_non_decipher_lines!(lines)
    do_pre_transformations!(lines)

    lines.map do |line|
      if /\(\w+,(?<index>\d+)\)/     =~ line  # calling a two argument function (swap)
        "w#{index}"
      elsif /slice\((?<index>\d+)\)/ =~ line  # calling slice
        "s#{index}"
      elsif /reverse\(\)/            =~ line  # calling reverse
        "r"
      else
        raise "Cannot parse line: #{line}"
      end
    end
  end

  def remove_non_decipher_lines!(lines)
    # The first line splits the string into an array and the last joins and returns
    lines.delete_at(0)
    lines.delete_at(-1)
  end

  def do_pre_transformations!(lines)
    change_inline_swap_to_function_call(lines) if inline_swap?(lines)
  end

  def inline_swap?(lines)
    # Defining a variable = inline swap function
    lines.any? { |line| line.include?("var ") }
  end

  def change_inline_swap_to_function_call(lines)
    start_index = lines.find_index { |line| line.include?("var ") }
    swap_lines  = lines.slice!(start_index, 3)  # inline swap is 3 lines long
    i1, i2      = get_swap_indices(swap_lines)

    lines.insert(start_index, "swap(#{i1},#{i2})")
    lines
  end

  def get_swap_indices(lines)
    i1 = lines.first[/(\d+)/, 1]
    i2 = lines.last[/(\d+)/, 1]
    [i1, i2]
  end

  def decipher_function_name_regex
    # Find "C" in this: var A = B.sig || C (B.s)
    /
    \.sig
    \s*
    \|\|
    (\w+)
    \(
    /x
  end

  def get_function_regex(function_name)
  # Match the function function_name (that has one argument)
    /
    #{function_name}
    \(
    \w+
    \)
    #{function_body_regex}
    /x
  end

  def function_body_regex
  # Match nested braces
    /
    (?<brace>
    {
    (
    [^{}]
    | \g<brace>
    )*
    }
    )
    /x
  end
end
