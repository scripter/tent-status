TentStatus.Models.MetaProfile = class  MetaProfileModel extends Marbles.Model
  @model_name: 'meta_profile'
  @id_mapping_scope: ['entity']

  @post_type: new TentClient.PostType(TentStatus.config.POST_TYPES.META)

  @fetch: (entity, options = {}) ->
    params = {entity:entity}

    completeFn = (res, xhr) =>
      if xhr.status != 200
        @trigger("fetch:failure", params, res, xhr)
        options.failure?(res, xhr)
        options.complete?(res, xhr)
        return

      constructorFn = @
      server_meta_post = res.post
      model = new constructorFn(_.extend({
        entity: server_meta_post.content.entity
        avatar_digest: server_meta_post.attachments?[0]?.digest
      }, server_meta_post.content.profile || {}))

      @trigger("fetch:success", model, xhr)
      options.success?(model, xhr)
      options.complete?(res, xhr)

    TentStatus.tent_client.discover(
      params: params
      callback: completeFn
    )

  constructor: ->
    @on 'change:avatar_digest', (digest) =>
      if digest
        @set('avatar_url', TentStatus.tent_client.getSignedUrl('attachment', entity: @get('entity'), digest: digest))
      else
        @set('avatar_url', TentStatus.config.DEFAULT_AVATAR_URL)

    super

  parseAttributes: =>
    super

    unless @get('avatar_url')
      @set('avatar_url', TentStatus.config.DEFAULT_AVATAR_URL)

TentStatus.once 'config:ready', ->
  server_meta_post = TentStatus.config.current_user.server_meta_post
  TentStatus.meta_profile = new MetaProfileModel(_.extend(
    {
      entity: server_meta_post.content.entity,
      avatar_digest: server_meta_post.attachments?[0]?.digest
    },
    server_meta_post.content.profile || {}
  ))
