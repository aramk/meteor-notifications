templateName = 'notificationMessage'
TemplateClass = Template[templateName]

TemplateClass.helpers
  labelClass: -> getClass.call(@)
  iconClass: -> Notifications.config().getIconClass(@doc)
  hasLabel: -> if getClass.call(@)? then 'has-label'
  docLabel: -> Notifications.config().getDocLabel(@doc)
  eventClass: -> if @doc.eventId? then 'event'

getClass = ->
  labelClass = Notifications.config().getClass(@doc)
  if @doc.eventId and !labelClass
    'blue'
  else
    labelClass
