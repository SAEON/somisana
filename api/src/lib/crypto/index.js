// https://stackoverflow.com/a/53573115/3114742
import crypto from 'crypto'

const ALGORITHM = {
  BLOCK_CIPHER: 'aes-256-gcm',
  AUTH_TAG_BYTE_LEN: 16,
  IV_BYTE_LEN: 12,
  KEY_BYTE_LEN: 32,
  SALT_BYTE_LEN: 16,
}

const getIV = () => crypto.randomBytes(ALGORITHM.IV_BYTE_LEN)

export const getRandomKey = () => crypto.randomBytes(ALGORITHM.KEY_BYTE_LEN)

/**
 * To prevent rainbow table attacks
 * */
export const getSalt = () => crypto.randomBytes(ALGORITHM.SALT_BYTE_LEN)

/**
 *
 * @param {Buffer} password - The password to be used for generating key
 *
 * To be used when key needs to be generated based on password.
 * The caller of this function has the responsibility to clear
 * the Buffer after the key generation to prevent the password
 * from lingering in the memory
 */
export const getKeyFromPassword = (password, salt) => {
  return crypto.scryptSync(password, salt, ALGORITHM.KEY_BYTE_LEN)
}

/**
 *
 * @param {Buffer} messageText - The clear text message to be encrypted
 * @param {Buffer} key - The key to be used for encryption
 *
 * The caller of this function has the responsibility to clear
 * the Buffer after the encryption to prevent the message text
 * and the key from lingering in the memory
 */
export const encrypt = (messageText, key) => {
  const iv = getIV()
  const cipher = crypto.createCipheriv(ALGORITHM.BLOCK_CIPHER, key, iv, {
    authTagLength: ALGORITHM.AUTH_TAG_BYTE_LEN,
  })
  let encryptedMessage = cipher.update(messageText)
  encryptedMessage = Buffer.concat([encryptedMessage, cipher.final()])
  return Buffer.concat([iv, encryptedMessage, cipher.getAuthTag()])
}

/**
 *
 * @param {Buffer} ciphertext - Cipher text
 * @param {Buffer} key - The key to be used for decryption
 *
 * The caller of this function has the responsibility to clear
 * the Buffer after the decryption to prevent the message text
 * and the key from lingering in the memory
 */
export const decrypt = (ciphertext, key) => {
  const authTag = ciphertext.slice(-16)
  const iv = ciphertext.slice(0, 12)
  const encryptedMessage = ciphertext.slice(12, -16)
  const decipher = crypto.createDecipheriv(ALGORITHM.BLOCK_CIPHER, key, iv, {
    authTagLength: ALGORITHM.AUTH_TAG_BYTE_LEN,
  })
  decipher.setAuthTag(authTag)
  let messageText = decipher.update(encryptedMessage)
  messageText = Buffer.concat([messageText, decipher.final()])
  return messageText
}
