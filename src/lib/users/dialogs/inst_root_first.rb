# encoding: utf-8

# ------------------------------------------------------------------------------
# Copyright (c) 2006-2012 Novell, Inc. All Rights Reserved.
#
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of version 2 of the GNU General Public License as published by the
# Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, contact Novell, Inc.
#
# To contact Novell about this file by physical or electronic mail, you may find
# current contact information at www.novell.com.
# ------------------------------------------------------------------------------

require "users/widgets"
require "users/ca_password_validator"
require "users/local_password"
require "users/widgets/public_key_selector"

require "ui/widgets"


module Yast
  # This library provides a simple dialog for setting new password for the
  # system adminitrator (root) including checking quality of the password
  # itself. The new password is not stored here, just set in UsersSimple module
  # and stored later during inst_finish.
  class InstRootFirstDialog
    include Yast::Logger
    include Yast::I18n
    include Yast::UIShortcuts

    def run
      Yast.import "UI"
      Yast.import "Mode"
      Yast.import "UsersSimple"
      Yast.import "CWM"

      textdomain "users"

      return :auto unless root_password_dialog_needed?

      # We do not need to create a wizard dialog in installation, but it's
      # helpful when testing all manually on a running system
      Wizard.CreateDialog if separate_wizard_needed?

      Wizard.SetTitleIcon("yast-users")

      ret = CWM.show(
        content,
        # Title for root-password dialogue
        caption: _("Password for the System Administrator \"root\""),
      )

      Wizard.CloseDialog if separate_wizard_needed?

      ret
    end

  private

    # Returns a UI widget-set for the dialog
    def content
      VBox(
        VStretch(),
        HSquash(
          VBox(
            ::Users::PasswordWidget.new(focus: true),
            VSpacing(2.4),
            ::UI::Widgets::KeyboardLayoutTest.new,
            VSpacing(2.4),
            ::Y2Users::Widgets::PublicKeySelector.new,
          )
        ),
        VStretch()
      )
    end

    # Returns whether we need/ed to create new UI Wizard
    def separate_wizard_needed?
      Mode.normal
    end

    # Returns whether we need to run this dialog
    def root_password_dialog_needed?
      if UsersSimple.RootPasswordDialogSkipped
        log.info "root password was set with first user, skipping"
        return false
      end

      true
    end
  end
end
