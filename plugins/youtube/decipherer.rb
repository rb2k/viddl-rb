
class Decipherer

  class UnknownCipherVersionError < StandardError; end 
  class UnknownCipherOperationError < StandardError; end 

  CIPHERS = {
    'vflNzKG7n' => 's3 r s2 r s1 r w67',              # 30 Jan 2013, untested
    'vfllMCQWM' => 's2 w46 r w27 s2 w43 s2 r',        # 15 Feb 2013, untested
    'vflJv8FA8' => 's1 w51 w52 r',                    # 12 Mar 2013, untested
    'vflR_cX32' => 's2 w64 s3',                       # 11 Apr 2013, untested
    'vflveGye9' => 'w21 w3 s1 r w44 w36 r w41 s1',    # 02 May 2013, untested
    'vflj7Fxxt' => 'r s3 w3 r w17 r w41 r s2',        # 14 May 2013, untested
    'vfltM3odl' => 'w60 s1 w49 r s1 w7 r s2 r',       # 23 May 2013
    'vflDG7-a-' => 'w52 r s3 w21 r s3 r',             # 06 Jun 2013
    'vfl39KBj1' => 'w52 r s3 w21 r s3 r',             # 12 Jun 2013
    'vflmOfVEX' => 'w52 r s3 w21 r s3 r',             # 21 Jun 2013
    'vflJwJuHJ' => 'r s3 w19 r s2',                   # 25 Jun 2013
    'vfl_ymO4Z' => 'r s3 w19 r s2',                   # 26 Jun 2013
    'vfl26ng3K' => 'r s2 r',                          # 08 Jul 2013
    'vflcaqGO8' => 'w24 w53 s2 w31 w4',               # 11 Jul 2013
    'vflQw-fB4' => 's2 r s3 w9 s3 w43 s3 r w23',      # 16 Jul 2013
    'vflSAFCP9' => 'r s2 w17 w61 r s1 w7 s1',         # 18 Jul 2013
    'vflART1Nf' => 's3 r w63 s2 r s1',                # 22 Jul 2013
    'vflLC8JvQ' => 'w34 w29 w9 r w39 w24',            # 25 Jul 2013
    'vflm_D8eE' => 's2 r w39 w55 w49 s3 w56 w2',      # 30 Jul 2013
    'vflTWC9KW' => 'r s2 w65 r',                      # 31 Jul 2013
    'vflRFcHMl' => 's3 w24 r',                        # 04 Aug 2013
    'vflM2EmfJ' => 'w10 r s1 w45 s2 r s3 w50 r',      # 06 Aug 2013
    'vflz8giW0' => 's2 w18 s3',                       # 07 Aug 2013
    'vfl_wGgYV' => 'w60 s1 r s1 w9 s3 r s3 r',        # 08 Aug 2013
    'vfl1HXdPb' => 'w52 r w18 r s1 w44 w51 r s1',     # 12 Aug 2013
    'vflkn6DAl' => 'w39 s2 w57 s2 w23 w35 s2',        # 15 Aug 2013
    'vfl2LOvBh' => 'w34 w19 r s1 r s3 w24 r',         # 16 Aug 2013
    'vfl-bxy_m' => 'w48 s3 w37 s2',                   # 20 Aug 2013
    'vflZK4ZYR' => 'w19 w68 s1',                      # 21 Aug 2013
    'vflh9ybst' => 'w48 s3 w37 s2',                   # 21 Aug 2013
    'vflapUV9V' => 's2 w53 r w59 r s2 w41 s3',        # 27 Aug 2013
    'vflg0g8PQ' => 'w36 s3 r s2',                     # 28 Aug 2013
    'vflHOr_nV' => 'w58 r w50 s1 r s1 r w11 s3',      # 30 Aug 2013
    'vfluy6kdb' => 'r w12 w32 r w34 s3 w35 w42 s2',   # 05 Sep 2013
    'vflkuzxcs' => 'w22 w43 s3 r s1 w43',             # 10 Sep 2013
    'vflGNjMhJ' => 'w43 w2 w54 r w8 s1',              # 12 Sep 2013
    'vfldJ8xgI' => 'w11 r w29 s1 r s3',               # 17 Sep 2013
    'vfl79wBKW' => 's3 r s1 r s3 r s3 w59 s2',        # 19 Sep 2013
    'vflg3FZfr' => 'r s3 w66 w10 w43 s2',             # 24 Sep 2013
    'vflUKrNpT' => 'r s2 r w63 r',                    # 25 Sep 2013
    'vfldWnjUz' => 'r s1 w68',                        # 30 Sep 2013
    'vflP7iCEe' => 'w7 w37 r s1',                     # 03 Oct 2013
    'vflzVne63' => 'w59 s2 r',                        # 07 Oct 2013
    'vflO-N-9M' => 'w9 s1 w67 r s3',                  # 09 Oct 2013
    'vflZ4JlpT' => 's3 r s1 r w28 s1',                # 11 Oct 2013
    'vflDgXSDS' => 's3 r s1 r w28 s1',                # 15 Oct 2013
    'vflW444Sr' => 'r w9 r s1 w51 w27 r s1 r',        # 17 Oct 2013
    'vflK7RoTQ' => 'w44 r w36 r w45',                 # 21 Oct 2013
    'vflKOCFq2' => 's1 r w41 r w41 s1 w15',           # 23 Oct 2013
    'vflcLL31E' => 's1 r w41 r w41 s1 w15',           # 28 Oct 2013
    'vflz9bT3N' => 's1 r w41 r w41 s1 w15',           # 31 Oct 2013
    'vfliZsE79' => 'r s3 w49 s3 r w58 s2 r s2',       # 05 Nov 2013
    'vfljOFtAt' => 'r s3 r s1 r w69 r',               # 07 Nov 2013
    'vflqSl9GX' => 'w32 r s2 w65 w26 w45 w24 w40 s2', # 14 Nov 2013
    'vflFrKymJ' => 'w32 r s2 w65 w26 w45 w24 w40 s2', # 15 Nov 2013
    'vflKz4WoM' => 'w50 w17 r w7 w65',                # 19 Nov 2013
    'vflhdWW8S' => 's2 w55 w10 s3 w57 r w25 w41',     # 21 Nov 2013
    'vfl66X2C5' => 'r s2 w34 s2 w39',                 # 26 Nov 2013
    'vflCXG8Sm' => 'r s2 w34 s2 w39',                 # 02 Dec 2013
    'vfl_3Uag6' => 'w3 w7 r s2 w27 s2 w42 r',         # 04 Dec 2013
    'vflQdXVwM' => 's1 r w66 s2 r w12',               # 10 Dec 2013
    'vflCtc3aO' => 's2 r w11 r s3 w28',               # 12 Dec 2013
    'vflCt6YZX' => 's2 r w11 r s3 w28',               # 17 Dec 2013
    'vflG49soT' => 'w32 r s3 r s1 r w19 w24 s3',      # 18 Dec 2013
    'vfl4cHApe' => 'w25 s1 r s1 w27 w21 s1 w39',      # 06 Jan 2014
    'vflwMrwdI' => 'w3 r w39 r w51 s1 w36 w14',       # 06 Jan 2014
    'vfl4AMHqP' => 'r s1 w1 r w43 r s1 r',            # 09 Jan 2014
    'vfln8xPyM' => 'w36 w14 s1 r s1 w54',             # 10 Jan 2014
    'vflVSLmnY' => 's3 w56 w10 r s2 r w28 w35',       # 13 Jan 2014
    'vflkLvpg7' => 'w4 s3 w53 s2',                    # 15 Jan 2014
    'vflbxes4n' => 'w4 s3 w53 s2',                    # 15 Jan 2014
    'vflmXMtFI' => 'w57 s3 w62 w41 s3 r w60 r',       # 23 Jan 2014
    'vflYDqEW1' => 'w24 s1 r s2 w31 w4 w11 r',        # 24 Jan 2014
    'vflapGX6Q' => 's3 w2 w59 s2 w68 r s3 r s1',      # 28 Jan 2014
    'vflLCYwkM' => 's3 w2 w59 s2 w68 r s3 r s1',      # 29 Jan 2014
    'vflcY_8N0' => 's2 w36 s1 r w18 r w19 r',         # 30 Jan 2014
    'vfl9qWoOL' => 'w68 w64 w28 r',                   # 03 Feb 2014
    'vfle-mVwz' => 's3 w7 r s3 r w14 w59 s3 r',       # 04 Feb 2014
    'vfltdb6U3' => 'w61 w5 r s2 w69 s2 r',            # 05 Feb 2014
    'vflLjFx3B' => 'w40 w62 r s2 w21 s3 r w7 s3',     # 10 Feb 2014
    'vfliqjKfF' => 'w40 w62 r s2 w21 s3 r w7 s3',     # 13 Feb 2014
    'ima-vflxBu-5R' => 'w40 w62 r s2 w21 s3 r w7 s3', # 13 Feb 2014
    'ima-vflrGwWV9' => 'w36 w45 r s2 r'               # 20 Feb 2014
  }

  def decipher_with_version(cipher, cipher_version)
    operations = CIPHERS[cipher_version] 
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
