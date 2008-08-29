class ShoeboxApp
  attr_accessor :link_url, :thumb, :id
  
  def self.list
    @list ||= begin
      doc = Hpricot(open('http://the-shoebox.org'))
      doc.search("#app_grid > a").inject({ }) do |memo, app|
        shoe = ShoeboxApp.new(app)
        memo[shoe.id] = shoe
        memo
      end
    end
  end
  
  def initialize(element)
    self.link_url = element['href']
    self.thumb = element.at('img')['src']
    self.id = link_url.split('/').last
    @_name = element.at('h6').inner_html
  end
  
  def description
    page.at('.description_display').search('p').map { |p| Hpricot(p.inner_html).to_plain_text }
  end
  
  def name
    @name ||= begin
      @_name.match(/\.\.\.\s*$/) ? page.at('title') \
        .inner_html \
        .split('&mdash;') \
        .last \
        .strip :  @_name
    end
  end
  
  def versions
    @version ||= page.search('.version').inject({}) do |memo, node|
      version_name = node.at('a').inner_html
      memo[version_name] = {
        :url => node.at('a')['href'],
        :type => node.at('div').inner_html.strip
      }
      memo
    end
  end
  
  def image
    @image ||= page.at('.app_polaroid_image')['src'] rescue nil
  end
  
  private
  
  def page
    @page ||= Hpricot(open(link_url))
  end
end
