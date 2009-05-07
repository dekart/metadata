module Metadata::ControllerExtensions
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.send(:helper_method, :metadata)
  end

  module InstanceMethods
    def metadata
      @metadata ||= ::Metadata::Base.new({})
    end
  end
end

ActionController::Base.send(:include, Metadata::ControllerExtensions)