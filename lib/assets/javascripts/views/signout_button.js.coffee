Marbles.Views.SignoutButton = class SignoutButtonView extends Marbles.View
  @view_name: 'signout_button'

  initialize: =>
    Marbles.DOM.on @el, 'click', @performSignout

  performSignout: (e) =>
    e?.preventDefault()

    new Marbles.HTTP {
      method: 'POST'
      url: TentStatus.config.SIGNOUT_URL
      middleware: [{
        processRequest: (request) ->
          request.request.xmlhttp.withCredentials = true
      }]
      callback: (res, xhr) =>
        @signoutRedirect()
    }

  signoutRedirect: =>
    window.location.href = TentStatus.config.SIGNOUT_REDIRECT_URL

