@Players = new Meteor.Collection 'players'
@Holes = new Meteor.Collection 'holes'
###
players schema...
players: 
    id: 3218041230941
    name: 'Kedar Amladi'
    total_score: 0
    
    id: 3218041230941
    name: 'Christian Kasilag'
    total_score: 0
    
    id: 3218041230941
    name: 'Will Records'
    total_score: 0

Holes:
	hole_number: 1
	par: 3
	scores:
		player_id: 2345823075968273045
		score: 4
		
		player_id: 2345823075968273045
		score: 3
		
		player_id: 2345823075968273045
		score: 9
	
	hole_number: 2
	par: 4
	scores:
		player_id: 2345823075968273045
		score: 5
		
		player_id: 2345823075968273045
		score: 8
		
		player_id: 2345823075968273045
		score: 4