
class DecipherCoordinator

  def initialize(decipherer, cipher_guesser)
    @decipherer = decipherer
    @cipher_guesser = cipher_guesser
  end

  def get_decipher_data(cipher_version)
    ops = @decipherer.get_operations(cipher_version)
    Youtube.notify "Cipher guess: no"
    {version: cipher_version, operations: ops.join(" "), guess?: false}

  rescue Decipherer::UnknownCipherVersionError => e
    ops = @cipher_guesser.guess(cipher_version)
    Youtube.notify "Cipher guess: yes"
    {version: cipher_version, operations: ops.join(" "), guess?: true}

  rescue Decipherer::UnknownCipherOperationError => e
    Youtube.notify "Failed to parse the cipher from the Youtube player version #{cipher_version}\n" +
                   "Please submit a bug report at https://github.com/rb2k/viddl-rb"
    raise e
  end

  def decipher_with_operations(cipher, operations)
    @decipherer.decipher_with_operations(cipher, operations)
  end
end
