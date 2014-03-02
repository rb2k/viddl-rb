
class Decipherer

  class UnknownCipherVersionError < StandardError; end 
  class UnknownCipherOperationError < StandardError; end

  def initialize(loader)
    @ciphers = loader.load_ciphers
  end

  def decipher_with_version(cipher, cipher_version)
    operations = @ciphers[cipher_version] 
    raise UnknownCipherVersionError.new("Unknown cipher version: #{cipher_version}") unless operations

    decipher_with_operations(cipher, operations.split)
  end

  def decipher_with_operations(cipher, operations)
    cipher = cipher.dup

    operations.each do |op|
      cipher = apply_operation(cipher, op)
    end
    cipher
  end

  private

  def apply_operation(cipher, op)
    op = check_operation(op)

    case op[0].downcase
    when "r"
      cipher.reverse
    when "w"
      index = get_op_index(op)
      swap_first_char(cipher, index)
    when "s"
      index = get_op_index(op)
      cipher[index, cipher.length - 1] # slice from index to the end
    else
      raise_unknown_op_error(op)
    end
  end

  def check_operation(op)
    raise_unknown_op_error(op) if op.nil? || !op.respond_to?(:to_s)
    op.to_s
  end

  def swap_first_char(string, index)
    temp = string[0]
    string[0] = string[index]
    string[index] = temp
    string
  end

  def get_op_index(op)
    index = op[/.(\d+)/, 1]
    raise_unknown_op_error(op) unless index
    index.to_i
  end

  def raise_unknown_op_error(op)
    raise UnknownCipherOperationError.new("Unkown operation: #{op}")
  end
end
