require 'spec_helper'
describe  ActiveRecord::ConnectionAdapters::AbstractMysqlAdapter do

  describe '#stored_procedure' do

    context "stored procedure does not exist" do
      it {expect(ActiveRecord::Base.connection.stored_procedure("bad")).to be_nil}
    end

    context "stored procedure does exist" do
      before(:each) do
        conn = ActiveRecord::Base.connection
        conn.execute("DROP procedure IF EXISTS `sp_test_adapter`;")
        conn.execute(%q{CREATE PROCEDURE `sp_test_adapter`(
                          IN  p_name            VARCHAR(255)  ,
                          IN  p_bar           	DECIMAL(10,2) ,
                          IN  p_other           DATE		  ,
                          OUT results			INT(11)
                        )
                        BEGIN
                        END})
      end
      context "called with the stored procedure's name" do
        let (:sp) {ActiveRecord::Base.connection.stored_procedure("sp_test_adapter")}
        it {expect(sp).to be_a(Hash)}
        it {expect(sp[:param_list]).to be_a(Array)}
      end

      context "called the stored procedure and database name" do
        let (:sp) {ActiveRecord::Base.connection.stored_procedure("sp_test.sp_test_adapter")}
        it {expect(sp).to be_a(Hash)}
        it {expect(sp[:param_list]).to be_a(Array)}
      end
    end
  end

  describe '#stored_procedure_params' do
    let (:sp_params) { %q{IN  p_name            VARCHAR(255)  ,
                          IN  p_bar           	DECIMAL(10,2) ,
                          IN  p_other           DATE		  ,
                          OUT results			INT(11)}
                       }
    let (:parsed_params) {ActiveRecord::Base.connection.stored_procedure_params(sp_params, 'utf8_general_ci')}

    it {expect(parsed_params).to be_a(Array)}
    it {expect(parsed_params.length).to eql(4)}
    it {expect(parsed_params[0]).to be_a(ActiveRecord::ConnectionAdapters::Mysql2Adapter::Column)}
    it {expect(parsed_params[0].collation).to eql('utf8_general_ci')}
    it {expect(parsed_params[0].param_type).to eql('IN')}
    it {expect(parsed_params[0].name).to eql('p_name')}
    it {expect(parsed_params[0].type).to eql(:string)}
    it {expect(parsed_params[1].param_type).to eql('IN')}
    it {expect(parsed_params[1].name).to eql('p_bar')}
    it {expect(parsed_params[1].type).to eql(:decimal)}
    it {expect(parsed_params[2].param_type).to eql('IN')}
    it {expect(parsed_params[2].name).to eql('p_other')}
    it {expect(parsed_params[2].type).to eql(:date)}
    it {expect(parsed_params[3].param_type).to eql('OUT')}
    it {expect(parsed_params[3].name).to eql('results')}
    it {expect(parsed_params[3].type).to eql(:integer)}
  end
end
