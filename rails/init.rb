require 'jgrowl_flash_messages'

ActionController::Base.send( :include, JGrowlFlashMessages::ControllerHelpers )
ActionView::Base.send( :include, JGrowlFlashMessages::ViewHelpers )