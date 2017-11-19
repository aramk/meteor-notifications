TemplateClass = Template.unreadNotificationLabel

TemplateClass.helpers
  value: ->
    value = getValue()
    return unless value?
    if value >= UserEventStats.MAX_COUNT then (UserEventStats.MAX_COUNT - 1) + '+' else value
  hasValue: ->
    value = getValue()
    value? and value > 0

getValue = -> Notifications.getUnreadCount()

getTemplate = -> Template.instance()
