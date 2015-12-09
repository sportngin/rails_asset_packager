require 'rails'

module RailsAssetPackager
  class Railtie < Rails::Railtie
    initializer "RailsAssetPackager.initialize" do
      ActionView::Base.send :include, RailsAssetPackager::AssetPackageHelper
    end
    
    rake_tasks do
      load "tasks/asset_packager_tasks.rake"
    end
  end
end
