import { ObjectId } from 'mongodb'

/**
 * TODO
 * Once Mongo Docker is updated to v5, look at options for
 * joining in a single query
 *
 * update => this can be done now as mongo is v6
 */
export default async (ctx, ...permissions) => {
  permissions = permissions.map(({ name }) => name)
  const { findRoles, findUsers, findPermissions } = ctx.mongo.dataFinders

  if (!ctx.userInfo) {
    ctx.throw(401)
    return
  }

  const { userInfo } = ctx
  const { id: userId } = userInfo

  /**
   * First get permission IDs from permission names
   */
  const permissionIds = (await findPermissions({ name: { $in: permissions } })).map(
    ({ _id }) => _id
  )

  /**
   * Then get the roles that have those permissions
   */
  const roleIds = (await findRoles({ permissions: { $in: permissionIds } })).map(({ _id }) => _id)

  /**
   * Then see if there is a user with these roles, and the userId
   */
  const user = (await findUsers({ _id: new ObjectId(userId), roles: { $in: roleIds } }))[0]

  /**
   * If there is no user,
   * then throw forbidden
   */
  if (!user) {
    ctx.throw(403)
  }

  /**
   * TODO Log successful authorization
   *
   * While this does allow for an audit trail of database changes
   * via the API, this currently results in too many logs to be
   * useful at this point
   */
}
