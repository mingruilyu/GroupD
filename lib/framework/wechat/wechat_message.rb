module WechatMessage
  class Message
    attr_reader :from_user_name, :type, :create_time, :to_user_name
    def self.create(hash)
      hash.symbolize_keys!
      case hash[:MsgType]
      when 'event'
        case hash[:Event].downcase
        when 'subscribe'
          SubscribeEvent.new hash
        when 'location'
          LocationEvent.new hash
        else
        end
      when 'text'
        Text.new hash
      when 'image'
        Image.new hash
      when 'news'
        News.new 
      else
      end
    end

    def initialize(hash)
      @from_user_name = hash[:FromUserName]
      @type = hash[:MsgType]
      @create_time = hash[:CreateTime]
      @to_user_name = hash[:ToUserName]
    end
  end

  class Text < Message
    attr_reader :content
    def initialize(hash)
      super hash
      @content = hash[:Content]
    end

    def to_xml(options={})
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.xml do
          xml.ToUserName do
            xml.cdata @to_user_name
          end
          xml.FromUserName do
            xml.cdata @from_user_name
          end
          xml.CreateTime @create_time
          xml.MsgType do
            xml.cdata @type
          end
          xml.Content do
            xml.cdata @content
          end
        end
      end
      builder.to_xml
    end
  end

  class Image < Message
    attr_reader :image_url
    def initialize(hash)
      super hash
      @image_url = hash[:PicUrl]
    end

    def dispatch
    end
  end

  class Event < Message
    attr_reader :event
    def initialize(hash)
      super hash
      @event = hash[:Event].downcase
    end
  end

  class SubscribeEvent < Event
    def initialize(hash)
      super hash
    end
  end

  class ClickEvent < Event
    attr_reader :key
    def initialize(hash)
      super hash
      @event = hash[:EventKey]
    end

  end

  class LocationEvent < Event
    attr_reader :latitude, :longitude, :precision
    def initialize(hash)
      super hash
      @latitude = hash[:Latitude].to_f
      @longitude = hash[:Longitude].to_f
      @precision = hash[:Precision].to_f
    end
  end

  class News
    attr_reader :title, :description, :pic_url, :url
    def initialize(hash={})
      @title = hash[:title]
      @description = hash[:description]
      @pic_url = hash[:pic_url]
      @url = hash[:url]
    end
  end

  class NewsGroup < Message
    def initialize(hash, articles)
      super hash
      @type = 'news'
      @article_count = articles.size
      @articles = articles
    end

    def to_xml(options={})
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.xml do
          xml.ToUserName do
            xml.cdata @to_user_name
          end
          xml.FromUserName do
            xml.cdata @from_user_name
          end
          xml.CreateTime @create_time
          xml.MsgType do
            xml.cdata @type
          end
          xml.ArticleCount @articles.size
          xml.Articles do
            @articles.each do |article|
              xml.item do
                xml.Title do
                  xml.cdata article.title
                end
                xml.Description do
                  xml.cdata article.description
                end
                xml.PicUrl do
                  xml.cdata article.pic_url
                end
                xml.Url do 
                  xml.cdata article.url
                end
              end
            end
          end
        end
      end
      builder.to_xml
    end
  end
end
