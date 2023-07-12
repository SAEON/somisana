export const ALLOWED_ORIGINS = process.env.ALLOWED_ORIGINS?.split(',') || [
  'http://localhost:3000',
  'http://localhost:3001',
]
export const DEPLOYMENT_ENV = process.env.DEPLOYMENT_ENV || 'development'
export const HOSTNAME = process.env.HOSTNAME || 'http://localhost:3000'
export const KEY = process.env.KEY || '7cwANClfrqqNFmpOmcP0OzWDzdcras0EdIqD3RAUUCU='
export const NODE_ENV = process.env.NODE_ENV || 'development'
export const PORT = process.env.PORT || 3000
export const NODE_VERSION = process.version
