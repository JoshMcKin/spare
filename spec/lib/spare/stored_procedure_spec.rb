require 'spec_helper'
require 'byebug'
class SpInsert < ActiveRecord::StoredProcedure
  validates :p_name, presence: true
end

class Foo < ActiveRecord::Base;end

describe ActiveRecord::StoredProcedure do
  it {expect(SpInsert.stored_procedure_name).to eql('sp_insert') }

  context 'attributes' do
    let(:sp_insert) {SpInsert.new}

    it { expect(sp_insert).to respond_to(:p_name, :p_deci, :p_date, :o_id) }
  end

  describe '#execute' do
    let (:sp_insert) { SpInsert.new(:p_name => "foo",:p_deci => 2.0, :p_date => Date.today, :in_out_add => 4) }

    it { expect(sp_insert).to be_valid}

    it { expect(sp_insert.execute).to eql(true) }

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

  context "class methods" do
    context "#execute" do
      it "should work" do
        expect {
          SpInsert.execute(:p_name => "foo",:p_deci => 2.0, :p_date => Date.today, :in_out_add => 4)
        }.to change(Foo, :count).by(1)
      end

      context "out parameters" do
        it "should work" do
          sp = SpInsert.execute(:p_name => "foo",:p_deci => 2.0, :p_date => Date.today, :in_out_add => 4)
          expect(sp.o_id).to be_a(Fixnum)
        end
      end

      context "inout parameters" do
        it "should work" do
          sp = SpInsert.execute(:p_name => "foo",:p_deci => 2.0, :p_date => Date.today, :in_out_add => 4)
          expect(sp.in_out_add).to eql(5)
        end
      end
    end

    context "#execute!" do
      context "not valid" do
        it "should work" do
          expect { SpInsert.execute! }.to raise_error(ActiveRecord::StoredProcedureNotExecuted)
        end
      end
    end
  end
end
