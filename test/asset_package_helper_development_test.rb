ENV['RAILS_ENV'] = "development"

$:.unshift(File.dirname(__FILE__))
require 'test_helper'

class AssetPackageHelperDevelopmentTest < ActionView::TestCase
  include RailsAssetPackager::AssetPackageHelper

  def setup
    RailsAssetPackager::AssetPackage.asset_base_path    = "#{Rails.root}/vendor/plugins/asset_packager/test/assets"
    RailsAssetPackager::AssetPackage.asset_packages_yml = YAML.load_file("#{Rails.root}/vendor/plugins/asset_packager/test/asset_packages.yml")

    RailsAssetPackager::AssetPackage.any_instance.stubs(:log)
  end

  def build_js_expected_string(*sources)
    sources.map {|s| javascript_include_tag(s) }.join("\n")
  end

  def build_css_expected_string(*sources)
    sources.map {|s| stylesheet_link_tag(s) }.join("\n")
  end

  def test_js_basic
    assert_dom_equal build_js_expected_string("prototype"),
      javascript_include_merged("prototype")
  end

  def test_js_multiple_packages
    assert_dom_equal build_js_expected_string("prototype", "foo"),
      javascript_include_merged("prototype", "foo")
  end

  def test_js_unpackaged_file
    assert_dom_equal build_js_expected_string("prototype", "foo", "not_part_of_a_package"),
      javascript_include_merged("prototype", "foo", "not_part_of_a_package")
  end

  def test_js_multiple_from_same_package
    assert_dom_equal build_js_expected_string("prototype", "effects", "controls", "not_part_of_a_package", "foo"),
      javascript_include_merged("prototype", "effects", "controls", "not_part_of_a_package", "foo")
  end

  def test_js_by_package_name
    assert_dom_equal build_js_expected_string("prototype", "effects", "controls", "dragdrop"),
      javascript_include_merged(:base)
  end

  def test_js_multiple_package_names
    assert_dom_equal build_js_expected_string("prototype", "effects", "controls", "dragdrop", "foo", "bar", "application"),
      javascript_include_merged(:base, :secondary)
  end

  def test_css_basic
    assert_dom_equal build_css_expected_string("screen"),
      stylesheet_link_merged("screen")
  end

  def test_css_multiple_packages
    assert_dom_equal build_css_expected_string("screen", "foo", "subdir/bar"),
      stylesheet_link_merged("screen", "foo", "subdir/bar")
  end

  def test_css_unpackaged_file
    assert_dom_equal build_css_expected_string("screen", "foo", "not_part_of_a_package", "subdir/bar"),
      stylesheet_link_merged("screen", "foo", "not_part_of_a_package", "subdir/bar")
  end

  def test_css_multiple_from_same_package
    assert_dom_equal build_css_expected_string("screen", "header", "not_part_of_a_package", "foo", "bar", "subdir/foo", "subdir/bar"),
      stylesheet_link_merged("screen", "header", "not_part_of_a_package", "foo", "bar", "subdir/foo", "subdir/bar")
  end

  def test_css_by_package_name
    assert_dom_equal build_css_expected_string("screen", "header"),
      stylesheet_link_merged(:base)
  end

  def test_css_multiple_package_names
    assert_dom_equal build_css_expected_string("screen", "header", "foo", "bar", "subdir/foo", "subdir/bar"),
      stylesheet_link_merged(:base, :secondary, "subdir/styles")
  end

end
