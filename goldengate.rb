#!/usr/bin/ruby 
#
# Copyright (C) 2012 Jason Aras
#
# goldengate.rb is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published
# by the Free Software Foundation, either version 3 of the License,
# or (at your option) any later version.
#
# goldengate.rb is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with goldengate.rb.  If not, see:
#      http://www.gnu.org/licenses/
#
#
# Modifications:
#
# 2012-Jan-30: Initial version.  Full code authorship: Jason Aras.
#              Comments and GPLv3-or-later boilerplate added with
#              author's permission by Jeff Gehlbach.
#

require 'rubygems'
require 'httparty'

require 'pp'
# l/p/url

$user = 'admin'
$password = 'admin'
$base_url = "http://opennms:8980/opennms/rest/"

class Nodes
  include HTTParty
  base_uri $base_url
  basic_auth $user, $password
  format :xml
  
end

response = Nodes.get('/nodes', :query => {:limit => 0})

x = response.parsed_response

x["nodes"]["node"].each do |node|
  if node["label"] == ARGV[0]
     # currently just use 3 csv lists in the comments field
     #pp node
     comments = node['assetRecord']['comment']
     #puts comments
     
    comments.each do |line|
      line.strip!
       
       if line.lstrip.match(/^puppet/)  &&  ((line.include? "environment") || (line.include? "parameters") || (line.include? "classes"))
          #puts line
          
          if (line.include? "environment")
             @environment = line[line.index(':')+1..line.length].strip
          
          elsif (line.include? "classes")
             @classes = line[line.index(':')+1..line.length].split(',')
             @classes.collect! { |x| x.strip!}       
          elsif (line.include? "parameters")
            @parameters = {}
            kvpairs = line[line.index(':')+1..line.length].split(',')
            kvpairs.each do |str|
                (k,v) = str.split("=")
                @parameters[k.strip] = v.strip
              
            end
          end  
       end
    end
    #pp @environment
    #pp @classes
    #pp @parameters
   end
   
end

 output = {}
 output['classes'] = @classes
 output['parameters'] = @parameters
 output['environment'] = @environment
 puts output.to_yaml
