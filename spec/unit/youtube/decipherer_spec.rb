
$LOAD_PATH << File.join(File.dirname(__FILE__), '../../..', 'plugins/youtube')

require 'minitest/autorun'
require 'decipherer.rb'
require 'cipher_loader.rb'

class DeciphererTest < Minitest::Test

  def setup
    @dc = Decipherer.new(CipherLoader.new)
  end

  def test_raises_UnkownCipherVersionError_if_cipher_version_not_recognized
    assert_raises(Decipherer::UnknownCipherVersionError) { @dc.decipher_with_version("", nil) }
    assert_raises(Decipherer::UnknownCipherVersionError) { @dc.decipher_with_version("", "f7sdfkjsd") }
  end

  def test_raises_UnknownCipherOperationError_if_unknown_operation
    assert_raises(Decipherer::UnknownCipherOperationError) { @dc.decipher_with_operations("", [nil]) }
    assert_raises(Decipherer::UnknownCipherOperationError) { @dc.decipher_with_operations("", ["x47"]) }
    assert_raises(Decipherer::UnknownCipherOperationError) { @dc.decipher_with_operations("", ["wTwo"]) }
  end

  def test_can_do_reverse_operation
    assert_equal("esrever", @dc.decipher_with_operations("reverse", ["r"]))

    longer = "F4DC4DAC306AF54FE5133C41696EB69A45CD1E80949.B6AE03D2EFA82CCC157AAF45EEBE67167FFAE37F37676" 
    assert_equal(longer.reverse, @dc.decipher_with_operations(longer, ["r"]))
  end

  def test_can_do_swap_operation
    string = "swap 0th and Nth character".freeze

    assert_equal("awap 0th snd Nth character", @dc.decipher_with_operations(string.dup, ["w9"]))
    assert_equal("rwap 0th and Nth charactes", @dc.decipher_with_operations(string.dup, ["w#{string.length-1}"]))
  end

  def test_can_do_slice_operation
    string = "slice from character N to the end"

    assert_equal("ice from character N to the end", @dc.decipher_with_operations(string, ["s2"]))
    assert_equal("N to the end", @dc.decipher_with_operations(string, ["s#{string.index("N")}"]))
  end

  def test_can_do_all_operations_together
    string = "reverse swap and slice!"

    assert_equal("cil! dna paws esrever", @dc.decipher_with_operations(string, %w[r w5 s2]))
  end

  def test_can_decipher_using_a_cipher_version
    # 'vflbxes4n' => 'w4 s3 w53 s2'
    string = "F4DC4DAC306AF54FE5133C41696EB69A45CD1E80949.B6AE03D2EFA82CCC157AAF45EEBE67167FFAE37F37676"

    assert_equal("DAC306AF54FE5133C41696EB69A45CD1E80949.B6AE03D2EFA8CCCC157AAF45EEBE67167FFAE37F37676",
                 @dc.decipher_with_version(string, "vflbxes4n"))
  end
end
