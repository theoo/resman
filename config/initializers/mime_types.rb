# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf


require "railspdf"  #  Made lowercase so will work in linux  -- tomw
#require "ActionView"

# ActionView::Template.register_template_handler 'rpdf', RailsPDF::Renderer.new
ActionView::Template.register_template_handler 'rpdf', -> (template) {
  eval template.source
}

# Mime::Type.register "application/pdf", :pdf

