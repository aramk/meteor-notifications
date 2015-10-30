templateName = 'notificationMessage'
TemplateClass = Template[templateName]

LevelIcons =
  info: 'info circle'
  debug: 'info circle'
  warn: 'warning sign'
  error: 'ban'

LevelClasses =
  info: 'info'
  debug: ''
  warn: 'warning'
  error: 'error'

TemplateClass.helpers
  levelClass: -> getLevelClass.call(@)
  levelIcon: -> LevelIcons[@doc.label]
  hasLevel: -> if getLevelClass.call(@)? then 'has-level'
  docLabel: -> Notifications.getDocLabel(@doc)

getLevelClass = -> LevelClasses[@doc.label]
