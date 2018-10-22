require "kemal"

module ImageHost
  extend self

  images = Hash(String, ImageHost::Image).new

  upload_page : String?

  def serve_up

    get "/:id" {|ctx| render_img_page to: ctx, for_id: id }
    get "/" { |ctx| render_upload_page to: ctx}
    get "/img/:id" do |ctx|
      if (id = ctx.params.url["id"]?) && (image = images[id]?).nil?
        not_found to: context
      else
        image.serve to: context
      end
    end
    post "/" do |ctx|
      images[new_image.filename] = Image.from_context ctx
    end

    Kemal.run
  end

  def not_found(to)
    to.response.status_code = 404
    to.response.write "not found".to_slice
    return
  end

  def render_img_page(to, for_id)
    to.response.write ECR.render "img_page.ecr"
  end

  def render_upload_page(to)
    if upload_page.nil?
      File.open "templates/uplaod_page.html" { |f| upload_page = f.gets }
    end
    to.response.write upload_page.to_slice
  end
end
