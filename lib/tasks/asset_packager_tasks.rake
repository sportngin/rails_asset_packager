require 'yaml'
require 'digest/md5'
require File.dirname(__FILE__) + '/../rails_asset_packager/asset_package'

namespace :asset do
  namespace :packager do

    desc "Merge and compress assets"
    task :build_all do
      RailsAssetPackager::AssetPackage.build_all
    end

    desc "Delete all asset builds"
    task :delete_all do
      RailsAssetPackager::AssetPackage.delete_all
    end

    desc "Generate asset_packages.yml from existing assets"
    task :create_yml do
      RailsAssetPackager::AssetPackage.create_yml
    end

  end

  namespace :cache do
    task :config do
      S3_CONFIG = YAML.load_file(File.join(Rails.root, "config/s3.yml"))[Rails.env] rescue nil || {}
      ASSET_PKG_CONFIG = YAML.load_file(File.join(Rails.root, "config/asset_packages.yml")) rescue nil || {}
    end

    desc "start aws"
    task :aws => :config do
      require 'aws/s3'

      AWS::S3::Base.establish_connection!(
        :access_key_id => S3_CONFIG['access_key_id'],
        :secret_access_key => S3_CONFIG['secret_access_key']
      )
    end

    desc "update s3"
    task :s3 => :aws do
      prefix = ''

      files = []

      ASSET_PKG_CONFIG.keys.each do |set|
        if set == 'javascripts' || set == 'stylesheets'
          ext = (set == 'javascripts') ? "js" : "css"

          ASSET_PKG_CONFIG[set].each do |val|
            val.keys.each do |val|
              files << "./public/#{set}/#{val}_packaged.#{ext}"
            end
          end
        elsif set == 'uploads'
          ASSET_PKG_CONFIG[set].each do |val|
            if File.directory?("./public/#{val}")
              files = files + Dir.glob("./public/#{val}/**/*.*")
            end
          end

          files.uniq!
        end
      end

      files.each do |f|
        next if File.directory?(f)

        key = f.gsub(/\.\/public/, prefix)
        puts "#{f} -> #{key}"

        unless AWS::S3::S3Object.exists?(key, S3_CONFIG['bucket']) && AWS::S3::S3Object.about(key, S3_CONFIG['bucket'])['x-amz-meta-checksum'] == Digest::MD5.file(f).to_s
          AWS::S3::S3Object.store(
            key,
            File.open(f),
            S3_CONFIG['bucket'],
            :access => :public_read,
            'Cache-Control' => 'max-age=315360000',
            'x-amz-storage-class' => 'REDUCED_REDUNDANCY',
            'x-amz-meta-checksum' => Digest::MD5.file(f).to_s
          )
        end
      end
    end

    desc "cache assets and update s3 for production"
    task :production do
      Rake::Task['asset:packager:delete_all'].invoke
      Rake::Task['asset:packager:build_all'].invoke
      Rake::Task['asset:cache:s3'].invoke
    end
  end
end
