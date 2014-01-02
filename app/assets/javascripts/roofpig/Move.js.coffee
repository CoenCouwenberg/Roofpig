#= require roofpig/MoveExecution
#= require roofpig/Side

class @Move
  constructor: (code) ->
    [@side, @turns] = Move._parse_code(code)

    @turn_time = 200 * (1 + Math.abs(@turns))

  @_parse_code: (code) ->
    turns = switch code.substring(1)
      when "1", ""   then 1
      when "2", "²"  then 2
      when "3", "'"  then -1
      when "Z", "2'" then -2
    [Side.by_name(code[0]), turns]

  do: (world) ->
    this._do(world.pieces3d, @turns, false)

  undo: (world) ->
    this._do(world.pieces3d, -@turns, false)

  show_do: (world) ->
    this._do(world.pieces3d, @turns, true)

  show_undo: (world) ->
    this._do(world.pieces3d, -@turns, true)

  _do: (pieces3d, do_turns, animate) ->
    animation_pieces = pieces3d.on(@side)
    pieces3d.move(@side, do_turns)
    new MoveExecution(animation_pieces, @side.normal, do_turns * -Math.PI/2, @turn_time, animate)

  count: -> 1

  to_s: ->
    turn_code = switch @turns
      when  1 then ""
      when  2 then "2"
      when -1 then "'"
      when -2 then "Z"

    "#{@side.name}#{turn_code}"
