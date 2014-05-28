require 'sequel'

DB = Sequel.connect('sqlite://db/development.db')

class Doctor < Sequel::Model; end
