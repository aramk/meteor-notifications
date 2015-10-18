TemplateClass = Template.unreadNotificationLabel

TemplateClass.helpers
  value: -> getValue()
  hasValue: ->
    value = getValue()
    value? and value > 0

getValue = -> Notifications.getUnreadCount()

getTemplate = -> Template.instance()
