request = require 'request'
_ = require 'lodash'

header = () ->
  "frame,lever,button\n30, 6, select\n15, 5, \n"

str_to_steps = (str) ->
  match = /^(\d)(.*?)($|\d.*)/.exec(str)
  if match == null
    []
  else
    [[match[1], match[2]]].concat(str_to_steps(match[3]))

compress = (steps) ->
  if steps.length == 0
    []
  else
    first = _.first(steps)
    duplicate = _.first _.tail(steps), (step) ->
      "#{step}" == "#{first}"
    [[first[0], first[1], duplicate.length + 1]].concat(compress(steps.slice(duplicate.length + 1)))

step_to_csv = (step) ->
  "#{step[2] * 2}, #{step[0]}, #{step[1]}\n"

module.exports = (robot) ->
  robot.respond /(.*)/i, (msg) ->
    steps = compress(str_to_steps(msg.match[1]))
    request.post
      url: 'http://localhost:4567/index'
      form:
        command: header() + _.map(steps, (step) -> step_to_csv(step)).join('')
    , (err, response, body) ->
    msg.send _.map(steps, (step) -> step_to_csv(step)).join('')

