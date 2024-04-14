class HomeController < ApplicationController
  def index
    content = Content.for('instance-info', I18n.locale)
    unless content.nil?
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, extensions = {})
      @instance_info_text = markdown.render(content.content)
      @instance_info_title = content.title
    end
  end
end
