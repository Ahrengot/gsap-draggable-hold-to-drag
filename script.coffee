class ListSortController
	constructor: (container, views, @onDragCompleteCallback) ->
		@model = new ListSortModel( container, views )
		@enableTouchListners()
	enableTouchListners: ->
		@model.container.hammer().on( "hold", "ol li", @activate )
	disableTouchListeners: ->
		@model.container.hammer().off( "hold", @activate )
	activate: (e) =>
		@disableTouchListeners()
		@model.init()
		Backbone.on( "redraw-sortable-list", @redraw, @ )
		@listenForOrderChanges()
		@setInitialOrder()
		@createDraggables()
		if e then @forceStartDrag e
	forceStartDrag: (e) ->
		draggable = @getDraggableFromId e.currentTarget.getAttribute "data-id"
		draggable.startDrag e.gesture.srcEvent
	getDraggableFromId: (id) ->
		for d in @draggables
			if d._eventTarget.getAttribute( "data-id" ) is id
				return d
				break

	deactivate: (removeCSS = no) =>
		@stopListenForOrderChanges()
		@killDraggables removeCSS
		Backbone.off( "redraw-sortable-list", @redraw )
		@model.destroy()
		@enableTouchListners()
	setInitialOrder: ->
		@model.container.height ""
		@model.container.height( @model.container.height() )

		for view in @model.views
			view.$el.css { position: "absolute", width: "100%" }
			@reorderView.call( view, view.model, view.model.get( "order" ), no )
	createDraggables: ->
		if @draggables? then @killDraggables()

		self = @
		@draggables = []

		for view in @model.views
			dragOpts =
				type: "top"
				bounds: @model.container

				# Throwing / Dragging
				edgeResistance: 0.75
				throwProps: yes
				resistance: 3000
				snap: top: (endValue) ->
					# Snap to closest row
					return Math.max( @minY, Math.min( @maxY, Math.round( endValue / self.model.rowHeight ) * self.model.rowHeight ) );

				# Handlers
				onDragStartParams: [view, @model.views]
				onDragStart: @onDragStart
				onDragParams: [view, @model]
				onDrag: @onDrag
				onDragEndParams: [view, @model]
				onDragEnd: @onDragEnd
				onThrowComplete: =>
					@deactivate()
					@onDragCompleteCallback?.call @

			dragOpts.trigger = view.$el.find ".todo-content"
			draggable = new Draggable( view.el, dragOpts )

			@draggables.push draggable
	redraw: ->
		@killDraggables()
		@model.rows = @model.getRows()
		@setInitialOrder()
		@createDraggables()
	listenForOrderChanges: ->
		for view in @model.views
			view.model.on( "change:order", @reorderView, view )
	stopListenForOrderChanges: ->
		if @model?
			view.model.off(null, null, @) for view in @model?.views
	onDragStart: (view, allViews) =>
		view.$el.addClass "selected"
	onDrag: (view, model) ->
		model.reorderRows( view, @y )
		# if Modernizr.touch then model.scrollWindow( @pointerY )
		model.scrollWindow( @pointerY )
	onDragEnd: (view, model) ->
		model.reorderRows( view, @endY )
		view.$el.removeClass( "selected" ) unless view.model.get "selected"
	reorderView: (model, newOrder, animate = yes) ->
		dur = if animate then 0.3 else 0
		TweenLite.to( @el, dur, { top: newOrder * @$el.height() } )
	killDraggables: (removeCSS) ->
		if @draggables?
			draggable.disable() for draggable in @draggables
			@draggables = null
			@removeInlineStyles() if removeCSS
	removeInlineStyles: ->
		view.$el.removeAttr "style" for view in @model.views
	destroy: ->
		@deactivate yes
		@disableTouchListeners()
		@model = null