# frozen_string_literal: true

# ----------------------------------------------
#  Class for Youtube (youtube.com)
#  http://www.youtube.com/watch?v=MVa4q-YVjD8
# ----------------------------------------------

class VgYoutube
  def initialize(url = nil, options = {})
    settings ||= begin
                   YAML.load_file(RAILS_ROOT + '/config/unvlogable.yml')
                 rescue StandardError
                   {}
                 end
    Yt.configure do |config|
      config.api_key = options.nil? || options[:key].nil? ? settings['youtube_key'] : options[:key]
    end

    @url = url
    @video_id = @url.query_param('v')
    begin
      @details = Yt::Video.new(id: @video_id)
      raise if @details.blank?
    rescue StandardError
      raise ArgumentError, 'Unsuported url or service'
    end
  end

  def title
    @details.title
  end

  def thumbnail
    @details.thumbnail_url
  end

  def duration
    @details.duration
  end

  def video_id
    @video_id
  end

  def embed_url
    "http://www.youtube.com/embed/#{@video_id}"
  end

  # iframe embed — https://developers.google.com/youtube/player_parameters#Manual_IFrame_Embeds
  def embed_html(width = 425, height = 344, options = {}, _params = {})
    if @details.embeddable?
      "<iframe id='ytplayer' type='text/html' width='#{width}' height='#{height}' src='#{embed_url}#{options.map { |k, v| "&#{k}=#{v}" }}' frameborder='0'/>"
    elsif @details.embed_html.present?
      @details.embed_html
    end
  end

  def service
    'Youtube'
  end
end
