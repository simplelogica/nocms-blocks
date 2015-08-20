require 'spec_helper'

require "generator_spec"

require_relative '../../../lib/generators/nocms/blocks/layout_generator.rb'

describe NoCms::Blocks::LayoutGenerator, type: :generator do

  TMP_ROOT = File.expand_path("../../../../tmp", __FILE__)
  destination TMP_ROOT

  arguments %w(test_name)

  before do
    prepare_destination
    run_generator
  end

  after do
    FileUtils.rm_rf(TMP_ROOT)
  end

  specify "should create the structure" do
    expect(destination_root).to have_structure {
      directory "config" do
        directory "initializers" do
          directory "nocms" do
            directory "blocks" do
              file "test_name.rb" do
                contains "'test_name'"
              end
            end
          end
        end
      end
      directory "app" do
        directory "views" do
          directory "no_cms" do
            directory "blocks" do
              directory "blocks" do
                file "_test_name.html.erb" do
                  contains 'class="block test_name"'
                end
              end
            end
            directory "admin" do
              directory "blocks" do
                directory "blocks" do
                  file "_test_name.html.erb"
                end
              end
            end
          end
        end
      end
    }
  end
end
