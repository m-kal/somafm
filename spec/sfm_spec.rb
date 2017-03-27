require 'rails_helper'
require 'rspec'
require 'sfm'

describe Sfm do
  it 'exist' do
    sfm = Sfm.new()
    expect(sfm).to_not be_nil
  end

  describe '#pretty_print_hashes_as_table' do
    it 'should print out a table from a simple hash' do
      test_hash = [{'1' => 'A', '2' => 'B', '3' => 'C', '4' => 'D'}]
      sfm = Sfm.new()
      res = sfm.pretty_print_hashes_as_table(test_hash)
      expect(res.length).to eq(3)
      expect(res[0]).to eq('| 1 | 2 | 3 | 4 ')
      expect(res[1]).to eq('|---|---|---|---')
      expect(res[2]).to eq('| A | B | C | D ')
    end

    it 'should print out a table from a simple hash with longer headers than values' do
      test_hash = [{'11' => 'A', '22' => 'B', '33' => 'C', '44' => 'D'}]
      sfm = Sfm.new()
      res = sfm.pretty_print_hashes_as_table(test_hash)
      expect(res.length).to eq(3)
      expect(res[0]).to eq('| 11 | 22 | 33 | 44 ')
      expect(res[1]).to eq('|----|----|----|----')
      expect(res[2]).to eq('| A  | B  | C  | D  ')
    end

    it 'should print out a table from a simple hash with longer values than headers' do
      test_hash = [{'1' => 'AA', '2' => 'BB', '3' => 'CC', '4' => 'DD'}]
      sfm = Sfm.new()
      res = sfm.pretty_print_hashes_as_table(test_hash)
      expect(res.length).to eq(3)
      expect(res[0]).to eq('| 1  | 2  | 3  | 4  ')
      expect(res[1]).to eq('|----|----|----|----')
      expect(res[2]).to eq('| AA | BB | CC | DD ')
    end
  end
end