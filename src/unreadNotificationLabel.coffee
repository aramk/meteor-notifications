TemplateClass = Template.unreadNotificationLabel

# Limit value to avoid excessive width.
MAX_COUNT = 1000

TemplateClass.helpers
  value: ->
    value = getValue()
    return unless value?
    if value > MAX_COUNT then (MAX_COUNT - 1) + '+' else value
  hasValue: ->
    value = getValue()
    value? and value > 0

getValue = -> Notifications.getUnreadCount()

getTemplate = -> Template.instance()
