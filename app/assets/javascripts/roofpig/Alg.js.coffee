#= require roofpig/Move
#= require roofpig/Rotation
#= require roofpig/CompositeMove

class @Alg
  constructor: (@move_codes, @dom_handler) ->
    if not @move_codes || @move_codes == ""
      throw new Error("Invalid alg: '#{@move_codes}'")
    this._pre_process()

    @actions = []
    for code in @move_codes.split(' ')
      if code.length > 0
        @actions.push(Alg._make_action(code))
    @next = 0
    @playing = false
    this._update_dom('first time')

  _pre_process: ->
    switch @move_codes.substring(0, 6)
      when 'shift>' then shift = 1
      when 'shift2' then shift = 2
      when 'shift<' then shift = 3

    if shift
      shifted_codes = ""
      for char in @move_codes.substring(6).split('')
        shifted_codes += Side.D.shift(char, shift) || char
      @move_codes = shifted_codes

  @_make_action: (code) ->
    if code.indexOf('+') > -1
      moves = (Alg._make_action(code) for code in code.split('+'))
      new CompositeMove(moves)
    else
      if code.indexOf('>') > -1 || code.indexOf('<') > -1
        new Rotation(code)
      else
        new Move(code)


  premix: (world3d) ->
    @next =  @actions.length
    until this.at_start()
      this.prev_move().premix(world3d)
    this

  next_move: ->
    unless this.at_end()
      @next += 1
      if this.at_end() then @playing = false
      this._update_dom()
      @actions[@next-1]

  prev_move: ->
    unless this.at_start()
      @next -= 1
      this._update_dom()
      @actions[@next]

  play: (world3d) ->
    @playing = true
    this._update_dom()
    new AlgAnimation(this, world3d)

  stop: ->
    @playing = false
    this._update_dom()

  at_start: ->
    @next == 0

  at_end: ->
    @next == @actions.length

  to_s: ->
    (@actions.map (move) -> move.to_s()).join(' ')

  standard_text: ->
    active = past = []
    future = []
    for action, i in @actions
      if @next == i then active = future
      if action.standard_text()
        active.push(action.standard_text())
    { past: past.join(' '), future: future.join(' ')}

  _update_dom: (time = 'later') ->
    return unless @dom_handler

    if time == 'first time'
      @dom_handler.init_alg_text(this.standard_text().future)

    @dom_handler.alg_changed(@playing, this.at_start(), this.at_end(), this._place_text(), this.standard_text())

  _place_text: ->
    total = current = 0
    for move, i in @actions
      current += move.count() if @next > i
      total += move.count()
    "#{current}/#{total}"