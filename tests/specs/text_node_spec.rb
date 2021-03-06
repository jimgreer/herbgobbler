require 'backports'
require_relative '../spec_helper'

class TestTextNode
  
  include TextNode
  attr_accessor :text_value
  def initialize( string )
    @text_value = string
  end
end

describe TextNode do
  it "should be able to see that a double quoted string has a variable in it" do
    erb_file = ErbFile.from_string( '<%= "test #{"data"}" %>' )
    erb_file.nodes.size.should == 6
    erb_file.nodes[2].text_value == '"test '
    erb_file.nodes[3].text_value == '#{"data"}'
    erb_file.nodes[4].text_value == '"'
  end

  it "should be able to see that a string doesn't have a variable in it" do
    erb_file = ErbFile.from_string( 'test' )
    erb_file.nodes.size.should == 1
    erb_file.nodes.first.has_variables?.should == false
  end

  it "should not think that a regular string has variables" do
    erb_file = ErbFile.from_string( '"test #{"data"}"' )
    erb_file.nodes.size.should == 1
    erb_file.nodes[0].has_variables?.should == false
  end

  it "should make the appropriate text call backs for a simple string with erb text in it" do
    erb_file = ErbFile.from_string " test <%= 'this' %> works  "
  end


  it "should remove all of the whitespace from the front of the node and add it as a separate node before the actual text" do
    string = "     abc";
    result = "     ";

    results = TestTextNode.new( string ).remove_leading_and_trailing_whitespace
    results.first.text_value.should == result
    results.last.text_value.should == string.lstrip
  end

  it "should remove all of the whitespace from the rear of the node and add it as a separate node after the actual text" do
    result = "     ";    
    string = "abc" + result;

    results = TestTextNode.new( string ).remove_leading_and_trailing_whitespace
    results.first.text_value.should == string.rstrip    
    results.last.text_value.should == result
  end

  it "should remove all of the whitespace from both the front and the rear of a text node and attach separate nodes on either side of text to represent the whitespace" do
    front_ws = "   "
    rear_ws = "        "
    string = front_ws + "abc" + rear_ws

    results =  TestTextNode.new( string ).remove_leading_and_trailing_whitespace
    results.first.text_value.should == front_ws
    results[1].text_value.should == "abc"
    results.last.text_value.should == rear_ws
    
  end

  it "should be able to handle spacing around multiple lines" do
    rear_ws = "    "
    string = "abc\n       123" + rear_ws

    results = TestTextNode.new( string ).remove_leading_and_trailing_whitespace
    results.first.text_value.should ==  "abc\n       123"
    results.last.text_value == rear_ws
  end
  
  it "should be able to find a text node with alpha numberic characters" do
     TestTextNode.new( "abc123" ).contains_alpha_characters?.should == true
  end

  it "should mark contains alpha numeric characters as false if it is all numbers" do
     TestTextNode.new( "123" ).contains_alpha_characters?.should == false    
  end
  
  it "should mark contains alpha numeric characters as false if it is all punctuation" do
     TestTextNode.new( "|" ).contains_alpha_characters?.should == false        
  end

  it "should mark contains alpha numeric characters as false if it is all whitespace" do
     TestTextNode.new( "  \n  " ).contains_alpha_characters?.should == false        
  end
  
end

