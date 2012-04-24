Meteor.startup ->
    if Players.find().count() is 0
        ###
        Players.insert
            name: 'Kedar Amladi'
            throws: 0
        Players.insert
            name: 'Christian Kasilag'
            throws: 0
        Players.insert
            name: 'Will Records'
            throws: 0
        ###
