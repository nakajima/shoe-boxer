require 'rubygems' unless defined?(Gem)
require 'open-uri'
require 'hpricot'
require 'cgi'
require File.join(File.dirname(__FILE__), 'lib', 'shoebox_app')

class ShoeBoxer < Shoes
  url '/', :index
  url '/view/(\d+)', :view
  
  def index
    style(Para, :font => 'Georgia')
    style(Title, :font => 'Georgia')
    style(Link, :underline => false, :stroke => '#444', :font => 'Georgia')
    style(LinkHover, :underline => false, :fill => '#0af', :stroke => white, :font => 'Georgia')

    background '#0a0a0a'

    stack do
      title strong("the shoeboxer", :stroke => white), :margin_left => 10
    end

    container = flow(:margin_left => 10, :width => 500) do
      apps.each do |app|
        stack do
          para link(strong(app.name), :click => "/view/#{app.id}"), :font => '20px'
        end
      end
    end
  end
  
  def view(id)
    app = ShoeboxApp.list[id]
    
    style(Para, :font => 'Georgia')
    style(Title, :font => 'Georgia')
    style(Link, :underline => false, :stroke => '#444')
    style(LinkHover, :underline => false, :fill => '#0af', :stroke => white)

    background '#111'
    
    stack(:margin => 10) do
      flow do
        flow { title strong(app.name.upcase, :stroke => white) }
      end
      
      stack do
        app.description.each do |p|
          next if p.match(/instructions/i)
          para CGI::unescapeHTML(p), :stroke => '#ccc'
        end

        subtitle "VERSIONS", :stroke => '#fff'
        
        para "Click a version to run it in Shoes (.rb files only for now...)", :stroke => '#ccc'
        
        app.versions.each do |name, info|
          stack do
            if info[:url] && (info[:type] == '.rb')
              para link(strong(name, " (#{info[:type]})"), :click => proc { Shoes.load(info[:url]) })
            else
              para link(strong(name),
                " (#{info[:type]})",
                :click => proc { alert("WHOOPS! You can only run .rb files from here. Sorry!") })
            end
          end
        end
        
        stack { para link("GO BACK", :click => "/") }
      end
    end
  end
  
  def apps
    @apps ||= ShoeboxApp.list.values.sort_by { |a| a.name }
  end
end

Shoes.app :width => 500