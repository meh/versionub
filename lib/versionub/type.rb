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
  attr_reader :name

  def initialize (name, &block)
    @name = name

    @klass = Class.new {
      attr_reader :type, :data

      def initialize (type, data)
        @type = type
        @data = data
      end
    }

    instance_eval &block
  end

  def parse (text)
    data = parser.new.parse(text)

    if transformer
      data = transformer.apply(data)
    end

    @klass.new(name, data)
  end

  def parser (&block)
    if block
      @parser = Class.new(Parslet::Parser)
      @parser.class_eval(&block)
    end

    @parser
  end

  def transformer (&block)
    if block
      @transformer = Class.new(Parslet::Transform)
      @transformer.class_eval(&block)
    end

    @transformer
  end

  def callbacks (&block)
    @klass.class_eval &block

    @klass.instance_methods
  end
end

end
