import { API_GQL } from './modules/config/env'
import { ApolloProvider } from '@apollo/client'
import { ApolloClient, InMemoryCache, HttpLink } from '@apollo/client'
import { SnackbarProvider } from 'notistack'
import Theme from './theme'
import { light as lightTheme, dark as darkTheme } from './theme/mui'
import AuthenticationProvider from './modules/authentication'
import CssBaseline from '@mui/material/CssBaseline'
import ErrorBoundary from './components/error-boundary'
import NativeExtensions from './components/native-extensions'
import ConfigProvider from './modules/config'
import ApplicationLogger from './modules/application-logger'
import LogAppRender from './modules/application-logger/app-render'
import InteractionLogger from './modules/application-logger/interaction-logger'
import { BrowserRouter as Router } from 'react-router-dom'
import Background from './modules/background'
import Div from './components/div'
import Header from './header'
import Footer from './modules/footer'
import routes from './routes/config'
import I18nProvider from './modules/i18n'
import RouteSwitcher from './modules/layout/route-switcher'
import SiteSettingsProvider from './modules/site-settings'
import c from 'cookie'

const apolloClient = new ApolloClient({
  cache: new InMemoryCache({}),
  link: new HttpLink({
    uri: API_GQL,
    credentials: 'include',
  }),
})

const SETTINGS_COOKIE_KEY = 'SOMISANA_SITE_SETTINGS'

const LANGS = ['en']

const negotiator = language => {
  return LANGS[0]
}

function App() {
  // Load settings cookie
  const cookie = c.parse(document.cookie || '')?.[SETTINGS_COOKIE_KEY]
  const acceptLanguage = negotiator(window.navigator.language)
  const sessionSettings = JSON.parse(cookie || '{}')

  return (
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
                  <Background>
                    <NativeExtensions>
                      <SnackbarProvider>
                        <AuthenticationProvider>
                          <ApplicationLogger>
                            <LogAppRender>
                              <InteractionLogger>
                                <Router>
                                  <Header routes={routes}>
                                    <Div sx={{ display: 'flex', alignItems: 'center' }} />
                                  </Header>
                                  <RouteSwitcher routes={routes} />
                                  <Footer routes={routes} />
                                </Router>
                              </InteractionLogger>
                            </LogAppRender>
                          </ApplicationLogger>
                        </AuthenticationProvider>
                      </SnackbarProvider>
                    </NativeExtensions>
                  </Background>
                </ErrorBoundary>
              </I18nProvider>
            </CssBaseline>
          </Theme>
        </ApolloProvider>
      </SiteSettingsProvider>
    </ConfigProvider>
  )
}

export default App
