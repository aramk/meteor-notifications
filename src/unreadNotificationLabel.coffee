TemplateClass = Template.unreadNotificationLabel

TemplateClass.created = ->
  @value = new ReactiveVar(20)

TemplateClass.helpers
  value: -> getTemplate().value.get()
  hasValue: ->
    value = getTemplate().value.get()
    value? and value > 0

getTemplate = -> Template.instance()
