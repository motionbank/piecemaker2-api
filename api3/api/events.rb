module Piecemaker

  class Events < Grape::API

    resource 'event' do

      # --------------------------------------------------
      desc "returns event with id"
      params do
        requires :id, type: Integer, desc: "event id"
      end
      get "/:id" do
        @_user = authorize!
        Event.first(:id => params[:id]) || error!('Not found', 404)
      end

    end

  end
end