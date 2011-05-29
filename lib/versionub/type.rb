#--
# Copyleft meh. [http://meh.paranoid.pk | meh@paranoici.org]
#
# This file is part of versionub.
#
# versionub is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# versionub is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with versionub. If not, see <http://www.gnu.org/licenses/>.
#++

require 'parslet'

module Versionub

class Type
  class Instance
    def self.parser (&block)
      if block
        @parser = Class.new(Parslet::Parser)
        @parser.class_eval(&block)
      end

      @parser
    end

    def self.transformer (&block)
      if block
        @transformer = Class.new(Parslet::Transform)
        @transformer.class_eval(&block)
      end

      @transformer
    end

    attr_reader :type

    def initialize (type, text, data)
      @type = type
      @text = text
      @data = data
    end

    def to_hash
      @data.clone
    end

    def to_s
      @text
    end
  end

  attr_reader :name

  def initialize (name, &block)
    @name     = name
    @instance = Class.new(Instance)

    @instance.instance_eval &block
  end

  def parse (text)
    data = @instance.parser.new.parse(text)

    if @instance.transformer
      data = @instance.transformer.apply(data)
    end

    @instance.new(name, text, data)
  end

end

end
