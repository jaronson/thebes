require 'spec_helper'

describe Thebes::Query, "against live data" do

  let(:create_items!) do
    Thebes::Sphinxql::Client.servers = [{ :host => '127.0.0.1', :port => 9334 }]

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

      @result = Thebes::Sphinxql::Query.run "SELECT * FROM items WHERE MATCH('Horwitz')"
    end

    let(:matches){ @result.collect{|r| r }}

    it 'should return 3 matches' do
      matches.size.should eql 3
    end

    it 'should return id #2' do
      puts matches.inspect
      matches.last['_id'].should eql 2
    end

    it 'should return id #4' do
      matches.first['_id'].should eql 4
    end
  end

  context "searching for 'Horwitz' with filter" do
    before(:each) do
      create_items!
      SPHINX.index

      @result = Thebes::Sphinxql::Query.run "SELECT * FROM items WHERE MATCH('Horwitz') AND active = 1"
    end

    let(:matches){ @result.collect{|r| r }}

    it 'should return 2 matches' do
      matches.size.should eql 2
    end

    it 'should return id #2' do
      matches.last['_id'].should eql 2
    end

    it 'should return id #4' do
      matches.first['_id'].should eql 4
    end
  end
end
