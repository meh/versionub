#! /usr/bin/env ruby
require 'rubygems'
require 'versionub'
require 'versionomy'

describe Versionub do
  describe '.parse' do
    it 'returns the same as Versionomy for 1.2.3a2' do
      a = Versionub.parse('1.2.3a2')
      b = Versionomy.parse('1.2.3a2')

      a.major.should == b.major
      a.minor.should == b.minor
      a.tiny.should  == b.tiny
      a.tiny2.should == b.tiny2

      a.release_type.should == b.release_type

      a.alpha.should == b.alpha_version
    end

    it 'returns 2008.2 for Versionub.parse("2008 SP2", :windows)' do
      Versionub.parse('2008 SP2', :windows) == '2008.2'
    end
  end

  describe '.create' do
    it 'returns the same as Versionomy for { major: 1, minor: 3, tiny: 2 }' do
      a = Versionub.create(major: 1, minor: 3, tiny: 2)
      b = Versionomy.create(major: 1, minor: 3, tiny: 2)

      a.major.should == b.major
      a.minor.should == b.minor
      a.tiny.should  == b.tiny
      a.tiny2.should == b.tiny2

      a.release_type.should == b.release_type

      a.patchlevel.should == b.patchlevel
    end
  end
end

describe Versionub::Type::Instance do
  it 'returns true for 1.4a3 > 1.3.2 ' do
    '1.4a3'.to_version.should > '1.3.2'
  end

  it 'returns true for 1.4.0b2 > 1.4a3' do
    '1.4.0b2'.to_version.should > '1.4a3'
  end

  it 'returns true for 2.0.0-1 == 2.0p1' do
    '2.0.0-1'.to_version.should == '2.0p1'
  end
end
