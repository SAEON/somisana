import { lazy, Suspense } from 'react'
import Loading from '../../../components/loading'
import { Home, Contract, Map, About, Github, License } from '../../../components/icons'
import HomePage from './home'
import VisualizationsPage from './visualizations'

const PrivacyPolicyPage = lazy(() => import('../../../modules/privacy-policy'))
const AboutPage = lazy(() => import('../../../modules/about'))

export default [
  {
    to: '/',
    path: '*',
    label: 'Home',
    Icon: Home,
    includeInNavMenu: true,
    includeInFooter: true,
    element: props => <HomePage {...props} />,
  },

  {
    to: '/visualizations',
    path: '/visualizations',
    label: 'Visualisations',
    Icon: Map,
    includeInNavMenu: true,
    includeInFooter: true,
    element: props => <VisualizationsPage {...props} />,
  },

  {
    to: '/about',
    path: '/about',
    label: 'About',
    Icon: About,
    includeInNavMenu: true,
    includeInFooter: true,
    element: props => (
      <Suspense fallback={<Loading />}>
        <AboutPage {...props} />
      </Suspense>
    ),
  },

  {
    to: '/privacy-policy',
    path: '/privacy-policy',
    label: 'Privacy policy',
    group: 'legal',
    includeInFooter: true,
    includeInNavMenu: false,
    Icon: Contract,
    element: props => (
      <Suspense fallback={<Loading />}>
        <PrivacyPolicyPage {...props} />
      </Suspense>
    ),
  },

  {
    to: '/no-route', // Hack - the to property is still required
    group: 'source code',
    label: 'Source code',
    Icon: Github,
    href: 'https://github.com/SAEON/somisana',
    includeInNavMenu: false,
    includeInFooter: true,
  },
  {
    to: '/no-route', // Hack - the to property is still required
    group: 'source code',
    label: 'License (MIT)',
    Icon: License,
    includeInNavMenu: false,
    includeInFooter: true,
    href: 'https://github.com/SAEON/somisana/blob/stable/LICENSE',
  },
]
