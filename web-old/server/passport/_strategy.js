import { collections } from '../mongo/index.js'
import { Strategy } from 'openid-client'
import {
  ODP_AUTH,
  ODP_SSO_CLIENT_SECRET,
  ODP_SSO_CLIENT_ID,
  ODP_SSO_CLIENT_REDIRECT,
  ODP_AUTH_LOGOUT_REDIRECT,
  PASSPORT_SSO_MAXAGE_HOURS,
} from '../config/index.js'
import { makeLog, logToMongo } from '../mongo/index.js'

export default hydra =>
  new Strategy(
    {
      client: new hydra.Client({
        client_id: ODP_SSO_CLIENT_ID,
        client_secret: ODP_SSO_CLIENT_SECRET,
        redirect_uris: [ODP_SSO_CLIENT_REDIRECT],
        post_logout_redirect_uris: [ODP_AUTH_LOGOUT_REDIRECT],
        token_endpoint_auth_method: 'client_secret_post',
        response_types: ['code'],
      }),
    },
    async (tokenSet, userInfo, cb) => {
      const { email, sub: saeonId, name, picture } = userInfo
      const { Users, Roles } = await collections
      const saeonRoleId = (await Roles.find({ name: 'saeon' }).toArray())[0]._id
      const userRoleId = (await Roles.find({ name: 'user' }).toArray())[0]._id
      const emailAddress = email.toLowerCase()
      const isSaeon = emailAddress.match(/@saeon\.nrf\.ac\.za$/)

      try {
        const userQuery = await Users.findOneAndUpdate(
          {
            emailAddress,
          },
          {
            $setOnInsert: {
              emailAddress,
              roles: [isSaeon ? saeonRoleId : userRoleId],
            },
            $set: {
              authAddress: ODP_AUTH,
              saeonId,
              name,
              tokenSet,
            },
            $addToSet: {
              links: {
                picture,
              },
            },
          },
          {
            upsert: true,
            returnDocument: 'after',
          }
        )
        const user = userQuery.value

        // Log successful authentication
        logToMongo.load(
          makeLog(null, {
            type: 'authentication',
            userId: user._id,
            info: {
              userName: userInfo.name,
            },
          })
        )

        cb(null, { id: user._id, emailAddress: user.emailAddress, name: user.name })
      } catch (error) {
        console.error('Error authenticating', error.message)
        cb(error, null)
      }
    }
  )
