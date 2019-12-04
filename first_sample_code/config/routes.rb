# config/routes.rb
class ActionDispatch::Routing::Mapper
  def draw(routes_name)
    instance_eval(File.read(Rails.root.join("config/routes/#{routes_name}.rb")))
  end
end

Rails.application.routes.draw do
  draw :business_partners
  draw :crop
  root 'dashboard#index'
end
