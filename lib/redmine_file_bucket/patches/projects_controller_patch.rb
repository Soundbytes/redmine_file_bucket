require_dependency 'projects_controller'


module RedmineFileBucket
  module Patches
    module ProjectsControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
      end

      module InstanceMethods

        def rfb_project_settings
          if params[:reset].present?
            RfbProjectSetting.for_project(@project).destroy_all
            flash[:notice] = l(:notice_successful_update)
          else
            @settings = params[:settings]
            @settings.permit!

            project_setting = RfbProjectSetting.for_project(@project).first_or_initialize
            project_setting.assign_attributes(RfbProjectSetting.sanitize_settings(@settings))

            if project_setting.save!
              flash[:notice] = l(:notice_successful_update)
            else
              flash[:error] = l('redmine_file_bucket.project_settings.error_update_not_successful')
            end
          end

          redirect_to settings_project_path(@project, :tab => 'rfb_project_settings')
        end

      end

    end
  end
end

