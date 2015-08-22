#!/usr/bin/env ruby

require 'nokogiri'
require 'pathname'

doc = ARGF.read
html = Nokogiri::HTML(doc)
file = 'immutable-js.html'
sql = []

modules = html.css(".tsd-kind-module:has(a[name=immutable]) > .tsd-parent-kind-module")
modules.each do |mod|
  children = mod.children

  a, h3 = children.filter('a[name], h3')

  sql << "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ('#{h3.text}', 'Class', '#{file}##{a['name']}');"

  children.css('.tsd-panel.tsd-kind-property').each do |property|
    a, h3 = property.children.filter('a, h3')
    sql << "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ('#{h3.text}', 'Property', '#{file}##{a['name']}');"
  end
  
  children.css('.tsd-panel.tsd-kind-method').each do |method|
    a, h3 = method.children.filter('a, h3')
    sql << "INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ('#{h3.text}', 'Method', '#{file}##{a['name']}');"
  end
end



path = Pathname('Contents/Resources')
path.mkpath

create = %q{
  CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT);
  CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path);
}
sqlite = IO.popen("sqlite3 #{path.join('docSet.dsidx')}" , 'r+' )

sqlite << create << sql.compact.join("\n")

documents = path.join('Documents')
documents.mkpath

documents.join(file).open('w') do |f|
  f.puts(doc)
end

