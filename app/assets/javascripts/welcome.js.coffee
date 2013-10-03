# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
app = angular.module('app',[])
window.app = app

app.factory 'faye', ($rootScope)->
  client: new Faye.Client("http://localhost:9292/faye")
  sub: (channel, cb)->
    @client.subscribe channel, (data) ->
      console.log('recieve', arguments)
      args = arguments
      $rootScope.$apply ()->
        cb.apply(null, args)
  pub: (channel, message, cb)->
    console.log('send', message)
    p = @client.publish(channel, message)
    p.callback ->
      args = arguments
      $rootScope.$apply (data)->
        cb.apply(null, args)
    p.errback (err)->
      console.error err

app.controller 'Chat', ($scope, faye) ->
  $scope.ms = [
    user: 'robot',
    text: 'Welcome to chat!'
  ]

  $scope.user= "Anton"

  faye.sub "/server", (message) ->
    console.log('message', message)
    $scope.ms.push(message)

  $scope.sendMessage = ()->
    return if ! $scope.message
    m = {text: $scope.message, user: $scope.user }
    faye.pub "/browser", m, ()->
      $scope.message = ""
