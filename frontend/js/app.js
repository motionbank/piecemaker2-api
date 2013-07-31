var directory = {

    views: {},

    models: {},

    loadTemplates: function(views, callback) {

        var deferreds = [];

        $.each(views, function(index, view) {
            if (directory[view]) {
                deferreds.push($.get('tpl/' + view + '.html', function(data) {
                    directory[view].prototype.template = _.template(data);
                }, 'html'));
            } else {
                alert(view + " not found");
            }
        });

        $.when.apply(null, deferreds).done(callback);
    }

};

directory.Router = Backbone.Router.extend({

    routes: {
        "":                "home",
        "pieces":          "piecesList",
        "pieces/:id":      "piecesDetail"
    },

    initialize: function () {
        directory.shellView = new directory.ShellView();
        $('body').html(directory.shellView.render().el);
        this.$content = $("#content");
    },

    home: function () {

        // Since the home view never changes, we instantiate it and render it only once
        if (!directory.homelView) {
            directory.homelView = new directory.HomeView();
            directory.homelView.render();
        } else {
            directory.homelView.delegateEvents(); // delegate events when the view is recycled
        }

        this.$content.html(directory.homelView.el);
        directory.shellView.selectMenuItem('home-menu');
    },

    piecesList: function () {

        // Since the home view never changes, we instantiate it and render it only once
        if (!directory.piecesListView) {
            directory.piecesListView = new directory.PiecesListView();
            directory.piecesListView.render();
        }

        this.$content.html(directory.piecesListView.el);
        directory.shellView.selectMenuItem('pieces-menu');
    },

    piecesDetail: function (id) {
        directory.piecesDetailView = new directory.PiecesDetailView({model: id});
        directory.piecesDetailView.render();
        this.$content.html(directory.piecesDetailView.el);
        directory.shellView.selectMenuItem('pieces-menu');
    }

});

$(document).on("ready", function () {
    directory.loadTemplates(["HomeView", "PiecesListView", "PiecesDetailView", "ShellView"],
        function () {
            directory.router = new directory.Router();
            Backbone.history.start();
        });
});