require 'spec_helper'

describe Thebes::Query, "after configuration" do

  before(:all) {
    Thebes::Query.servers = [['127.0.0.2', 111]]
  }

  subject { Thebes::Query.new }

  its(:servers) { should == ['127.0.0.2'] }
  its(:port)    { should == 111 }

  context "running query" do
    
    before(:each) {
      Thebes::Query.any_instance.stubs(:run)
    }

    after(:each) {
      Thebes::Query.run {|q| }
    }

    it "should run the query on an instance" do
      Thebes::Query.any_instance.expects(:run)
    end

    it "should call the before_query callback" do
      Thebes::Query.before_query = Proc.new {|q| }
      Thebes::Query.before_query.expects(:call)
    end

    it "should call the before_running callback" do
      Thebes::Query.before_running = Proc.new {|q| }
      Thebes::Query.before_running.expects(:call)
    end

  end

end

describe Thebes::Query, "against live data" do

  let(:create_items!) do
    Thebes::Query.servers = [['127.0.0.1', 9333]]
    Item.create \
      :name => "Larry",
      :active => true,
      :body => "Fine was born to a Jewish family as Louis Feinberg[1] in Philadelphia, Pennsylvania, at the corner of 3rd and South Streets. The building there is now a restaurant which is called Jon's Bar & Grill."
    Item.create \
      :name => "Moe",
      :active => true,
      :body => "Moses Horwitz was born in Brooklyn, New York, neighborhood of Brownsville, to Solomon Horwitz and Jennie Gorovitz. He was the fourth of the five Horwitz brothers and of Levite and Lithuanian Jewish ancestry."
    Item.create \
      :name => "Curly",
      :active => false,
      :body => "Curly Howard was born Jerome Lester Horwitz in Brownsville, a section of Brooklyn, New York. He was the fifth of the five Horwitz brothers and of Lithuanian Jewish ancestry."
    Item.create \
      :name => "Shemp",
      :active => true,
      :body => "Shemp, like his brothers Moe and Curly, was born in Brownsville, Brooklyn. He was the third of the five Horwitz brothers and of Levite[citation needed] and Lithuanian Jewish ancestry."
    SPHINX.index
  end

  context "searching for 'Horwitz'" do
    before(:each) do
      create_items!
      SPHINX.index

      @result = Thebes::Query.run do |q|
        q.append_query('Horwitz', 'items')
      end
    end

    let(:matches){ @result.first[:matches] }

    it 'should return 3 matches' do
      matches.size.should eql 3
    end

    it 'should return id #2' do
      matches.first[:attributes]['_id'].should eql 2
    end

    it 'should return id #4' do
      matches.last[:attributes]['_id'].should eql 4
    end
  end

  context "searching for 'Horwitz' with filter" do
    before(:each) do
      create_items!
      SPHINX.index

      @result = Thebes::Query.run do |q|
        q.filters << Riddle::Client::Filter.new('active', [1])
        q.append_query 'Horwitz', 'items'
      end
    end

    let(:matches){ @result.first[:matches] }

    it 'should return 2 matches' do
      matches.size.should eql 2
    end

    it 'should return id #2' do
      matches.first[:attributes]['_id'].should eql 2
    end

    it 'should return id #4' do
      matches.last[:attributes]['_id'].should eql 4
    end
  end
end
