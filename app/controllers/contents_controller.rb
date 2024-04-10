class ContentsController < ApplicationController
  private

  def method_missing(method, *args, &block)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, extensions = {})
    c = Content.for(args.first, I18n.locale)

    unless c.nil?
      @content = markdown.render(c.content)
      @title.push c.title
    else
      @content = ""
    end

    render :show
  end

  def respond_to_missing?(method, include_private = false)
    true
  end
end
