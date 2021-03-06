
module FileBucketHelper
  include ApplicationHelper

  def humanize_option_type(container_str)
    option_type_key = RfbProjectSetting::LOCALIZED_OPTION_TYPE[container_str]

    if option_type_key
      l(option_type_key)
    else
      container_str
    end
  end

  def link_to_attachment_container(attachment)
    case attachment.container_type
    when 'Issue' then
      link_to "[#{attachment.container.tracker.name} ##{attachment.container_id}] #{attachment.container.subject}", issue_path(attachment.container_id)
    when 'Project' then
      link_to attachment.project.name, project_files_path(attachment.container_id)
    when 'Version' then
      link_to attachment.container.name, version_path(attachment.container_id)
    when 'WikiPage' then
      link_to attachment.container.title,
        url_for(:controller => 'wiki',
                :action => 'show',
                :project_id => attachment.project.id,
                :id => Wiki.titleize(attachment.container.title),
                :version => nil
        )
    when 'Document' then
      link_to attachment.container.title, document_path(attachment.container_id)
    when 'News' then
      link_to attachment.container.title, news_path(attachment.container_id)
    else
      ''
    end
  end

  def link_to_attachment_project(attachment)
    link_to attachment.project.name, project_path(attachment.project.id)
  end

  def link_to_subproject_if_exist(target_project)
    if @project.id == target_project.id
      ''
    else
      link_to target_project.name, project_path(target_project.id)
    end
  end

  def prepare_attachments_for_bucket(attachments)
    attachments.map do |file|
      {
        :container_type => file.container_type,
        :container_type_formatted => humanize_option_type(file.container_type),
        :file_name => link_to_attachment(file, :download => true, :title => file.content_type),
        :file_size => number_to_human_size(file.filesize),
        :description => file.description,
        :location => link_to_attachment_container(file),
        :author => file.author.name,
        :created_on => format_time(file.created_on),
        :downloads => download_count_for_attachment(file),
        :subproject => link_to_subproject_if_exist(file.project),
        :action => (link_to(image_tag('delete.png'), attachment_path(file), :data => {:confirm => l(:text_are_you_sure)}, :method => :delete) if @delete_allowed)
      }
    end.to_json
  end

  def download_count_for_attachment(attachment)
    if attachment.container.is_a?(Version) || attachment.container.is_a?(Project)
      attachment.downloads
    else
      attachment.downloads > 0 ? attachment.downloads : '-'
    end
  end

end

