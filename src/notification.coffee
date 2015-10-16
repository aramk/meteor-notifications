templateName = 'notification'
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
  levelClass: -> LevelClasses[@doc.label]
  levelIcon: -> LevelIcons[@doc.label]
