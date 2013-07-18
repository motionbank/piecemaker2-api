module Piecemaker

  class EventGroups < Grape::API

    resource 'groups' do

      desc "get all event_groups for current user (with read rights)"
      get "/" do
        _user = authorize!
        # @todo acl!
        EventGroup.all || []
      end

    end

    resource 'group' do

      desc "create new event_group and record for user_has_event_groups"
      params do
        requires :title, type: String, desc: "name of the group"
        requires :text, type: String, desc: "some additional description" # @todo type: Text not String
      end 
      post "/" do
        _user = authorize!
        # @todo acl!

        EventGroup.create(
          :title => params[:title],
          :text  => params[:text])
      end

    end

  end
end