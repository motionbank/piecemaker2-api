module Piecemaker

  class EventGroups < Grape::API

    resource 'groups' do

      desc "all event_groups for currently logged in user"
      get "/" do
        _user = authorize!
        # @todo acl!
        EventGroup.all || []
      end

    end

    resource 'group' do

      desc "create new event_group (together with user_has_event_groups record)"
      params do
        requires :title, type: String, desc: "name of the group"
        requires :text, type: String, desc: "some additional description" # @todo type: Text not String
      end 
      post "/" do
        _user = authorize!
        # @todo acl!

        event_group = EventGroup.create(
          :title => params[:title],
          :text  => params[:text])

        UserHasEventGroup.create(
          :user_id => _user.id,
          :event_group_id => event_group.id)

        return event_group
      end

    end

  end
end