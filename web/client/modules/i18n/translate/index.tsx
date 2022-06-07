import { useContext } from 'react'
import { ctx as i18nContext } from '../index'

export default ({ contentId }) => {
  const { t, language } = useContext(i18nContext)
  const text = t(contentId, language)

  return text
}
