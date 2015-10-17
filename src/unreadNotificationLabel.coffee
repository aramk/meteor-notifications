TemplateClass = Template.unreadNotificationLabel

TemplateClass.created = ->
  @value = new ReactiveVar()
  updateValue(@)
  debounceUpdate = _.debounce (=> updateValue(@)), 500
  Collections.observe Events.getCollection(), debounceUpdate

TemplateClass.helpers
  value: -> getTemplate().value.get()
  hasValue: ->
    value = getTemplate().value.get()
    value? and value > 0

updateValue = (template) ->
  Meteor.call 'events/unreadCount', (err, result) ->
    unless err? then template.value.set parseFloat(result)

getTemplate = -> Template.instance()
