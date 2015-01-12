require 'spec_helper'

class SpInsert < ActiveRecord::StoredProcedure;end

class Foo < ActiveRecord::Base;end

describe ActiveRecord::StoredProcedure do
  it {expect(SpInsert.stored_procedure_name).to eql('sp_insert') }

  context 'attributes' do
    let(:sp_insert) {SpInsert.new}

    it { expect(sp_insert).to respond_to(:p_name, :p_deci, :p_date, :o_id) }
  end

  describe '#execute' do
    let (:sp_insert) {SpInsert.new(:p_name => "foo",:p_deci => 2.0, :p_date => Date.today, :in_out_add => 4)}
    it {expect(sp_insert).to be_valid}
    it {expect(sp_insert.execute).to eql(true)}
    it "should work" do
      expect {
        sp_insert.execute
      }.to change(Foo, :count).by(1)
    end
    context "out parameters" do
      it "should work" do
        sp_insert.execute
        expect(sp_insert.o_id).to be_a(Fixnum)
      end
    end
    context "inout parameters" do
      it "should work" do
        sp_insert.execute
        expect(sp_insert.in_out_add).to eql(5)
      end
    end
  end
end
