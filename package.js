// Meteor package definition.
Package.describe({
  name: 'aramk:notifications',
  version: '1.0.1',
  summary: 'User notification messages',
  git: 'https://github.com/aramk/meteor-notifications.git'
});

Package.onUse(function (api) {
  api.versionsFrom('METEOR@1.6.1');
  api.use([
    'coffeescript@2.2.1_1',
    'email',
    'underscore',
    'templating@1.3.2',
    'less',
    'reactive-var@1.0.4',
    'tracker@1.0.5',
    'aldeed:simple-schema@1.3.2',
    'aldeed:collection2@2.3.3',
    'aramk:events@1.0.0_1',
    'momentjs:moment@2.10.3',
    'urbanetic:utility@2.0.1',
    'urbanetic:accounts-ui@1.0.0_1',
    'aramk:user-status@1.0.0'
  ], ['client', 'server']);
  api.use([
    'semantic:ui-css@2.1.2'
  ], {weak: true});
  api.export('Notifications', ['client', 'server']);
  api.addFiles([
    'src/Notifications.coffee'
  ], ['client', 'server']);
  api.addFiles([
    'src/client.coffee',
    'src/notificationBar.html',
    'src/notificationBar.coffee',
    'src/notificationList.html',
    'src/notificationList.coffee',
    'src/notificationListItem.html',
    'src/notificationListItem.coffee',
    'src/notificationMessage.html',
    'src/notificationMessage.coffee',
    'src/notifications.less',
    'src/notificationUserMenu.html',
    'src/notificationUserMenu.coffee',
    'src/unreadNotificationLabel.html',
    'src/unreadNotificationLabel.coffee',
    'src/userMenuButtons.html'
  ], 'client');
  api.addAssets([
    'assets/notificationEmailTemplate.html'
  ], 'server');
  api.addFiles([
    'src/server.coffee'
  ], 'server');
});
