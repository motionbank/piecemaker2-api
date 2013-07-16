module.exports = function (db, cb) {
    db.define('users', {
        name : String
    });

    return cb();
};