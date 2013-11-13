class ListSorter
	constructor: (@container, @views) ->
		@enableHoldListner()
	enableHoldListner: ->
		@container.hammer().on( "hold", "li", @activate )
	disableHoldListner: ->
		@container.hammer().off( "hold", @activate )
	activate: (e) =>
		@disableHoldListner()
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
		@killDraggables removeCSS
		@enableHoldListner()
	createDraggables: ->
		if @draggables? then @killDraggables()

		self = @
		@draggables = []

		for view in @views
			dragOpts =
				type: "y"
				bounds: @container
				# Handlers
				onDragStartParams: [view]
				onDragStart: @onDragStart
				onDragEndScope: @
				onDragEndParams: [view]
				onDragEnd: @onDragEnd

			draggable = new Draggable( view, dragOpts )
			@draggables.push draggable
	onDragStart: (view) =>
		$(view).addClass "dragging"
	onDragEnd: (view) ->
		$(view).removeClass( "dragging" )
		@deactivate()
	killDraggables: (removeCSS) ->
		if @draggables? then draggable.disable() for draggable in @draggables
		@removeInlineStyles() if removeCSS
	removeInlineStyles: ->
		$(view).removeAttr "style" for view in @views
	destroy: ->
		@deactivate yes
		@disableHoldListner()

# Expose ListSorter so we can use it outside of this file
window.ListSorter = ListSorter