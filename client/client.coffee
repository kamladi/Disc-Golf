Router = Backbone.Router.extend(
	routes:
		'players/:player_id': 'main'
	
	main: (player_id) ->
		Session.set "player_id", player_id
	
	setPlayer: (player_id) ->
		@navigate player_id, true
	
)

AppRouter = new Router

Meteor.startup ->
	Backbone.history.start pushState: true
	#load curernt_player_id from localStorage if it exists
	if window.localStorage['discgolf_current_player_id']
		Session.set('current_player_id', window.localStorage['discgolf_current_player_id'])
		AppRouter.setPlayer 'players/' + Session.get('current_player_id')
	else
		alert "Welcome to the discgolf game!"

is_current_player = (player_id) ->
	return player_id == Session.get('current_player_id')

#LEADERBOARDS
Template.leaderboards.players = ->
	Players.find({}, {
		sort:
			total_score: 1
			name: 1
	})


Template.leaderboards.events =
	'click input#create-new-player-btn, keypress input#new-player-name': (e) ->
		if e.keyCode and e.keyCode isnt 13
			return false
		name = $('input#new-player-name').val()
		#check if name already exists as player
		player = Players.findOne({name: name})
		if player
			alert 'A player with that name already exists. Try another name.'
			return false
		else
			id = Players.insert({name: name, total_score: 0});
			Session.set('current_player_id', id)
			localStorage['discgolf_current_player_id'] = id
			$('input#new-player-name').val('')
			AppRouter.navigate 'players/' + id, true
		
#PLAYER LIST ITEM
Template.playerListItem.events = 
	'click a': (e) ->
		AppRouter.setPlayer @_id


#PLAYER DETAIL VIEW
Template.playerDetail.selectedPlayer = ->
	player_id = Session.get('player_id')
	if not player_id
		player_id = Session.get 'current_player_id'
	player = Players.findOne(player_id)

Template.playerDetail.is_current_player = ->
	return is_current_player Session.get('player_id')

Template.playerDetail.events = 
	'click input#new-score-btn, keypress input#new-score, keypress input#hole': (e) ->
		if e.keyCode and e.keyCode isnt 13
			return false
		hole_number = parseInt $('input#hole').val()
		#validate hole number
		if not hole_number or hole_number <= 0
			alert 'Not a valid hole number'
			return false
		score = parseInt $('input#new-score').val()
		#validate score
		if not score or score <= 0
			alert 'Not a valid score'
			return false
		console.log 'hole number: ' + hole_number
		console.log 'score entered: ' + score
		
		hole = Holes.findOne({hole_number: hole_number})
		
		if not hole # hole doesn't exist yet
			par = parseInt(window.prompt("First score for hole "+hole_number+". What is this hole's par?", "3"))
			if not par or par <= 0
				alert "not a valid par"
				return false
			#create new hole and add score to it
			Holes.insert(
				hole_number: hole_number
				par: par
				scores: [{
					player_id: Session.get 'current_player_id'
					score: score
				}]
			)
		else # hole does exist
			#search if score for player exists already
			for x in hole.scores
				if x.player_id is Session.get 'current_player_id'
					#ask for overwrite
					confirm = window.confirm "Score already exists for hole " + hole_number + ". Overwrite?"
					if confirm is true #player wants to overwrite
						#remove current score
						Holes.update({hole_number: hole_number}, {
							$pull:
								scores:
									player_id: Session.get 'current_player_id'
						})
						Players.update(Session.get('current_player_id'), {
							$inc:
								total_score: parseInt(score * (-1))
						})
					else # player cancels out
						return false
			# player does not have score yet for hole_number
			Holes.update({hole_number: hole_number}, {
				$push:
					scores:
						player_id: Session.get 'current_player_id'
						score: score
			})
			
		#update Players total_score
		Players.update(Session.get('current_player_id'),
			$inc:
				total_score: score
		)
	
Template.playerDetail.holes = ->
	scoresList = []
	cur = Holes.find({}, {sort: {hole_number: -1}}).fetch()
	cur.forEach (hole) ->
		for x in hole.scores
			if x.player_id is Session.get 'player_id'
				scoresList.push(
					hole_number: hole.hole_number
					par: hole.par
					score: x.score
				)
	return scoresList
