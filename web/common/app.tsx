import { ApolloProvider } from '@apollo/client'
import { CacheProvider as EmotionCacheProvider } from '@emotion/react'
import { light as lightTheme, dark as darkTheme } from './theme/mui'
import { SnackbarProvider } from 'notistack'
import AuthenticationProvider from '../client/modules/authentication'
import c from 'cookie'
import ConfigProvider from '../client/modules/config'
import createCache from '@emotion/cache'
import CssBaseline from '@mui/material/CssBaseline'
import ErrorBoundary from '../client/components/error-boundary'
import I18nProvider from '../client/modules/i18n'
import NativeExtensions from '../client/modules/native-extensions'
import SiteSettingsProvider from '../client/modules/site-settings'
import Theme from './theme'
import ApplicationLogger, { LogAppRender } from '../client/modules/application-logger'

const SETTINGS_COOKIE_KEY = 'SOMISANA_SITE_SETTINGS'

const LANGS = ['en']

const negotiator = language => {
  return LANGS[0]
}

export const createEmotionCache = () => createCache({ key: 'css' })

const App = ({
  Router,
  apolloClient,
  children,
  emotionCache = createEmotionCache(),
  cookie = undefined,
  acceptLanguage = negotiator(window.navigator.language),
}) => {
  /**
   * Load the cookie
   */
  const _cookie = c.parse(
    cookie || (typeof document === 'undefined' ? '' : document.cookie) || ''
  )?.[SETTINGS_COOKIE_KEY]

  const sessionSettings = JSON.parse(_cookie || '{}')

  return (
    <EmotionCacheProvider value={emotionCache}>
      <ConfigProvider>
        <SiteSettingsProvider
          acceptLanguage={acceptLanguage}
          cookieKey={SETTINGS_COOKIE_KEY}
          sessionSettings={sessionSettings}
        >
          <ApolloProvider client={apolloClient}>
            <Theme themes={{ light: lightTheme, dark: darkTheme }}>
              <CssBaseline>
                <I18nProvider>
                  <ErrorBoundary>
                    <NativeExtensions>
                      <SnackbarProvider>
                        <AuthenticationProvider>
                          <ApplicationLogger>
                            <LogAppRender>
                              <Router>{children}</Router>
                            </LogAppRender>
                          </ApplicationLogger>
                        </AuthenticationProvider>
                      </SnackbarProvider>
                    </NativeExtensions>
                  </ErrorBoundary>
                </I18nProvider>
              </CssBaseline>
            </Theme>
          </ApolloProvider>
        </SiteSettingsProvider>
      </ConfigProvider>
    </EmotionCacheProvider>
  )
}

export default App
