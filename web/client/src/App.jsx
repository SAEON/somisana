import { API_GQL } from './modules/config/env'
import { ApolloProvider } from '@apollo/client'
import { ApolloClient, InMemoryCache, HttpLink } from '@apollo/client'
import { light } from './theme/mui'
import { SnackbarProvider } from 'notistack'
import { ThemeProvider } from '@mui/material/styles'
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
import RouteSwitcher from './modules/layout/route-switcher'
import esriConfig from "@arcgis/core/config.js";
esriConfig.assetsPath = "./assets";

const apolloClient = new ApolloClient({
  cache: new InMemoryCache({}),
  link: new HttpLink({
    uri: API_GQL,
    credentials: 'include',
  }),
})

function App() {
  return (
    <ConfigProvider>
      <ApolloProvider client={apolloClient}>
        <ThemeProvider theme={light}>
          <CssBaseline>
            <Background>
              <ErrorBoundary>
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
              </ErrorBoundary>
            </Background>
          </CssBaseline>
        </ThemeProvider>
      </ApolloProvider>
    </ConfigProvider>
  )
}

export default App
